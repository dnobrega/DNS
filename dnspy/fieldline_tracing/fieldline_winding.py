
from __future__ import annotations

from dataclasses import dataclass
import numpy as np
from numba import njit, prange


@dataclass
class LocalWindingResult:
    """Local pairwise winding diagnostics between neighboring field lines."""

    mean_wind: np.ndarray
    mean_abs_wind: np.ndarray
    max_abs_wind: np.ndarray
    std_wind: np.ndarray
    n_pairs: np.ndarray


def compute_local_winding(
    result,
    seed_shape,
    *,
    neighbor_offsets=((1, 0), (0, 1), (1, 1), (1, -1)),
    nsample=200,
    min_sep=1e-8,
    dtype=np.float32
):
    """
    Compute local pairwise winding between neighboring field lines.

    Parameters
    ----------
    result : TraceResult
        Output from trace_field_lines.
    seed_shape : tuple
        Shape of the original seed grid as (ny_seed, nx_seed).
        Assumes line index i = iy * nx_seed + ix.
    neighbor_offsets : sequence of tuple
        Neighbor offsets as (dy, dx). By default only forward-like
        neighbors are used to avoid double counting.
    nsample : int
        Number of samples in normalized arc-length coordinate u=s/L.
    min_sep : float
        Minimum allowed horizontal separation. If two sampled points are
        closer than this in x-y, that pair sample is skipped.
    dtype : np.dtype
        Output dtype.

    Returns
    -------
    LocalWindingResult

    Notes
    -----
    This is a practical local winding proxy, not the full Gauss linking
    integral. It is most meaningful when neighboring lines are stored with
    a consistent orientation and do not suffer large wrapped jumps across
    periodic boundaries.
    """

    dtype = np.dtype(dtype)

    ny_seed, nx_seed = seed_shape
    nlines = result.line_count.size

    if nlines != ny_seed * nx_seed:
        raise ValueError(
            f"seed_shape={seed_shape} implies {ny_seed*nx_seed} lines, "
            f"but result has {nlines} lines."
        )

    if nsample < 2:
        raise ValueError("nsample must be >= 2.")

    offsets = np.asarray(neighbor_offsets, dtype=np.int64)
    if offsets.ndim != 2 or offsets.shape[1] != 2:
        raise ValueError("neighbor_offsets must be a sequence of (dy, dx) pairs.")

    xfl = np.ascontiguousarray(result.xfl, dtype=dtype)
    yfl = np.ascontiguousarray(result.yfl, dtype=dtype)
    sfl = np.ascontiguousarray(result.sfl, dtype=dtype)
    line_start = np.ascontiguousarray(result.line_start, dtype=np.int64)
    line_count = np.ascontiguousarray(result.line_count, dtype=np.int64)

    mean_wind = np.empty(nlines, dtype=dtype)
    mean_abs_wind = np.empty(nlines, dtype=dtype)
    max_abs_wind = np.empty(nlines, dtype=dtype)
    std_wind = np.empty(nlines, dtype=dtype)
    n_pairs = np.empty(nlines, dtype=np.int32)

    _compute_local_winding_parallel(
            xfl,
            yfl,
            sfl,
            line_start,
            line_count,
            ny_seed,
            nx_seed,
            offsets,
            nsample,
            dtype.type(min_sep),
            mean_wind,
            mean_abs_wind,
            max_abs_wind,
            std_wind,
            n_pairs,
        )

    return LocalWindingResult(
        mean_wind=mean_wind,
        mean_abs_wind=mean_abs_wind,
        max_abs_wind=max_abs_wind,
        std_wind=std_wind,
        n_pairs=n_pairs,
    )


@njit(cache=True)
def _interp_line_xy_at_u(
    xfl,
    yfl,
    sfl,
    line_start,
    line_count,
    iline,
    u,
):
    """
    Interpolate x,y along one ragged line at normalized coordinate u=s/L.
    Assumes s is monotonic increasing along the stored line.
    """

    i0 = line_start[iline]
    n = line_count[iline]

    if n < 2:
        return 0.0, 0.0, False

    s_first = sfl[i0]
    s_last = sfl[i0 + n - 1]
    L = s_last - s_first

    if not np.isfinite(L) or L <= 0.0:
        return 0.0, 0.0, False

    starget = s_first + u * L

    if starget <= s_first:
        return xfl[i0], yfl[i0], True

    if starget >= s_last:
        return xfl[i0 + n - 1], yfl[i0 + n - 1], True

    # Since s is ordered, linear search is acceptable for modest nsample.
    # This avoids allocating any temporary arrays.
    for k in range(n - 1):
        idx0 = i0 + k
        idx1 = idx0 + 1

        s0 = sfl[idx0]
        s1 = sfl[idx1]

        if s0 <= starget <= s1:
            ds = s1 - s0
            if ds <= 0.0 or not np.isfinite(ds):
                return 0.0, 0.0, False

            t = (starget - s0) / ds

            x = xfl[idx0] * (1.0 - t) + xfl[idx1] * t
            y = yfl[idx0] * (1.0 - t) + yfl[idx1] * t

            if not np.isfinite(x) or not np.isfinite(y):
                return 0.0, 0.0, False

            return x, y, True

    return xfl[i0 + n - 1], yfl[i0 + n - 1], True


@njit(cache=True)
def _angle_diff(theta_new, theta_old):
    """
    Wrapped angular difference in [-pi, pi].
    """

    dtheta = theta_new - theta_old

    while dtheta > np.pi:
        dtheta -= 2.0 * np.pi

    while dtheta < -np.pi:
        dtheta += 2.0 * np.pi

    return dtheta


@njit(cache=True)
def _pairwise_winding_one_pair(
    xfl,
    yfl,
    sfl,
    line_start,
    line_count,
    iline,
    jline,
    nsample,
    min_sep,
):
    """
    Compute pairwise local winding between two field lines.

    Returns
    -------
    winding, ok
    """

    prev_theta = 0.0
    have_prev = False
    total_dtheta = 0.0
    valid_samples = 0

    for m in range(nsample):
        if nsample == 1:
            u = 0.0
        else:
            u = m / (nsample - 1.0)

        xi, yi, ok_i = _interp_line_xy_at_u(
            xfl, yfl, sfl, line_start, line_count, iline, u
        )

        xj, yj, ok_j = _interp_line_xy_at_u(
            xfl, yfl, sfl, line_start, line_count, jline, u
        )

        if not (ok_i and ok_j):
            continue

        dx = xj - xi
        dy = yj - yi
        sep2 = dx * dx + dy * dy

        if sep2 <= min_sep * min_sep:
            continue

        theta = np.arctan2(dy, dx)

        if have_prev:
            total_dtheta += _angle_diff(theta, prev_theta)

        prev_theta = theta
        have_prev = True
        valid_samples += 1

    if valid_samples < 2:
        return np.nan, False

    winding = total_dtheta / (2.0 * np.pi)

    if not np.isfinite(winding):
        return np.nan, False

    return winding, True


@njit(cache=True)
def _compute_local_winding_one_line(
    iline,
    xfl,
    yfl,
    sfl,
    line_start,
    line_count,
    ny_seed,
    nx_seed,
    offsets,
    nsample,
    min_sep,
    mean_wind,
    mean_abs_wind,
    max_abs_wind,
    std_wind,
    n_pairs,
):
    iy = iline // nx_seed
    ix = iline - iy * nx_seed

    count = 0
    sum_w = 0.0
    sum_w2 = 0.0
    sum_abs_w = 0.0
    max_abs = 0.0

    for io in range(offsets.shape[0]):
        dy = offsets[io, 0]
        dx = offsets[io, 1]

        jy = iy + dy
        jx = ix + dx

        if jy < 0 or jy >= ny_seed:
            continue

        if jx < 0 or jx >= nx_seed:
            continue

        jline = jy * nx_seed + jx

        w, ok = _pairwise_winding_one_pair(
            xfl,
            yfl,
            sfl,
            line_start,
            line_count,
            iline,
            jline,
            nsample,
            min_sep,
        )

        if not ok:
            continue

        aw = abs(w)

        sum_w += w
        sum_w2 += w * w
        sum_abs_w += aw

        if aw > max_abs:
            max_abs = aw

        count += 1

    if count == 0:
        mean_wind[iline] = np.nan
        mean_abs_wind[iline] = np.nan
        max_abs_wind[iline] = np.nan
        std_wind[iline] = np.nan
        n_pairs[iline] = 0
        return

    mean = sum_w / count
    var = sum_w2 / count - mean * mean

    if var < 0.0:
        var = 0.0

    mean_wind[iline] = mean
    mean_abs_wind[iline] = sum_abs_w / count
    max_abs_wind[iline] = max_abs
    std_wind[iline] = np.sqrt(var)
    n_pairs[iline] = count


@njit(parallel=True, cache=True, fastmath=True)
def _compute_local_winding_parallel(
    xfl,
    yfl,
    sfl,
    line_start,
    line_count,
    ny_seed,
    nx_seed,
    offsets,
    nsample,
    min_sep,
    mean_wind,
    mean_abs_wind,
    max_abs_wind,
    std_wind,
    n_pairs,
):
    nlines = line_count.size

    for iline in prange(nlines):
        _compute_local_winding_one_line(
            iline,
            xfl,
            yfl,
            sfl,
            line_start,
            line_count,
            ny_seed,
            nx_seed,
            offsets,
            nsample,
            min_sep,
            mean_wind,
            mean_abs_wind,
            max_abs_wind,
            std_wind,
            n_pairs,
        )


@njit(cache=True)
def _compute_local_winding_serial(
    xfl,
    yfl,
    sfl,
    line_start,
    line_count,
    ny_seed,
    nx_seed,
    offsets,
    nsample,
    min_sep,
    mean_wind,
    mean_abs_wind,
    max_abs_wind,
    std_wind,
    n_pairs,
):
    nlines = line_count.size

    for iline in range(nlines):
        _compute_local_winding_one_line(
            iline,
            xfl,
            yfl,
            sfl,
            line_start,
            line_count,
            ny_seed,
            nx_seed,
            offsets,
            nsample,
            min_sep,
            mean_wind,
            mean_abs_wind,
            max_abs_wind,
            std_wind,
            n_pairs,
        )
