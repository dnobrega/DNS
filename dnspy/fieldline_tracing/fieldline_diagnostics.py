# -------------------A------------------------------------------------
# Diagnostics for fieldlines
# ------------------------------------------------------------------- 
from __future__ import annotations

from dataclasses import dataclass
import numpy as np
from numba import njit, prange


@dataclass
class LineDiagnosticsResult:
    """Line-integrated diagnostics for one sampled scalar field."""

    integral: np.ndarray
    integral_abs: np.ndarray
    cancellation: np.ndarray
    mean: np.ndarray
    mean_abs: np.ndarray
    max_abs: np.ndarray
    s_at_max_abs: np.ndarray
    z_at_max_abs: np.ndarray
    s_centroid_abs: np.ndarray
    z_centroid_abs: np.ndarray
    s16_abs: np.ndarray
    s84_abs: np.ndarray
    W68_s_abs: np.ndarray


def compute_line_diagnostics(
    result,
    sample,
    *,
    dtype=np.float32,
    eps=1e-30,
    use_codes=True,
):
    """
    Compute diagnostics of a sampled scalar field along traced field lines.

    Parameters
    ----------
    result : TraceResult
        Output from trace_field_lines.
    sample : ScalarSampleResult
        Output from sample_scalar_on_lines.
    dtype : np.dtype
        Output dtype, usually np.float32 or np.float64.
    eps : float
        Small number to avoid division by zero.
    use_codes : bool
        If True, only sample points with sample.codes_all == 0 are used.

    Returns
    -------
    LineDiagnosticsResult

    Diagnostics
    -----------
    integral
        ∫ f dl

    integral_abs
        ∫ |f| dl

    cancellation
        |∫ f dl| / ∫ |f| dl

    mean
        ∫ f dl / L_valid

    mean_abs
        ∫ |f| dl / L_valid

    max_abs
        max |f| along the line

    s_at_max_abs, z_at_max_abs
        Position of max |f|.

    s_centroid_abs
        ∫ s |f| dl / ∫ |f| dl

    z_centroid_abs
        ∫ z |f| dl / ∫ |f| dl

    s16_abs, s84_abs, W68_s_abs
        Weighted percentiles in s using |f| dl as weight.
    """

    dtype = np.dtype(dtype)

    if not np.array_equal(result.line_start, sample.line_start):
        raise ValueError("result.line_start and sample.line_start do not match.")

    if not np.array_equal(result.line_count, sample.line_count):
        raise ValueError("result.line_count and sample.line_count do not match.")

    nlines = result.line_count.size

    integral = np.empty(nlines, dtype=dtype)
    integral_abs = np.empty(nlines, dtype=dtype)
    cancellation = np.empty(nlines, dtype=dtype)
    mean = np.empty(nlines, dtype=dtype)
    mean_abs = np.empty(nlines, dtype=dtype)
    max_abs = np.empty(nlines, dtype=dtype)
    s_at_max_abs = np.empty(nlines, dtype=dtype)
    z_at_max_abs = np.empty(nlines, dtype=dtype)
    s_centroid_abs = np.empty(nlines, dtype=dtype)
    z_centroid_abs = np.empty(nlines, dtype=dtype)
    s16_abs = np.empty(nlines, dtype=dtype)
    s84_abs = np.empty(nlines, dtype=dtype)
    W68_s_abs = np.empty(nlines, dtype=dtype)

    values_all = np.ascontiguousarray(sample.values_all, dtype=dtype)
    sfl = np.ascontiguousarray(result.sfl, dtype=dtype)
    zfl = np.ascontiguousarray(result.zfl, dtype=dtype)
    line_start = np.ascontiguousarray(result.line_start, dtype=np.int64)
    line_count = np.ascontiguousarray(result.line_count, dtype=np.int64)
    codes_all = np.ascontiguousarray(sample.codes_all, dtype=np.int16)


    _compute_line_diagnostics_parallel(
        values_all,
        sfl,
        zfl,
        line_start,
        line_count,
        codes_all,
        use_codes,
        dtype.type(eps),
        integral,
        integral_abs,
        cancellation,
        mean,
        mean_abs,
        max_abs,
        s_at_max_abs,
        z_at_max_abs,
        s_centroid_abs,
        z_centroid_abs,
        s16_abs,
        s84_abs,
        W68_s_abs,
        )

    return LineDiagnosticsResult(
        integral=integral,
        integral_abs=integral_abs,
        cancellation=cancellation,
        mean=mean,
        mean_abs=mean_abs,
        max_abs=max_abs,
        s_at_max_abs=s_at_max_abs,
        z_at_max_abs=z_at_max_abs,
        s_centroid_abs=s_centroid_abs,
        z_centroid_abs=z_centroid_abs,
        s16_abs=s16_abs,
        s84_abs=s84_abs,
        W68_s_abs=W68_s_abs,
    )


@njit(cache=True, fastmath=True)
def _point_is_valid(values_all, codes_all, use_codes, idx):
    if use_codes and codes_all[idx] != 0:
        return False

    v = values_all[idx]
    if not np.isfinite(v):
        return False

    return True


@njit(cache=True, fastmath=True)
def _point_abs_weight(
    values_all,
    sfl,
    codes_all,
    use_codes,
    i0,
    n,
    k,
):
    """
    Trapezoidal vertex weight for |f| dl at point k.

    The line segment contribution

        0.5 * (|f_i| + |f_{i+1}|) * ds

    is distributed onto the two vertices. Therefore each point gets

        |f_k| * 0.5 * (ds_left + ds_right)

    using only valid neighboring intervals.
    """

    idx = i0 + k

    if not _point_is_valid(values_all, codes_all, use_codes, idx):
        return 0.0

    f_abs = abs(values_all[idx])
    w = 0.0

    # Left interval: k-1 -> k
    if k > 0:
        idx_left = idx - 1
        if _point_is_valid(values_all, codes_all, use_codes, idx_left):
            ds_left = sfl[idx] - sfl[idx_left]
            if np.isfinite(ds_left) and ds_left > 0.0:
                w += 0.5 * ds_left * f_abs

    # Right interval: k -> k+1
    if k < n - 1:
        idx_right = idx + 1
        if _point_is_valid(values_all, codes_all, use_codes, idx_right):
            ds_right = sfl[idx_right] - sfl[idx]
            if np.isfinite(ds_right) and ds_right > 0.0:
                w += 0.5 * ds_right * f_abs

    return w


@njit(cache=True, fastmath=True)
def _weighted_s_percentile(
    values_all,
    sfl,
    codes_all,
    use_codes,
    i0,
    n,
    total_weight,
    percentile,
):
    """
    Weighted percentile in s using |f| dl as weight.

    Since sfl is already ordered along the line, no sorting is needed.
    This returns the first s where cumulative weight exceeds the target.
    """

    if total_weight <= 0.0 or not np.isfinite(total_weight):
        return np.nan

    target = percentile * total_weight
    cumulative = 0.0

    for k in range(n):
        w = _point_abs_weight(values_all, sfl, codes_all, use_codes, i0, n, k)

        if w <= 0.0:
            continue

        cumulative += w

        if cumulative >= target:
            return sfl[i0 + k]

    return sfl[i0 + n - 1]


@njit(cache=True, fastmath=True)
def _compute_one_line_diagnostics(
    iline,
    values_all,
    sfl,
    zfl,
    line_start,
    line_count,
    codes_all,
    use_codes,
    eps,
    integral,
    integral_abs,
    cancellation,
    mean,
    mean_abs,
    max_abs,
    s_at_max_abs,
    z_at_max_abs,
    s_centroid_abs,
    z_centroid_abs,
    s16_abs,
    s84_abs,
    W68_s_abs,
):
    i0 = line_start[iline]
    n = line_count[iline]

    nan = np.nan

    if n < 2:
        integral[iline] = nan
        integral_abs[iline] = nan
        cancellation[iline] = nan
        mean[iline] = nan
        mean_abs[iline] = nan
        max_abs[iline] = nan
        s_at_max_abs[iline] = nan
        z_at_max_abs[iline] = nan
        s_centroid_abs[iline] = nan
        z_centroid_abs[iline] = nan
        s16_abs[iline] = nan
        s84_abs[iline] = nan
        W68_s_abs[iline] = nan
        return

    I = 0.0
    Iabs = 0.0
    Lvalid = 0.0

    maxabs = -1.0
    smax = nan
    zmax = nan

    # Trapezoidal interval integrals.
    for k in range(n - 1):
        idx0 = i0 + k
        idx1 = idx0 + 1

        valid0 = _point_is_valid(values_all, codes_all, use_codes, idx0)
        valid1 = _point_is_valid(values_all, codes_all, use_codes, idx1)

        if not (valid0 and valid1):
            continue

        s0 = sfl[idx0]
        s1 = sfl[idx1]
        ds = s1 - s0

        if not np.isfinite(ds) or ds <= 0.0:
            continue

        f0 = values_all[idx0]
        f1 = values_all[idx1]

        I += 0.5 * (f0 + f1) * ds
        Iabs += 0.5 * (abs(f0) + abs(f1)) * ds
        Lvalid += ds

    # Point-based maximum and weighted centroids.
    numerator_s = 0.0
    numerator_z = 0.0

    for k in range(n):
        idx = i0 + k

        if _point_is_valid(values_all, codes_all, use_codes, idx):
            f_abs = abs(values_all[idx])

            if f_abs > maxabs:
                maxabs = f_abs
                smax = sfl[idx]
                zmax = zfl[idx]

        w = _point_abs_weight(values_all, sfl, codes_all, use_codes, i0, n, k)

        if w > 0.0:
            numerator_s += sfl[idx] * w
            numerator_z += zfl[idx] * w

    integral[iline] = I
    integral_abs[iline] = Iabs

    if Iabs > eps:
        cancellation[iline] = abs(I) / Iabs
        s_centroid_abs[iline] = numerator_s / Iabs
        z_centroid_abs[iline] = numerator_z / Iabs

        s16 = _weighted_s_percentile(
            values_all, sfl, codes_all, use_codes,
            i0, n, Iabs, 0.16,
        )
        s84 = _weighted_s_percentile(
            values_all, sfl, codes_all, use_codes,
            i0, n, Iabs, 0.84,
        )

        s16_abs[iline] = s16
        s84_abs[iline] = s84
        W68_s_abs[iline] = s84 - s16
    else:
        cancellation[iline] = nan
        s_centroid_abs[iline] = nan
        z_centroid_abs[iline] = nan
        s16_abs[iline] = nan
        s84_abs[iline] = nan
        W68_s_abs[iline] = nan

    if Lvalid > eps:
        mean[iline] = I / Lvalid
        mean_abs[iline] = Iabs / Lvalid
    else:
        mean[iline] = nan
        mean_abs[iline] = nan

    if maxabs >= 0.0:
        max_abs[iline] = maxabs
        s_at_max_abs[iline] = smax
        z_at_max_abs[iline] = zmax
    else:
        max_abs[iline] = nan
        s_at_max_abs[iline] = nan
        z_at_max_abs[iline] = nan


@njit(parallel=True, cache=True, fastmath=True)
def _compute_line_diagnostics_parallel(
    values_all,
    sfl,
    zfl,
    line_start,
    line_count,
    codes_all,
    use_codes,
    eps,
    integral,
    integral_abs,
    cancellation,
    mean,
    mean_abs,
    max_abs,
    s_at_max_abs,
    z_at_max_abs,
    s_centroid_abs,
    z_centroid_abs,
    s16_abs,
    s84_abs,
    W68_s_abs,
):
    nlines = line_count.size

    for iline in prange(nlines):
        _compute_one_line_diagnostics(
            iline,
            values_all,
            sfl,
            zfl,
            line_start,
            line_count,
            codes_all,
            use_codes,
            eps,
            integral,
            integral_abs,
            cancellation,
            mean,
            mean_abs,
            max_abs,
            s_at_max_abs,
            z_at_max_abs,
            s_centroid_abs,
            z_centroid_abs,
            s16_abs,
            s84_abs,
            W68_s_abs,
        )

