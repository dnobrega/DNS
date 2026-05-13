# -------------------------------------------------------------------
# Sampling scalar fields on traced ragged field lines
# -------------------------------------------------------------------

from __future__ import annotations

from dataclasses import dataclass
from typing import Tuple

import numpy as np
from numba import njit, prange

EXIT_ZMIN = 1
EXIT_ZMAX = 2
EXIT_YMIN = 3
EXIT_YMAX = 4
EXIT_XMIN = 5
EXIT_XMAX = 6
EXIT_MAX_STEPS = 7
EXIT_BNORM_TOO_SMALL = 8
EXIT_NAN = 9
EXIT_INTERP_ERROR = 10

@dataclass
class ScalarSampleResult:
    """Scalar values sampled on an existing ragged TraceResult."""

    values_all: np.ndarray
    line_start: np.ndarray
    line_count: np.ndarray
    codes_all: np.ndarray
    
    @property
    def nlines(self) -> int:
        return self.line_count.size

    @property
    def total_points(self) -> int:
        return self.values_all.size

    
    def get_values(self, i: int) -> np.ndarray:
        """Return sampled scalar values for line i."""
        i0 = int(self.line_start[i])
        i1 = i0 + int(self.line_count[i])
        return self.values_all[i0:i1]

    def get_codes(self, i: int) -> np.ndarray:
        """Return sampling codes for line i."""
        i0 = int(self.line_start[i])
        i1 = i0 + int(self.line_count[i])
        return self.codes_all[i0:i1]


def validate_scalar_grid(
    scalar: np.ndarray,
    xgrid: np.ndarray,
    ygrid: np.ndarray,
    zgrid: np.ndarray,
) -> None:
    """Validate scalar field shape and grid compatibility."""
    if scalar.ndim != 3:
        raise ValueError("scalar must have shape (nz, ny, nx).")

    nz, ny, nx = scalar.shape

    if xgrid.ndim != 1 or ygrid.ndim != 1 or zgrid.ndim != 1:
        raise ValueError("xgrid, ygrid, zgrid must be 1D arrays.")

    if len(xgrid) != nx or len(ygrid) != ny or len(zgrid) != nz:
        raise ValueError(
            "Grid lengths do not match scalar shape: "
            f"scalar shape=(nz={nz}, ny={ny}, nx={nx}), "
            f"len(zgrid)={len(zgrid)}, len(ygrid)={len(ygrid)}, len(xgrid)={len(xgrid)}."
        )

    for name, g in [("xgrid", xgrid), ("ygrid", ygrid), ("zgrid", zgrid)]:
        if not np.all(np.isfinite(g)):
            raise ValueError(f"{name} contains NaN/Inf.")
        if not np.all(np.diff(g) > 0):
            raise ValueError(f"{name} must be strictly increasing.")

def is_uniform_grid(grid: np.ndarray, rtol: float = 1e-6, atol: float = 0.0) -> bool:
    """Return True if a 1D grid is approximately uniformly spaced."""
    grid = np.asarray(grid)
    if grid.size < 3:
        return True
    d = np.diff(grid)
    return bool(np.allclose(d, d[0], rtol=rtol, atol=atol))

def _inv_spacing(grid: np.ndarray, dtype) -> float:
    return dtype.type(1.0) / dtype.type(grid[1] - grid[0])
        
def sample_scalar_on_lines(
    result: TraceResult,
    scalar: np.ndarray,
    xgrid: np.ndarray,
    ygrid: np.ndarray,
    zgrid: np.ndarray,
    *,
    periodic_x: bool = True,
    periodic_y: bool = True,
    periodic_z: bool = False,
    dtype: np.dtype = np.float32,
    bad_value: float = np.nan,
) -> ScalarSampleResult:
    """
    Sample a 3D scalar field on all points of a ragged TraceResult.

    Parameters
    ----------
    result : TraceResult
        Field-line tracing result.
    scalar : ndarray
        Scalar field with shape (nz, ny, nx).
    xgrid, ygrid, zgrid : ndarray
        1D coordinate arrays.
    periodic_x, periodic_y, periodic_z : bool
        Periodicity flags used for interpolation.
    dtype : np.dtype
        Floating dtype for internal arrays and output.
    bad_value : float
        Value assigned when interpolation fails.

    Returns
    -------
    ScalarSampleResult
        values_all has the same ragged layout as result.xfl.
        codes_all is 0 for successful interpolation; otherwise it stores
        an interpolation/debug code.
    """

    dtype = np.dtype(dtype)

    validate_scalar_grid(scalar, xgrid, ygrid, zgrid)

    scalar_c = np.ascontiguousarray(scalar, dtype=dtype)
    xg_c = np.ascontiguousarray(xgrid, dtype=dtype)
    yg_c = np.ascontiguousarray(ygrid, dtype=dtype)
    zg_c = np.ascontiguousarray(zgrid, dtype=dtype)

    xfl = np.ascontiguousarray(result.xfl, dtype=dtype)
    yfl = np.ascontiguousarray(result.yfl, dtype=dtype)
    zfl = np.ascontiguousarray(result.zfl, dtype=dtype)

    values_all = np.empty_like(xfl, dtype=dtype)
    codes_all = np.empty(xfl.size, dtype=np.int16)

    uniform_x = is_uniform_grid(xg_c)
    uniform_y = is_uniform_grid(yg_c)
    uniform_z = is_uniform_grid(zg_c)

    inv_dx = _inv_spacing(xg_c, dtype) if uniform_x else dtype.type(0.0)
    inv_dy = _inv_spacing(yg_c, dtype) if uniform_y else dtype.type(0.0)
    inv_dz = _inv_spacing(zg_c, dtype) if uniform_z else dtype.type(0.0)

    _sample_scalar_all_parallel(scalar_c,
                                xg_c, yg_c, zg_c,
                                xfl, yfl, zfl,
                                values_all, codes_all,
                                periodic_x, periodic_y, periodic_z,
                                uniform_x, uniform_y, uniform_z,
                                inv_dx, inv_dy, inv_dz,
                                dtype.type(bad_value))

    return ScalarSampleResult(
        values_all=values_all,
        line_start=result.line_start,
        line_count=result.line_count,
        codes_all=codes_all,
    )


def sample_ragged_to_padded(
    sample: ScalarSampleResult,
    *,
    fill_value: float = np.nan,
    return_codes: bool = False,
):
    """
    Convert a ScalarSampleResult from ragged format to a padded matrix.

    Parameters
    ----------
    sample : ScalarSampleResult
        Output from sample_scalar_on_lines.
    fill_value : float
        Fill value for missing points.
    return_codes : bool
        If True, also return padded sampling-code matrix.

    Returns
    -------
    values_mat : ndarray
        Shape (nlines, max_points), filled with fill_value.
    codes_mat : ndarray, optional
        Shape (nlines, max_points), filled with -1 where no point exists.
    """

    nlines = sample.line_count.size
    max_points = int(sample.line_count.max()) if nlines > 0 else 0

    values_mat = np.full(
        (nlines, max_points),
        fill_value,
        dtype=sample.values_all.dtype,
    )

    if return_codes:
        codes_mat = np.full(
            (nlines, max_points),
            -1,
            dtype=sample.codes_all.dtype,
        )

    for i in range(nlines):
        i0 = int(sample.line_start[i])
        n = int(sample.line_count[i])
        i1 = i0 + n

        values_mat[i, :n] = sample.values_all[i0:i1]

        if return_codes:
            codes_mat[i, :n] = sample.codes_all[i0:i1]

    if return_codes:
        return values_mat, codes_mat

    return values_mat

@njit(cache=True, fastmath=True)
def _wrap_coord(q, qmin, qmax):
    L = qmax - qmin
    if L <= 0.0:
        return q
    while q < qmin:
        q += L
    while q > qmax:
        q -= L
    return q


@njit(cache=True, fastmath=True)
def _exit_code_for_coord(q, qmin, qmax, periodic, offset):
    if periodic:
        return 0
    if q < qmin:
        return offset + 1
    if q > qmax:
        return offset + 2
    return 0

@njit(cache=True, fastmath=True)
def _find_index_1d(grid, q, is_uniform, inv_d):
    """
    Return lower index i such that grid[i] <= q <= grid[i+1].
    Supports both uniform and nonuniform grids.
    """
    n = grid.size

    if n < 2:
        return -1

    if q < grid[0] or q > grid[n - 1]:
        return -1

    if q == grid[n - 1]:
        return n - 2

    if is_uniform:
        i = int((q - grid[0]) * inv_d)
        if i < 0:
            i = 0
        if i > n - 2:
            i = n - 2
        return i

    i = np.searchsorted(grid, q) - 1

    if i < 0:
        i = 0
    if i > n - 2:
        i = n - 2

    return i


@njit(cache=True, fastmath=True)
def _interp_scalar_sampling(
    A,
    xgrid, ygrid, zgrid,
    x, y, z,
    periodic_x, periodic_y, periodic_z,
    uniform_x, uniform_y, uniform_z,
    inv_dx, inv_dy, inv_dz,
):
    """
    Trilinear interpolation of a scalar A[iz, iy, ix].

    Returns
    -------
    value, ok, code
    """
    xmin = xgrid[0]
    xmax = xgrid[xgrid.size - 1]
    ymin = ygrid[0]
    ymax = ygrid[ygrid.size - 1]
    zmin = zgrid[0]
    zmax = zgrid[zgrid.size - 1]

    # ------------------------------------------------------------
    # Boundary handling / wrapping
    # ------------------------------------------------------------
    if periodic_x:
        x = _wrap_coord(x, xmin, xmax)
    else:
        code = _exit_code_for_coord(x, xmin, xmax, False, 4)
        if code != 0:
            return 0.0, False, code

    if periodic_y:
        y = _wrap_coord(y, ymin, ymax)
    else:
        code = _exit_code_for_coord(y, ymin, ymax, False, 2)
        if code != 0:
            return 0.0, False, code

    if periodic_z:
        z = _wrap_coord(z, zmin, zmax)
    else:
        code = _exit_code_for_coord(z, zmin, zmax, False, 0)
        if code != 0:
            return 0.0, False, code

    # ------------------------------------------------------------
    # Cell indices
    # ------------------------------------------------------------
    ix = _find_index_1d(xgrid, x, uniform_x, inv_dx)
    iy = _find_index_1d(ygrid, y, uniform_y, inv_dy)
    iz = _find_index_1d(zgrid, z, uniform_z, inv_dz)

    if ix < 0 or iy < 0 or iz < 0:
        return 0.0, False, EXIT_INTERP_ERROR

    # ------------------------------------------------------------
    # Weights
    # ------------------------------------------------------------
    x0 = xgrid[ix]
    x1 = xgrid[ix + 1]
    y0 = ygrid[iy]
    y1 = ygrid[iy + 1]
    z0 = zgrid[iz]
    z1 = zgrid[iz + 1]

    tx = (x - x0) / (x1 - x0)
    ty = (y - y0) / (y1 - y0)
    tz = (z - z0) / (z1 - z0)

    wx0 = 1.0 - tx
    wx1 = tx
    wy0 = 1.0 - ty
    wy1 = ty
    wz0 = 1.0 - tz
    wz1 = tz

    w000 = wz0 * wy0 * wx0
    w001 = wz0 * wy0 * wx1
    w010 = wz0 * wy1 * wx0
    w011 = wz0 * wy1 * wx1
    w100 = wz1 * wy0 * wx0
    w101 = wz1 * wy0 * wx1
    w110 = wz1 * wy1 * wx0
    w111 = wz1 * wy1 * wx1

    val = (
        A[iz,     iy,     ix    ] * w000 +
        A[iz,     iy,     ix + 1] * w001 +
        A[iz,     iy + 1, ix    ] * w010 +
        A[iz,     iy + 1, ix + 1] * w011 +
        A[iz + 1, iy,     ix    ] * w100 +
        A[iz + 1, iy,     ix + 1] * w101 +
        A[iz + 1, iy + 1, ix    ] * w110 +
        A[iz + 1, iy + 1, ix + 1] * w111
    )

    if not np.isfinite(val):
        return 0.0, False, EXIT_NAN

    return val, True, 0


@njit(parallel=True, cache=True, fastmath=True)
def _sample_scalar_all_parallel(
    scalar,
    xgrid, ygrid, zgrid,
    xfl, yfl, zfl,
    values_all, codes_all,
    periodic_x, periodic_y, periodic_z,
    uniform_x, uniform_y, uniform_z,
    inv_dx, inv_dy, inv_dz,
    bad_value,
):
    n = xfl.size

    for i in prange(n):
        val, ok, code = _interp_scalar_sampling(
            scalar,
            xgrid, ygrid, zgrid,
            xfl[i], yfl[i], zfl[i],
            periodic_x, periodic_y, periodic_z,
            uniform_x, uniform_y, uniform_z,
            inv_dx, inv_dy, inv_dz,
        )

        if ok:
            values_all[i] = val
            codes_all[i] = 0
        else:
            values_all[i] = bad_value
            codes_all[i] = code

