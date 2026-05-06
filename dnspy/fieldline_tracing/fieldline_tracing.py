"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fieldline_tracing.py

Developed by Daniel Nobrega-Siverio assisted by ChatGPT 5.5.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The package has three main routines:

1) trace_field_lines:
   Numba-accelerated field-line tracing on a 3D Cartesian grid.
   The tracing is computed with a fixed-step RK2.
   The integration is both backwards and forwards from the starting point.

2) save_trace_npz
   To save the results as npz.
   Future implementations could use other formats.

3) ragged_to_padded
   To change the format of the result from ragged (1D array, all the lines are concatenated)
   to padded (2D array, filling with np.nan)


-----------------------------------------------------------------------------------------------
  How to use them?
-----------------------------------------------------------------------------------------------
  from fieldline_tracing import trace_field_lines, save_trace_npz, ragged_to_padded

  result = trace_field_lines(
                             bx, by, bz,
                             xgrid, ygrid, zgrid,
                             seeds,
                             ds=0.01,
                             max_steps=20000,
                             save_stride=1,
                             periodic_x=True,
                             periodic_y=True,
                             periodic_z=False,
                             bmin=1e-12,
                             dtype=np.float32)


  save_trace_npz("fieldlines.npz", result)

  xfl, yfl, zfl, sfl = ragged_to_padded(result) # If needed

  xline, yline, zline, sline = result.get_line(2) # To get line number 2, for instance.

-----------------------------------------------------------------------------------------------
  Inputs
-----------------------------------------------------------------------------------------------
- bx,by,bz (float):  Magnetic field 3D arrays with shape (nz, ny, nx).
- ds (float):        Fixed arglength for the integration, in the same units as the grid.
- xgrid,
  ygrid,
  zgrid (float):     1D coordinate arrays, in the same units as ds, e.g. Mm.
- seeds (float):     Starting points for the tracing. 
                     It has shape (nseeds, 3), with columns (x0, y0, z0).
- max_steps (int):   Maximum number of steps for the integration
- save_stride (int): Save position of the line each save_stride*ds. 
                     For instance, if save_stride = 5, then the line is stored every 5*ds.
                     (Default is 1. User should check accuracy vs storage).
- periodic_x (bool): True by default (Bifrost has horizontal periodic boundaries).
- periodic_y (bool): True by default (Bifrost has horizontal periodic boundaries).
- periodic_z (bool): False by default.
- bmin (float):      Threshold to compute the line (1.0e-12 by default).
                     Future implementations will manage the behaviour near nulls.  
- dtype(np.float32): To optimize numba calculation, all the floats have to be of the same type. 
                     User should test whether double precision is needed. 

-----------------------------------------------------------------------------------------------
  Outputs
-----------------------------------------------------------------------------------------------
  The ouput arrays are ragged, meaning that all the lines are concatenated.
- xfl, yfl, zfl: Lines coordinates (x, y, z) stored in ragged format.
- sfl: total length of the line (sum of ds) stored in ragged format.
- line_start: Index where a new line beings.
- line_count: Number of points of such line.

- Each complete line is ordered as:
      minus endpoint -> ... -> seed -> ... -> plus endpoint
- For a padded result, use 
  xfl, yfl, zfl, sfl = ragged_to_padded(result)

-----------------------------------------------------------------------------------------------
  Exit codes
-----------------------------------------------------------------------------------------------
  The sign encodes the branch:
    positive = plus direction, negative = minus direction.

  Absolute value:
    1 = ended at zmin
    2 = ended at zmax
    3 = ended at ymin
    4 = ended at ymax
    5 = ended at xmin
    6 = ended at xmax
    7 = reached max_steps
    8 = |B| too small
    9 = NaN/Inf encountered
   10 = interpolation/domain error

-----------------------------------------------------------------------------------------------
  Version notes
-----------------------------------------------------------------------------------------------
- 1.0 (2026-05-06). First release :)

"""

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
class TraceResult:
    xfl: np.ndarray
    yfl: np.ndarray
    zfl: np.ndarray
    sfl: np.ndarray
    line_start: np.ndarray
    line_count: np.ndarray
    seeds: np.ndarray
    exit_code_minus: np.ndarray
    exit_code_plus: np.ndarray
    nsteps_minus: np.ndarray
    nsteps_plus: np.ndarray
    length_minus: np.ndarray
    length_plus: np.ndarray
    seed_index: np.ndarray

    @property
    def nlines(self) -> int:
        # Number of lines
        return int(self.line_count.size)

    @property
    def total_points(self) -> int:
        # Number of points
        return int(self.xfl.size)

    def get_line(self, i: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        # Function to get the coordinates of the line number #i
        i0 = int(self.line_start[i])
        i1 = i0 + int(self.line_count[i])
        return self.xfl[i0:i1], self.yfl[i0:i1], self.zfl[i0:i1], self.sfl[i0:i1]


def validate_inputs(bx, by, bz, xgrid, ygrid, zgrid, seeds) -> None:
    # Verifications of shapes just in case the user messes it up with the input arrays
    if bx.shape != by.shape or bx.shape != bz.shape:
        raise ValueError("bx, by, bz must have identical shape (nz, ny, nx).")
    if bx.ndim != 3:
        raise ValueError("bx, by, bz must be 3D arrays with shape (nz, ny, nx).")
    nz, ny, nx = bx.shape
    if xgrid.ndim != 1 or ygrid.ndim != 1 or zgrid.ndim != 1:
        raise ValueError("xgrid, ygrid, zgrid must be 1D arrays.")
    if len(xgrid) != nx or len(ygrid) != ny or len(zgrid) != nz:
        raise ValueError(
            "Grid lengths do not match field shape: "
            f"field=(nz={nz}, ny={ny}, nx={nx}), "
            f"len(zgrid)={len(zgrid)}, len(ygrid)={len(ygrid)}, len(xgrid)={len(xgrid)}."
        )
    if seeds.ndim != 2 or seeds.shape[1] != 3:
        raise ValueError("seeds must have shape (nseeds, 3), columns (x0, y0, z0).")
    for name, grid in (("xgrid", xgrid), ("ygrid", ygrid), ("zgrid", zgrid)):
        if not np.all(np.isfinite(grid)):
            raise ValueError(f"{name} contains NaN/Inf.")
        if not np.all(np.diff(grid) > 0):
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
        
def trace_field_lines(
    bx: np.ndarray,
    by: np.ndarray,
    bz: np.ndarray,
    xgrid: np.ndarray,
    ygrid: np.ndarray,
    zgrid: np.ndarray,
    seeds: np.ndarray,
    ds: float,
    max_steps: int,
    *,
    save_stride: int = 1,
    periodic_x: bool = True,
    periodic_y: bool = True,
    periodic_z: bool = False,
    bmin: float = 1.0e-12,
    dtype=np.float32,
) -> TraceResult:
    """Trace field lines using fixed-step RK2 and return ragged lines."""
    if ds <= 0:
        raise ValueError("ds must be positive.")
    if max_steps <= 0:
        raise ValueError("max_steps must be positive.")
    if save_stride <= 0:
        raise ValueError("save_stride must be positive.")

    dtype = np.dtype(dtype)
    validate_inputs(bx, by, bz, xgrid, ygrid, zgrid, seeds)

    # Tricks for speed optimization
    bx    = np.ascontiguousarray(bx, dtype=dtype)
    by    = np.ascontiguousarray(by, dtype=dtype)
    bz    = np.ascontiguousarray(bz, dtype=dtype)
    xgrid = np.ascontiguousarray(xgrid, dtype=dtype)
    ygrid = np.ascontiguousarray(ygrid, dtype=dtype)
    zgrid = np.ascontiguousarray(zgrid, dtype=dtype)
    seeds = np.ascontiguousarray(seeds, dtype=dtype)

    # Checking whether the mesh is uniform, to enhance the performance
    uniform_x = is_uniform_grid(xgrid)
    uniform_y = is_uniform_grid(ygrid)
    uniform_z = is_uniform_grid(zgrid)
    inv_dx    = _inv_spacing(xgrid, dtype) if uniform_x else dtype.type(0.0)
    inv_dy    = _inv_spacing(ygrid, dtype) if uniform_y else dtype.type(0.0)
    inv_dz    = _inv_spacing(zgrid, dtype) if uniform_z else dtype.type(0.0)
    
    # Initialization of variables
    nseeds       = seeds.shape[0]
    count_minus  = np.empty(nseeds, dtype=np.int64)
    count_plus   = np.empty(nseeds, dtype=np.int64)
    exit_minus   = np.empty(nseeds, dtype=np.int16)
    exit_plus    = np.empty(nseeds, dtype=np.int16)
    nsteps_minus = np.empty(nseeds, dtype=np.int32)
    nsteps_plus  = np.empty(nseeds, dtype=np.int32)
    length_minus = np.empty(nseeds, dtype=dtype)
    length_plus  = np.empty(nseeds, dtype=dtype)

    count_func = _count_all_parallel 
    count_func(
        bx, by, bz, xgrid, ygrid, zgrid, seeds,
        dtype.type(ds), int(max_steps), int(save_stride),
        bool(periodic_x), bool(periodic_y), bool(periodic_z), dtype.type(bmin),
        bool(uniform_x), bool(uniform_y), bool(uniform_z),
        dtype.type(inv_dx), dtype.type(inv_dy), dtype.type(inv_dz),
        count_minus, count_plus, exit_minus, exit_plus,
        nsteps_minus, nsteps_plus, length_minus, length_plus,
    )

    line_count = count_minus + 1 + count_plus
    line_start = np.empty(nseeds, dtype=np.int64)
    if nseeds > 0:
        line_start[0] = 0
        if nseeds > 1:
            line_start[1:] = np.cumsum(line_count[:-1], dtype=np.int64)
    total = int(np.sum(line_count, dtype=np.int64))

    xfl = np.empty(total, dtype=dtype)
    yfl = np.empty(total, dtype=dtype)
    zfl = np.empty(total, dtype=dtype)
    sfl = np.empty(total, dtype=dtype)
    seed_index = np.empty(nseeds, dtype=np.int64)

    fill_func = _fill_all_parallel 
    fill_func(
        bx, by, bz, xgrid, ygrid, zgrid, seeds,
        dtype.type(ds), int(max_steps), int(save_stride),
        bool(periodic_x), bool(periodic_y), bool(periodic_z), dtype.type(bmin),
        bool(uniform_x), bool(uniform_y), bool(uniform_z),
        dtype.type(inv_dx), dtype.type(inv_dy), dtype.type(inv_dz),
        line_start, count_minus, count_plus,
        xfl, yfl, zfl, sfl, seed_index,
    )

    return TraceResult(
        xfl=xfl, yfl=yfl, zfl=zfl, sfl=sfl,
        line_start=line_start, line_count=line_count.astype(np.int64), seeds=seeds,
        exit_code_minus=exit_minus, exit_code_plus=exit_plus,
        nsteps_minus=nsteps_minus, nsteps_plus=nsteps_plus,
        length_minus=length_minus, length_plus=length_plus,
        seed_index=seed_index,
    )


def ragged_to_padded(result: TraceResult, fill_value=np.nan):
    """Convert ragged lines to padded matrices with shape (nlines, max_points)."""
    nlines = result.nlines
    max_points = int(result.line_count.max()) if nlines else 0
    dtype = result.xfl.dtype
    xmat = np.full((nlines, max_points), fill_value, dtype=dtype)
    ymat = np.full((nlines, max_points), fill_value, dtype=dtype)
    zmat = np.full((nlines, max_points), fill_value, dtype=dtype)
    smat = np.full((nlines, max_points), fill_value, dtype=dtype)
    for i in range(nlines):
        i0 = int(result.line_start[i])
        n = int(result.line_count[i])
        i1 = i0 + n
        xmat[i, :n] = result.xfl[i0:i1]
        ymat[i, :n] = result.yfl[i0:i1]
        zmat[i, :n] = result.zfl[i0:i1]
        smat[i, :n] = result.sfl[i0:i1]
    return xmat, ymat, zmat, smat


def save_trace_npz(filename: str, result: TraceResult, *, compressed: bool = True) -> None:
    saver = np.savez_compressed if compressed else np.savez
    saver(
        filename,
        xfl=result.xfl, yfl=result.yfl, zfl=result.zfl, sfl=result.sfl,
        line_start=result.line_start, line_count=result.line_count, seeds=result.seeds,
        exit_code_minus=result.exit_code_minus, exit_code_plus=result.exit_code_plus,
        nsteps_minus=result.nsteps_minus, nsteps_plus=result.nsteps_plus,
        length_minus=result.length_minus, length_plus=result.length_plus,
        seed_index=result.seed_index,
    )


def load_trace_npz(filename: str) -> TraceResult:
    data = np.load(filename)
    return TraceResult(
        xfl=data["xfl"], yfl=data["yfl"], zfl=data["zfl"], sfl=data["sfl"],
        line_start=data["line_start"], line_count=data["line_count"], seeds=data["seeds"],
        exit_code_minus=data["exit_code_minus"], exit_code_plus=data["exit_code_plus"],
        nsteps_minus=data["nsteps_minus"], nsteps_plus=data["nsteps_plus"],
        length_minus=data["length_minus"], length_plus=data["length_plus"],
        seed_index=data["seed_index"],
    )


def print_exit_summary(result: TraceResult) -> None:
    for name, arr in (("exit_code_minus", result.exit_code_minus), ("exit_code_plus", result.exit_code_plus)):
        vals, counts = np.unique(arr, return_counts=True)
        print(name)
        for v, c in zip(vals, counts):
            print(f"  {int(v):4d}: {int(c)}")


def exit_code_meaning(code: int) -> str:
    branch = "plus" if code > 0 else "minus"
    meanings = {
        EXIT_ZMIN: "ended at zmin",
        EXIT_ZMAX: "ended at zmax",
        EXIT_YMIN: "ended at ymin",
        EXIT_YMAX: "ended at ymax",
        EXIT_XMIN: "ended at xmin",
        EXIT_XMAX: "ended at xmax",
        EXIT_MAX_STEPS: "reached max_steps",
        EXIT_BNORM_TOO_SMALL: "|B| too small",
        EXIT_NAN: "NaN/Inf encountered",
        EXIT_INTERP_ERROR: "interpolation/domain error",
    }
    return f"{branch}: {meanings.get(abs(int(code)), 'unknown')}"


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
    n = grid.size
    if n < 2:
        return -1
    qmin = grid[0]
    qmax = grid[n - 1]
    if q < qmin or q > qmax:
        return -1
    if q == qmax:
        return n - 2
    if is_uniform:
        i = int((q - qmin) * inv_d)
    else:
        i = np.searchsorted(grid, q) - 1
    if i < 0:
        i = 0
    if i > n - 2:
        i = n - 2
    return i


@njit(cache=True, fastmath=True)
def _interp_B(bx, by, bz, xgrid, ygrid, zgrid, x, y, z,
              periodic_x, periodic_y, periodic_z,
              uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz):
    """
    Trilinear interpolation of B = (bx, by, bz) on arrays with shape
    (nz, ny, nx).

    This version computes indices and interpolation weights only once,
    then applies them to bx, by, bz.
    
    Returns
    -------
    bx0, by0, bz0, ok, exit_code_abs
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
            return 0.0, 0.0, 0.0, False, code

    if periodic_y:
        y = _wrap_coord(y, ymin, ymax)
    else:
        code = _exit_code_for_coord(y, ymin, ymax, False, 2)
        if code != 0:
            return 0.0, 0.0, 0.0, False, code

    if periodic_z:
        z = _wrap_coord(z, zmin, zmax)
    else:
        code = _exit_code_for_coord(z, zmin, zmax, False, 0)
        if code != 0:
            return 0.0, 0.0, 0.0, False, code

    # ------------------------------------------------------------
    # Cell indices
    # ------------------------------------------------------------
    ix = _find_index_1d(xgrid, x, uniform_x, inv_dx)
    iy = _find_index_1d(ygrid, y, uniform_y, inv_dy)
    iz = _find_index_1d(zgrid, z, uniform_z, inv_dz)
    if ix < 0 or iy < 0 or iz < 0:
        return 0.0, 0.0, 0.0, False, EXIT_INTERP_ERROR


    # ------------------------------------------------------------
    # Interpolation weights
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

    # Combined trilinear weights
    w000 = wz0 * wy0 * wx0
    w001 = wz0 * wy0 * wx1
    w010 = wz0 * wy1 * wx0
    w011 = wz0 * wy1 * wx1
    w100 = wz1 * wy0 * wx0
    w101 = wz1 * wy0 * wx1
    w110 = wz1 * wy1 * wx0
    w111 = wz1 * wy1 * wx1

    # ------------------------------------------------------------
    # Interpolate bx
    # ------------------------------------------------------------
    bx0 = (
        bx[iz,     iy,     ix    ] * w000 +
        bx[iz,     iy,     ix + 1] * w001 +
        bx[iz,     iy + 1, ix    ] * w010 +
        bx[iz,     iy + 1, ix + 1] * w011 +
        bx[iz + 1, iy,     ix    ] * w100 +
        bx[iz + 1, iy,     ix + 1] * w101 +
        bx[iz + 1, iy + 1, ix    ] * w110 +
        bx[iz + 1, iy + 1, ix + 1] * w111
    )

    # ------------------------------------------------------------
    # Interpolate by
    # ------------------------------------------------------------
    by0 = (
        by[iz,     iy,     ix    ] * w000 +
        by[iz,     iy,     ix + 1] * w001 +
        by[iz,     iy + 1, ix    ] * w010 +
        by[iz,     iy + 1, ix + 1] * w011 +
        by[iz + 1, iy,     ix    ] * w100 +
        by[iz + 1, iy,     ix + 1] * w101 +
        by[iz + 1, iy + 1, ix    ] * w110 +
        by[iz + 1, iy + 1, ix + 1] * w111
    )

    # ------------------------------------------------------------
    # Interpolate bz
    # ------------------------------------------------------------
    bz0 = (
        bz[iz,     iy,     ix    ] * w000 +
        bz[iz,     iy,     ix + 1] * w001 +
        bz[iz,     iy + 1, ix    ] * w010 +
        bz[iz,     iy + 1, ix + 1] * w011 +
        bz[iz + 1, iy,     ix    ] * w100 +
        bz[iz + 1, iy,     ix + 1] * w101 +
        bz[iz + 1, iy + 1, ix    ] * w110 +
        bz[iz + 1, iy + 1, ix + 1] * w111
    )

    if not (np.isfinite(bx0) and np.isfinite(by0) and np.isfinite(bz0)):
        return 0.0, 0.0, 0.0, False, EXIT_NAN

    return bx0, by0, bz0, True, 0


@njit(cache=True, fastmath=True)
def _unit_B_at(bx, by, bz, xgrid, ygrid, zgrid, x, y, z,
               periodic_x, periodic_y, periodic_z, bmin,
               uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz):
    b0x, b0y, b0z, ok, code = _interp_B(
        bx, by, bz, xgrid, ygrid, zgrid, x, y, z,
        periodic_x, periodic_y, periodic_z,
        uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz)
    if not ok:
        return 0.0, 0.0, 0.0, False, code
    bnorm = np.sqrt(b0x*b0x + b0y*b0y + b0z*b0z)
    if not np.isfinite(bnorm):
        return 0.0, 0.0, 0.0, False, EXIT_NAN
    if bnorm <= bmin:
        return 0.0, 0.0, 0.0, False, EXIT_BNORM_TOO_SMALL
    return b0x / bnorm, b0y / bnorm, b0z / bnorm, True, 0


@njit(cache=True, fastmath=True)
def _wrap_xyz(x, y, z, xgrid, ygrid, zgrid, periodic_x, periodic_y, periodic_z):
    if periodic_x:
        x = _wrap_coord(x, xgrid[0], xgrid[xgrid.size - 1])
    if periodic_y:
        y = _wrap_coord(y, ygrid[0], ygrid[ygrid.size - 1])
    if periodic_z:
        z = _wrap_coord(z, zgrid[0], zgrid[zgrid.size - 1])
    return x, y, z


@njit(cache=True, fastmath=True)
def _rk2_step(bx, by, bz, xgrid, ygrid, zgrid, x, y, z, ds_signed,
              periodic_x, periodic_y, periodic_z, bmin,
              uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz):
    ux, uy, uz, ok, code = _unit_B_at(
        bx, by, bz, xgrid, ygrid, zgrid, x, y, z,
        periodic_x, periodic_y, periodic_z, bmin,
        uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz)
    if not ok:
        return x, y, z, False, code

    xmid = x + 0.5 * ds_signed * ux
    ymid = y + 0.5 * ds_signed * uy
    zmid = z + 0.5 * ds_signed * uz
    xmid, ymid, zmid = _wrap_xyz(xmid, ymid, zmid, xgrid, ygrid, zgrid, periodic_x, periodic_y, periodic_z)

    ux2, uy2, uz2, ok, code = _unit_B_at(
        bx, by, bz, xgrid, ygrid, zgrid, xmid, ymid, zmid,
        periodic_x, periodic_y, periodic_z, bmin,
        uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz)
    if not ok:
        return x, y, z, False, code

    xnew = x + ds_signed * ux2
    ynew = y + ds_signed * uy2
    znew = z + ds_signed * uz2
    xnew, ynew, znew = _wrap_xyz(xnew, ynew, znew, xgrid, ygrid, zgrid, periodic_x, periodic_y, periodic_z)

    code = _exit_code_for_coord(znew, zgrid[0], zgrid[zgrid.size - 1], periodic_z, 0)
    if code != 0:
        return x, y, z, False, code
    code = _exit_code_for_coord(ynew, ygrid[0], ygrid[ygrid.size - 1], periodic_y, 2)
    if code != 0:
        return x, y, z, False, code
    code = _exit_code_for_coord(xnew, xgrid[0], xgrid[xgrid.size - 1], periodic_x, 4)
    if code != 0:
        return x, y, z, False, code
    if not (np.isfinite(xnew) and np.isfinite(ynew) and np.isfinite(znew)):
        return x, y, z, False, EXIT_NAN
    return xnew, ynew, znew, True, 0


@njit(cache=True, fastmath=True)
def _count_branch(bx, by, bz, xgrid, ygrid, zgrid, x0, y0, z0, ds, max_steps, save_stride, sign,
                  periodic_x, periodic_y, periodic_z, bmin,
                  uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz):
    x, y, z = x0, y0, z0
    ds_signed = ds * sign
    count = 0
    last_saved = 0
    nsteps = 0
    length = 0.0
    exit_code = EXIT_MAX_STEPS
    for step in range(1, max_steps + 1):
        xn, yn, zn, ok, code = _rk2_step(
            bx, by, bz, xgrid, ygrid, zgrid, x, y, z, ds_signed,
            periodic_x, periodic_y, periodic_z, bmin,
            uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
        )
        if not ok:
            exit_code = code
            break
        x, y, z = xn, yn, zn
        nsteps = step
        length = step * ds
        if step % save_stride == 0:
            count += 1
            last_saved = step
    else:
        exit_code = EXIT_MAX_STEPS
    if nsteps > 0 and last_saved != nsteps:
        count += 1
    return count, exit_code, nsteps, length


@njit(cache=True, fastmath=True)
def _fill_branch_forward(bx, by, bz, xgrid, ygrid, zgrid, x0, y0, z0, ds, max_steps, save_stride, sign,
                         periodic_x, periodic_y, periodic_z, bmin,
                         uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
                         xt, yt, zt, st):
    x, y, z = x0, y0, z0
    ds_signed = ds * sign
    nsave = 0
    last_saved = 0
    nsteps = 0
    for step in range(1, max_steps + 1):
        xn, yn, zn, ok, code = _rk2_step(
            bx, by, bz, xgrid, ygrid, zgrid, x, y, z, ds_signed,
            periodic_x, periodic_y, periodic_z, bmin,
            uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
        )
        if not ok:
            break
        x, y, z = xn, yn, zn
        nsteps = step
        if step % save_stride == 0:
            xt[nsave] = x
            yt[nsave] = y
            zt[nsave] = z
            st[nsave] = step * ds
            nsave += 1
            last_saved = step
    if nsteps > 0 and last_saved != nsteps:
        xt[nsave] = x
        yt[nsave] = y
        zt[nsave] = z
        st[nsave] = nsteps * ds
        nsave += 1
    return nsave


@njit(parallel=True, cache=True, fastmath=True)
def _count_all_parallel(bx, by, bz, xgrid, ygrid, zgrid, seeds, ds, max_steps, save_stride,
                        periodic_x, periodic_y, periodic_z, bmin,
                        uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
                        count_minus, count_plus, exit_minus, exit_plus, nsteps_minus, nsteps_plus, length_minus, length_plus):
    for i in prange(seeds.shape[0]):
        x0, y0, z0 = seeds[i, 0], seeds[i, 1], seeds[i, 2]
        cm, codem, nsm, lm = _count_branch(bx, by, bz, xgrid, ygrid, zgrid, x0, y0, z0, ds,
                                           max_steps, save_stride, -1.0,
                                           periodic_x, periodic_y, periodic_z, bmin,
                                           uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz)
        cp, codep, nsp, lp = _count_branch(bx, by, bz, xgrid, ygrid, zgrid, x0, y0, z0, ds,
                                           max_steps, save_stride,  1.0,
                                           periodic_x, periodic_y, periodic_z, bmin,
                                           uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz)
        count_minus[i] = cm
        count_plus[i] = cp
        exit_minus[i] = -codem
        exit_plus[i] = codep
        nsteps_minus[i] = nsm
        nsteps_plus[i] = nsp
        length_minus[i] = lm
        length_plus[i] = lp

@njit(parallel=True, cache=True, fastmath=True)
def _fill_all_parallel(bx, by, bz, xgrid, ygrid, zgrid, seeds, ds, max_steps, save_stride,
                       periodic_x, periodic_y, periodic_z, bmin,
                       uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
                       line_start, count_minus, count_plus, xfl, yfl, zfl, sfl, seed_index):
    for i in prange(seeds.shape[0]):
        _fill_one_line(i, bx, by, bz, xgrid, ygrid, zgrid, seeds, ds, max_steps, save_stride,
                       periodic_x, periodic_y, periodic_z, bmin,
                       uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
                       line_start, count_minus, count_plus, xfl, yfl, zfl, sfl, seed_index)

@njit(cache=True, fastmath=True)
def _fill_one_line(
    i, bx, by, bz, xgrid, ygrid, zgrid, seeds, ds, max_steps, save_stride,
    periodic_x, periodic_y, periodic_z, bmin,
    uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
    line_start, count_minus, count_plus, x_all, y_all, z_all, s_all, seed_index,
):
    """
    Fill one concatenated field line directly into the global ragged arrays,
    without allocating temporary arrays for the minus/plus branches.

    Final ordering:
        minus endpoint -> ... -> seed -> ... -> plus endpoint

    The seed is always stored at:
        seed_index[i] = line_start[i] + count_minus[i]
    """

    x0 = seeds[i, 0]
    y0 = seeds[i, 1]
    z0 = seeds[i, 2]

    cm = count_minus[i]
    cp = count_plus[i]

    start = line_start[i]
    seed_pos = start + cm
    seed_index[i] = seed_pos

    # ------------------------------------------------------------
    # Minus branch
    # ------------------------------------------------------------
    # We trace outward from the seed in the -B direction, but write
    # backwards so that the stored full line begins at the minus endpoint.
    #
    # During this first pass we temporarily store s as distance from seed.
    # Once the final minus length Lm is known, we convert it to:
    #     s = Lm - distance_from_seed
    # so that s=0 at the minus endpoint and s=Lm at the seed.
    # ------------------------------------------------------------
    x = x0
    y = y0
    z = z0

    ds_signed = -ds
    nsave = 0
    nsteps = 0
    last_saved_step = 0

    for step in range(1, max_steps + 1):
        xn, yn, zn, ok, code = _rk2_step(
            bx, by, bz, xgrid, ygrid, zgrid,
            x, y, z, ds_signed,
            periodic_x, periodic_y, periodic_z, bmin,
            uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
        )

        if not ok:
            break

        x = xn
        y = yn
        z = zn
        nsteps = step

        if step % save_stride == 0:
            idx = seed_pos - 1 - nsave
            x_all[idx] = x
            y_all[idx] = y
            z_all[idx] = z
            s_all[idx] = step * ds   # temporary: distance from seed
            nsave += 1
            last_saved_step = step

    # Always save final valid minus point if it was not saved by stride.
    if nsteps > 0 and last_saved_step != nsteps:
        idx = seed_pos - 1 - nsave
        x_all[idx] = x
        y_all[idx] = y
        z_all[idx] = z
        s_all[idx] = nsteps * ds     # temporary: distance from seed
        nsave += 1

    # Final minus branch length.
    Lm = nsteps * ds

    # Convert temporary minus s values into global s along the full line.
    # Stored range for minus branch is:
    #     start ... seed_pos-1
    for idx in range(start, seed_pos):
        s_all[idx] = Lm - s_all[idx]

    # ------------------------------------------------------------
    # Seed point
    # ------------------------------------------------------------
    x_all[seed_pos] = x0
    y_all[seed_pos] = y0
    z_all[seed_pos] = z0
    s_all[seed_pos] = Lm

    # ------------------------------------------------------------
    # Plus branch
    # ------------------------------------------------------------
    # Trace outward from the seed in the +B direction and write forward.
    # ------------------------------------------------------------
    x = x0
    y = y0
    z = z0

    ds_signed = ds
    nsave = 0
    nsteps = 0
    last_saved_step = 0

    for step in range(1, max_steps + 1):
        xn, yn, zn, ok, code = _rk2_step(
            bx, by, bz, xgrid, ygrid, zgrid,
            x, y, z, ds_signed,
            periodic_x, periodic_y, periodic_z, bmin,
            uniform_x, uniform_y, uniform_z, inv_dx, inv_dy, inv_dz,
        )

        if not ok:
            break

        x = xn
        y = yn
        z = zn
        nsteps = step

        if step % save_stride == 0:
            idx = seed_pos + 1 + nsave
            x_all[idx] = x
            y_all[idx] = y
            z_all[idx] = z
            s_all[idx] = Lm + step * ds
            nsave += 1
            last_saved_step = step

    # Always save final valid plus point if it was not saved by stride.
    if nsteps > 0 and last_saved_step != nsteps:
        idx = seed_pos + 1 + nsave
        x_all[idx] = x
        y_all[idx] = y
        z_all[idx] = z
        s_all[idx] = Lm + nsteps * ds
        nsave += 1
