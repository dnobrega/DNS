import numpy as np
from numba import njit, prange
from scipy.spatial import cKDTree

import matplotlib.pyplot as plt

# Tipos de nulos según Parnell et al. 1996
# A  : dos eigenvalores con Re < 0  (fan convergente, spine divergente) — "improper"
# B  : dos eigenvalores con Re > 0  (fan divergente, spine convergente)
# As : como A pero eigenvalores complejos (espiral convergente en el fan)
# Bs : como B pero eigenvalores complejos (espiral divergente en el fan)
NULL_TYPE_UNKNOWN = 0
NULL_TYPE_A       = 1
NULL_TYPE_B       = 2
NULL_TYPE_AS      = 3   # A-spiral
NULL_TYPE_BS      = 4   # B-spiral

# ============================================================
# Global configurations (Fixed at compile time)
# ============================================================
FIELD_DTYPE  = np.float32
WORK_DTYPE   = np.float64
INT_DTYPE    = np.int32
NUMBA_CACHE  = True
FASTMATH     = False

# ============================================================
# Array preparation
# ============================================================
def _prepare_field_array(a, name, dtype=FIELD_DTYPE):
    if a.dtype != dtype:
        a = a.astype(dtype, copy=False)
    if not a.flags["C_CONTIGUOUS"]:
        a = np.ascontiguousarray(a)
    return a

def _prepare_coord_array(a, name, dtype=WORK_DTYPE):
    if a.dtype != dtype:
        a = a.astype(dtype, copy=False)
    if not a.flags["C_CONTIGUOUS"]:
        a = np.ascontiguousarray(a)
    return a

# ============================================================
# 1. Utilities
# ============================================================
@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _solve_3x3(A, b, det_tol):
    a00, a01, a02 = A[0, 0], A[0, 1], A[0, 2]
    a10, a11, a12 = A[1, 0], A[1, 1], A[1, 2]
    a20, a21, a22 = A[2, 0], A[2, 1], A[2, 2]

    det = (
        a00 * (a11 * a22 - a12 * a21)
        - a01 * (a10 * a22 - a12 * a20)
        + a02 * (a10 * a21 - a11 * a20)
    )

    x = np.zeros(3, dtype=WORK_DTYPE)

    if np.abs(det) < det_tol:
        return False, x

    b0, b1, b2 = b[0], b[1], b[2]

    detx = (
        b0  * (a11 * a22 - a12 * a21)
        - a01 * (b1  * a22 - a12 * b2)
        + a02 * (b1  * a21 - a11 * b2)
    )

    dety = (
        a00 * (b1  * a22 - a12 * b2)
        - b0  * (a10 * a22 - a12 * a20)
        + a02 * (a10 * b2  - b1  * a20)
    )

    detz = (
        a00 * (a11 * b2  - b1  * a21)
        - a01 * (a10 * b2  - b1  * a20)
        + b0  * (a10 * a21 - a11 * a20)
    )

    x[0] = detx / det
    x[1] = dety / det
    x[2] = detz / det

    return True, x

# ============================================================
# 2. Interpolation
# ============================================================
@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _trilinear_value_and_jac_cell(bx, by, bz, i, j, k, qx, qy, qz, B, Jq):
    """
    Trilinear interpolation of (bx, by, bz) and their Jacobian at normalised
    cell coordinates (qx, qy, qz) in [0,1]^3.

    B   : output vector (3,)  — field value
    Jq  : output matrix (3,3) — Jacobian w.r.t. normalised coords (q0,q1,q2)
    """
    x0, x1 = 1.0 - qx, qx
    y0, y1 = 1.0 - qy, qy
    z0, z1 = 1.0 - qz, qz

    B[0] = 0.0; B[1] = 0.0; B[2] = 0.0
    Jq[:, :] = 0.0

    for comp in range(3):
        if   comp == 0: arr = bx
        elif comp == 1: arr = by
        else:           arr = bz

        c000 = arr[k,   j,   i  ]
        c001 = arr[k,   j,   i+1]
        c010 = arr[k,   j+1, i  ]
        c011 = arr[k,   j+1, i+1]
        c100 = arr[k+1, j,   i  ]
        c101 = arr[k+1, j,   i+1]
        c110 = arr[k+1, j+1, i  ]
        c111 = arr[k+1, j+1, i+1]

        B[comp] = (
            c000 * x0 * y0 * z0 + c001 * x1 * y0 * z0
            + c010 * x0 * y1 * z0 + c011 * x1 * y1 * z0
            + c100 * x0 * y0 * z1 + c101 * x1 * y0 * z1
            + c110 * x0 * y1 * z1 + c111 * x1 * y1 * z1
        )

        Jq[comp, 0] = (
            - c000 * y0 * z0 + c001 * y0 * z0
            - c010 * y1 * z0 + c011 * y1 * z0
            - c100 * y0 * z1 + c101 * y0 * z1
            - c110 * y1 * z1 + c111 * y1 * z1
        )

        Jq[comp, 1] = (
            - c000 * x0 * z0 - c001 * x1 * z0
            + c010 * x0 * z0 + c011 * x1 * z0
            - c100 * x0 * z1 - c101 * x1 * z1
            + c110 * x0 * z1 + c111 * x1 * z1
        )

        Jq[comp, 2] = (
            - c000 * x0 * y0 - c001 * x1 * y0
            - c010 * x0 * y1 - c011 * x1 * y1
            + c100 * x0 * y0 + c101 * x1 * y0
            + c110 * x0 * y1 + c111 * x1 * y1
        )

# ============================================================
# 3. Poincaré index filter  (Haynes & Parnell 2007, Phys. Plasmas 14, 082107)
# ============================================================
@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _solid_angle_triangle(v0, v1, v2):
    """
    Ángulo sólido con signo subtendido por el triángulo (v0,v1,v2) visto desde
    el origen, asumiendo que v0,v1,v2 son vectores UNITARIOS.

    Fórmula de Van Oosterom & Strackee (1983):
        tan(Ω/2) = |v0·(v1×v2)| / (1 + v0·v1 + v1·v2 + v2·v0)

    El signo se toma del triple producto escalar v0·(v1×v2):
      > 0  →  normal apunta hacia fuera del origen  (Ω > 0)
      < 0  →  normal apunta hacia el origen          (Ω < 0)

    Devuelve Ω en radianes ∈ (-2π, 2π).
    """
    # triple producto escalar  t = v0 · (v1 × v2)
    cx = v1[1]*v2[2] - v1[2]*v2[1]
    cy = v1[2]*v2[0] - v1[0]*v2[2]
    cz = v1[0]*v2[1] - v1[1]*v2[0]
    t  = v0[0]*cx + v0[1]*cy + v0[2]*cz

    denom = (1.0
             + v0[0]*v1[0] + v0[1]*v1[1] + v0[2]*v1[2]
             + v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2]
             + v2[0]*v0[0] + v2[1]*v0[1] + v2[2]*v0[2])

    if denom == 0.0:
        # Degenerado: un vértice antipodal al origen — contribución ±π
        return np.pi if t > 0.0 else -np.pi

    return 2.0 * np.arctan2(t, denom)   # con signo


@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _normalize3(v, out):
    """Normaliza v → out. Devuelve la norma."""
    n = np.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
    if n > 0.0:
        out[0] = v[0] / n
        out[1] = v[1] / n
        out[2] = v[2] / n
    else:
        out[0] = out[1] = out[2] = 0.0
    return n


@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _poincare_index_cell(bx, by, bz, i, j, k):
    """
    Calcula el índice de Poincaré de la celda (i,j,k) integrando el ángulo
    sólido de B/|B| sobre la superficie del cubo.

    La superficie se triangula en 12 triángulos (2 por cara), orientados con
    la normal apuntando hacia FUERA de la celda.  El índice es:

        P = round( Ω_total / (4π) )   ∈ {-1, 0, +1}

    P = ±1  →  hay exactamente un nulo topológico simple en la celda.
    P =  0  →  no hay nulo (o hay un número par que se cancelan — raro).

    Los 8 vectores B normalizados se almacenan en un buffer local (b_hat)
    indexado como b_hat[dz*4 + dy*2 + dx].
    """
    # ------------------------------------------------------------------
    # 1. Leer y normalizar B en los 8 vértices
    # ------------------------------------------------------------------
    b_hat = np.zeros((8, 3), dtype=WORK_DTYPE)
    degenerate = False

    idx = 0
    for dz in range(2):
        for dy in range(2):
            for dx in range(2):
                bv = np.empty(3, dtype=WORK_DTYPE)
                bv[0] = bx[k + dz, j + dy, i + dx]
                bv[1] = by[k + dz, j + dy, i + dx]
                bv[2] = bz[k + dz, j + dy, i + dx]
                n = _normalize3(bv, b_hat[idx])
                if n == 0.0:
                    degenerate = True
                idx += 1

    if degenerate:
        return 0   # B=0 en un vértice: celda degenerada, no podemos decidir

    # ------------------------------------------------------------------
    # 2. Sumar ángulos sólidos sobre las 6 caras (2 triángulos cada una)
    #
    # Convención de índices de vértice: v[dz*4 + dy*2 + dx]
    #
    #   dz=0 (cara z-)  vértices: 0(0,0,0) 1(1,0,0) 2(0,1,0) 3(1,1,0)
    #   dz=1 (cara z+)  vértices: 4(0,0,1) 5(1,0,1) 6(0,1,1) 7(1,1,1)
    #
    # Cada cara se divide en 2 triángulos asegurando que la normal apunte
    # hacia fuera. El orden de los vértices determina la orientación (regla
    # de la mano derecha): para la normal exterior, el orden debe ser
    # antihorario visto desde fuera.
    # ------------------------------------------------------------------
    omega = 0.0

    # Cara z- (dz=0): normal hacia -z → vértices en orden (0,1,3,2)
    omega += _solid_angle_triangle(b_hat[0], b_hat[2], b_hat[1])
    omega += _solid_angle_triangle(b_hat[1], b_hat[2], b_hat[3])

    # Cara z+ (dz=1): normal hacia +z → vértices 4,5,7,6
    omega += _solid_angle_triangle(b_hat[4], b_hat[5], b_hat[6])
    omega += _solid_angle_triangle(b_hat[5], b_hat[7], b_hat[6])

    # Cara y- (dy=0): normal hacia -y → vértices 0,4,5,1
    omega += _solid_angle_triangle(b_hat[0], b_hat[1], b_hat[4])
    omega += _solid_angle_triangle(b_hat[1], b_hat[5], b_hat[4])

    # Cara y+ (dy=1): normal hacia +y → vértices 2,3,7,6
    omega += _solid_angle_triangle(b_hat[2], b_hat[6], b_hat[3])
    omega += _solid_angle_triangle(b_hat[3], b_hat[6], b_hat[7])

    # Cara x- (dx=0): normal hacia -x → vértices 0,2,6,4
    omega += _solid_angle_triangle(b_hat[0], b_hat[4], b_hat[2])
    omega += _solid_angle_triangle(b_hat[2], b_hat[4], b_hat[6])

    # Cara x+ (dx=1): normal hacia +x → vértices 1,3,7,5
    omega += _solid_angle_triangle(b_hat[1], b_hat[3], b_hat[5])
    omega += _solid_angle_triangle(b_hat[3], b_hat[7], b_hat[5])

    # ------------------------------------------------------------------
    # 3. Índice = Ω / (4π), redondeado al entero más próximo
    # ------------------------------------------------------------------
    return int(round(omega / (4.0 * np.pi)))


# ============================================================
# 4. Candidate cell filtering
# ============================================================
@njit(cache=NUMBA_CACHE, fastmath=FASTMATH)
def _all_components_cross_zero(bx, by, bz, i, j, k):
    """
    Primera criba rápida (condición necesaria): los tres componentes de B
    deben tener un cruce de cero en la celda. Una sola pasada sobre los 8
    vértices evalúa los tres componentes, reduciendo accesos a memoria a 1/3
    respecto a tres llamadas separadas.
    """
    xmin = xmax = bx[k, j, i]
    ymin = ymax = by[k, j, i]
    zmin = zmax = bz[k, j, i]

    for dz in range(2):
        for dy in range(2):
            for dx in range(2):
                vx = bx[k + dz, j + dy, i + dx]
                vy = by[k + dz, j + dy, i + dx]
                vz = bz[k + dz, j + dy, i + dx]
                if vx < xmin: xmin = vx
                if vx > xmax: xmax = vx
                if vy < ymin: ymin = vy
                if vy > ymax: ymax = vy
                if vz < zmin: zmin = vz
                if vz > zmax: zmax = vz

    return (xmin <= 0.0 <= xmax) and (ymin <= 0.0 <= ymax) and (zmin <= 0.0 <= zmax)


@njit(parallel=True, cache=NUMBA_CACHE, fastmath=FASTMATH)
def count_candidate_cells(bx, by, bz, use_poincare):
    """
    Cuenta celdas candidatas por capa k aplicando dos filtros en cascada:
      1. Cruce de cero por componente (rápido, condición necesaria).
      2. Índice de Poincaré ≠ 0    (más costoso, condición necesaria y suficiente).
    El segundo filtro sólo se aplica si use_poincare=True.
    """
    nz, ny, nx = bx.shape
    counts = np.zeros(nz - 1, dtype=np.int64)

    for k in prange(nz - 1):
        c = 0
        for j in range(ny - 1):
            for i in range(nx - 1):
                if not _all_components_cross_zero(bx, by, bz, i, j, k):
                    continue
                if use_poincare:
                    if _poincare_index_cell(bx, by, bz, i, j, k) == 0:
                        continue
                c += 1
        counts[k] = c
    return counts


@njit(parallel=True, cache=NUMBA_CACHE, fastmath=FASTMATH)
def fill_candidate_cells(bx, by, bz, offsets, candidates, poincare_indices, use_poincare):
    """
    Rellena el array de candidatos. `pos` es escalar local a cada hilo de
    prange — no hay race condition.
    Si use_poincare=True, también almacena el índice de Poincaré de cada celda.
    """
    nz, ny, nx = bx.shape
    for k in prange(nz - 1):
        pos = offsets[k]
        for j in range(ny - 1):
            for i in range(nx - 1):
                if not _all_components_cross_zero(bx, by, bz, i, j, k):
                    continue
                pidx = 0
                if use_poincare:
                    pidx = _poincare_index_cell(bx, by, bz, i, j, k)
                    if pidx == 0:
                        continue
                candidates[pos, 0] = i
                candidates[pos, 1] = j
                candidates[pos, 2] = k
                poincare_indices[pos] = pidx
                pos += 1


def get_candidate_cells(bx, by, bz, use_poincare=True):
    counts  = count_candidate_cells(bx, by, bz, use_poincare)
    offsets = np.zeros_like(counts)
    if counts.size > 1:
        offsets[1:] = np.cumsum(counts[:-1])
    n_candidates    = int(np.sum(counts))
    candidates      = np.empty((n_candidates, 3), dtype=INT_DTYPE)
    poincare_indices = np.zeros(n_candidates, dtype=np.int32)
    fill_candidate_cells(bx, by, bz, offsets, candidates, poincare_indices, use_poincare)
    return candidates, counts, poincare_indices

# ============================================================
# 5. Newton refinement
# ============================================================
@njit(cache=NUMBA_CACHE)
def _refine_null_in_cell(
    bx, by, bz, x, y, z, i, j, k,
    max_iter, b_tol, q_tol, det_tol,
    B, Jq, Jphys
):
    q0 = 0.5
    q1 = 0.5
    q2 = 0.5
    success = False
    bnorm   = 1.0e99
    rhs     = np.empty(3, dtype=WORK_DTYPE)

    for _ in range(max_iter):
        _trilinear_value_and_jac_cell(bx, by, bz, i, j, k, q0, q1, q2, B, Jq)

        bnorm = np.sqrt(B[0]*B[0] + B[1]*B[1] + B[2]*B[2])

        if bnorm < b_tol:
            success = True
            break

        rhs[0] = -B[0]
        rhs[1] = -B[1]
        rhs[2] = -B[2]

        ok, dq = _solve_3x3(Jq, rhs, det_tol)
        if not ok:
            break

        damp = 1.0
        for _ in range(6):
            qnew0 = q0 + damp * dq[0]
            qnew1 = q1 + damp * dq[1]
            qnew2 = q2 + damp * dq[2]
            if (qnew0 >= -q_tol and qnew0 <= 1.0 + q_tol and
                qnew1 >= -q_tol and qnew1 <= 1.0 + q_tol and
                qnew2 >= -q_tol and qnew2 <= 1.0 + q_tol):
                q0, q1, q2 = qnew0, qnew1, qnew2
                break
            damp *= 0.5
        else:
            q0 += damp * dq[0]
            q1 += damp * dq[1]
            q2 += damp * dq[2]

        if not (q0 >= -q_tol and q0 <= 1.0 + q_tol and
                q1 >= -q_tol and q1 <= 1.0 + q_tol and
                q2 >= -q_tol and q2 <= 1.0 + q_tol):
            success = False
            break

    if success:
        qx = min(1.0, max(0.0, q0))
        qy = min(1.0, max(0.0, q1))
        qz = min(1.0, max(0.0, q2))

        xnull = x[i] + qx * (x[i + 1] - x[i])
        ynull = y[j] + qy * (y[j + 1] - y[j])
        znull = z[k] + qz * (z[k + 1] - z[k])

        # FIX: no se recalcula Jq — ya tiene los valores de la última iteración
        # donde se verificó bnorm < b_tol. Solo se escala a coordenadas físicas.
        dx = x[i + 1] - x[i]
        dy = y[j + 1] - y[j]
        dz = z[k + 1] - z[k]

        for comp in range(3):
            Jphys[comp, 0] = Jq[comp, 0] / dx
            Jphys[comp, 1] = Jq[comp, 1] / dy
            Jphys[comp, 2] = Jq[comp, 2] / dz

        return True, xnull, ynull, znull, qx, qy, qz, bnorm

    return False, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bnorm


@njit(parallel=True, cache=NUMBA_CACHE, fastmath=FASTMATH)
def refine_candidates(bx, by, bz, x, y, z, candidates, poincare_indices,
                      max_iter, b_tol, q_tol, det_tol):
    n          = candidates.shape[0]
    found_mask = np.zeros(n, dtype=np.bool_)
    null_pos   = np.full((n, 3),    np.nan, dtype=WORK_DTYPE)
    null_cell  = np.full((n, 3),    -1,     dtype=np.int64)
    null_q     = np.full((n, 3),    np.nan, dtype=WORK_DTYPE)
    bnorms     = np.full(n,         np.nan, dtype=WORK_DTYPE)
    jacs       = np.full((n, 3, 3), np.nan, dtype=WORK_DTYPE)
    pidx_out   = np.zeros(n,                dtype=np.int32)

    for ncell in prange(n):
        i = candidates[ncell, 0]
        j = candidates[ncell, 1]
        k = candidates[ncell, 2]
        
        # trilinear_value_and_jac_cell inicializa B y Jq explícitamente antes de escribir.
        B_buf     = np.empty(3,      dtype=WORK_DTYPE)
        Jq_buf    = np.empty((3, 3), dtype=WORK_DTYPE)
        Jphys_buf = np.empty((3, 3), dtype=WORK_DTYPE)

        ok, xn, yn, zn, qx, qy, qz, bn = _refine_null_in_cell(
            bx, by, bz, x, y, z, i, j, k,
            max_iter, b_tol, q_tol, det_tol,
            B_buf, Jq_buf, Jphys_buf
        )

        if ok:
            found_mask[ncell]    = True
            null_pos[ncell, 0]   = xn
            null_pos[ncell, 1]   = yn
            null_pos[ncell, 2]   = zn
            null_cell[ncell, 0]  = i
            null_cell[ncell, 1]  = j
            null_cell[ncell, 2]  = k
            null_q[ncell, 0]     = qx
            null_q[ncell, 1]     = qy
            null_q[ncell, 2]     = qz
            bnorms[ncell]        = bn
            jacs[ncell, :, :]    = Jphys_buf
            pidx_out[ncell]      = poincare_indices[ncell]

    return found_mask, null_pos, null_cell, null_q, bnorms, jacs, pidx_out

# ============================================================
# 6. Duplicate removal
# ============================================================
def _remove_duplicate_nulls(pos, cell, q, bnorm, jac, pidx, x, y, z, duplicate_tol=None):
    """
    cKDTree O(n log n).
    Se conserva siempre el nulo de menor |B| (más preciso) de cada cluster.
    """
    if len(pos) <= 1:
        return pos, cell, q, bnorm, jac, pidx

    if duplicate_tol is None:
        duplicate_tol = 1e-6 * min(
            np.abs(np.min(np.diff(x))),
            np.abs(np.min(np.diff(y))),
            np.abs(np.min(np.diff(z))),
        )

    order  = np.argsort(bnorm)
    pos_s  = pos[order];  cell_s = cell[order]
    q_s    = q[order];    bn_s   = bnorm[order]
    jac_s  = jac[order];  pidx_s = pidx[order]

    tree  = cKDTree(pos_s)
    pairs = tree.query_pairs(duplicate_tol, output_type='ndarray')

    drop = np.zeros(len(pos_s), dtype=bool)
    for a, b in pairs:
        if not drop[a]:
            drop[b] = True

    keep = ~drop
    return pos_s[keep], cell_s[keep], q_s[keep], bn_s[keep], jac_s[keep], pidx_s[keep]

# ============================================================
# 7. Topological classification  (Parnell et al. 1996, Phys. Plasmas 3, 759)
# ============================================================
def _classify_nulls(jacs, div_tol_rel=1e-2):
    """
    Clasifica cada nulo a partir del Jacobiano físico J = dB/dr.

    Teoría
    ------
    En MHD ideal ∇·B = 0  →  tr(J) = 0 exactamente.
    Los tres eigenvalores {λ₀, λ₁, λ₂} satisfacen λ₀+λ₁+λ₂ = tr(J) ≈ 0.
    Se ordenan de forma que un par {λ_fan0, λ_fan1} comparte signo de Re
    y el tercero {λ_spine} tiene Re de signo opuesto.

    Clasificación:
      Re(λ_fan) < 0  →  tipo A   (fan convergente)
      Re(λ_fan) > 0  →  tipo B   (fan divergente)
      Im(λ_fan) ≠ 0  →  sufijo s (espiral: As o Bs)

    Outputs
    -------
    null_type   : (N,) int8  — constantes NULL_TYPE_*
    eigenvalues : (N,3) complex128
    spine_vec   : (N,3) float64  — dirección del spine (eigenvector real de λ_spine)
    fan_normal  : (N,3) float64  — normal al fan = spine_vec × (fan eigvec 0)
    div_residual: (N,)  float64  — |tr(J)| / ||J||_F  (test de calidad: debe ser ≪ 1)
    """
    N = len(jacs)
    null_type    = np.full(N, NULL_TYPE_UNKNOWN, dtype=np.int8)
    eigenvalues  = np.zeros((N, 3), dtype=complex)
    spine_vec    = np.full((N, 3), np.nan)
    fan_normal   = np.full((N, 3), np.nan)
    div_residual = np.full(N, np.nan)

    for n in range(N):
        J = jacs[n]

        # --- Test de calidad: divergencia numérica relativa ---
        frob = np.linalg.norm(J, 'fro')
        trace = np.trace(J)
        div_residual[n] = abs(trace) / frob if frob > 0 else 0.0

        # --- Eigendescomposición ---
        eigvals, eigvecs = np.linalg.eig(J)
        eigenvalues[n]   = eigvals


            
        #### NEW CODE

        re = np.real(eigvals)
        im = np.imag(eigvals)
        scale    = max(np.max(np.abs(eigvals)), 1.0e-300)
        imag_tol = 1.0e-10 * scale
        real_tol = 1.0e-10 * scale

        complex_mask = np.abs(im) > imag_tol

        if np.sum(complex_mask) == 2:
            # Eigenvalores complejos conjugados: el spine es el único real
            # y el tipo (As/Bs) se determina directamente por su signo
            spine_idx  = int(np.where(~complex_mask)[0][0])
            fan_re     = re[complex_mask][0]
            is_spiral  = True
        else:
            # Todos reales: identificar spine por signo de Re con banda de tolerancia
            s0 = 1 if re[0] > real_tol else (-1 if re[0] < -real_tol else 0)
            s1 = 1 if re[1] > real_tol else (-1 if re[1] < -real_tol else 0)
            s2 = 1 if re[2] > real_tol else (-1 if re[2] < -real_tol else 0)

            if s0 == 0 or s1 == 0 or s2 == 0:
                # Re ≈ 0 en algún eigenvalor: nulo degenerado, no clasificable
                null_type[n] = NULL_TYPE_UNKNOWN
                continue

            if s0 == s1:
                spine_idx = 2
            elif s0 == s2:
                spine_idx = 1
            else:
                spine_idx = 0

            fan_indices = [m for m in range(3) if m != spine_idx]
            fan_re      = re[fan_indices[0]]
            is_spiral   = False

        # Tipo topológico
        if fan_re < -real_tol:
            null_type[n] = NULL_TYPE_AS if is_spiral else NULL_TYPE_A
        elif fan_re > real_tol:
            null_type[n] = NULL_TYPE_BS if is_spiral else NULL_TYPE_B
        else:
            null_type[n] = NULL_TYPE_UNKNOWN   # fan con Re ≈ 0: nulo marginal

        ####


        fan_indices = [m for m in range(3) if m != spine_idx]
        re_fan      = re[fan_indices[0]]   # ambos fans comparten signo de Re
        im_fan      = np.imag(eigvals[fan_indices[0]])

        # --- Tipo ---
        is_spiral = abs(im_fan) > 1e-12 * abs(re_fan + 1e-300)
        if re_fan < 0:
            null_type[n] = NULL_TYPE_AS if is_spiral else NULL_TYPE_A
        else:
            null_type[n] = NULL_TYPE_BS if is_spiral else NULL_TYPE_B

        # --- Spine (dirección real del eigenvector asociado a λ_spine) ---
        sv = np.real(eigvecs[:, spine_idx])
        norm_sv = np.linalg.norm(sv)
        if norm_sv > 0:
            spine_vec[n] = sv / norm_sv

        # --- Normal al fan = spine × fan_eigvec0 ---
        fv = np.real(eigvecs[:, fan_indices[0]])
        norm_fv = np.linalg.norm(fv)
        if norm_sv > 0 and norm_fv > 0:
            fv /= norm_fv
            fn = np.cross(spine_vec[n], fv)
            norm_fn = np.linalg.norm(fn)
            if norm_fn > 0:
                fan_normal[n] = fn / norm_fn

    return null_type, eigenvalues, spine_vec, fan_normal, div_residual


def null_type_name(code):
    """Devuelve el nombre legible del tipo de nulo."""
    return {
        NULL_TYPE_UNKNOWN: "unknown",
        NULL_TYPE_A:  "A",
        NULL_TYPE_B:  "B",
        NULL_TYPE_AS: "As",
        NULL_TYPE_BS: "Bs",
    }.get(int(code), "unknown")


# ============================================================
# 8. Public API
# ============================================================
def find_magnetic_nulls(
    bx, by, bz, x, y, z,
    max_iter          = 30,
    b_tol             = 1.0e-6,
    q_tol             = 1.0e-6,
    det_tol           = 1.0e-20,
    use_poincare      = True,
    remove_duplicates = True,
    duplicate_tol     = None,
    classify          = True,
    verbose           = True,
):
    """
    Localiza y clasifica puntos nulos del campo magnético (B=0) en una malla
    cartesiana (posiblemente no uniforme).

    Pipeline
    --------
    1. Filtro de cruce de cero por componente  (condición necesaria, O(N_celdas))
    2. Filtro de índice de Poincaré ≠ 0        (condición necesaria y suficiente,
                                                ~12× más costoso por celda pero
                                                elimina todos los falsos positivos
                                                topológicos antes del Newton)
    3. Refinamiento Newton-Raphson con damping  (convergencia cuadrática)
    4. Eliminación de duplicados con cKDTree    (O(n log n))
    5. Clasificación topológica A/B/As/Bs       (Parnell et al. 1996)

    Parámetros
    ----------
    bx, by, bz        : ndarray (nz, ny, nx)  — componentes del campo (float32 recomendado)
    x, y, z           : ndarray 1D            — coordenadas de la malla (pueden ser no uniformes)
    max_iter          : int    — iteraciones máximas de Newton por celda
    b_tol             : float  — tolerancia absoluta |B| < b_tol para convergencia
                        ⚠ en las mismas unidades que el campo; ajustar si B ≫ 1.
    q_tol             : float  — margen sobre coordenadas normalizadas ∈ [0,1]
    det_tol           : float  — umbral de singularidad del Jacobiano en Newton
    use_poincare      : bool   — activar filtro de índice de Poincaré (recomendado)
    remove_duplicates : bool   — eliminar nulos repetidos que convergen al mismo punto
    duplicate_tol     : float  — distancia física para considerar duplicados (None = auto)
    classify          : bool   — calcular tipo topológico, spine, fan y ∇·B residual
    verbose           : bool

    Devuelve
    --------
    dict con claves:

    Localización:
        pos          (N,3)   — posiciones físicas (x,y,z) de los nulos
        cell         (N,3)   — índices (i,j,k) de la celda que contiene cada nulo
        q            (N,3)   — coordenadas normalizadas dentro de la celda ∈ [0,1]³
        bnorm        (N,)    — |B| residual en el nulo (calidad del Newton)
        jacobian     (N,3,3) — Jacobiano físico dB/dr evaluado en el nulo
        poincare     (N,)    — índice de Poincaré de la celda (±1)

    Clasificación (sólo si classify=True):
        null_type    (N,)    — entero según constantes NULL_TYPE_*
        eigenvalues  (N,3)   — eigenvalores complejos de J
        spine_vec    (N,3)   — dirección del spine
        fan_normal   (N,3)   — normal al plano del fan
        div_residual (N,)    — |tr(J)|/||J||_F  ≪ 1 indica buena calidad numérica

    Diagnóstico:
        candidates   (M,3)   — celdas candidatas que pasaron todos los filtros previos al Newton
        counts       (nz-1,) — nº de candidatos por capa k
    """
    bx = _prepare_field_array(bx, "bx", FIELD_DTYPE)
    by = _prepare_field_array(by, "by", FIELD_DTYPE)
    bz = _prepare_field_array(bz, "bz", FIELD_DTYPE)
    x  = _prepare_coord_array(x,  "x",  WORK_DTYPE)
    y  = _prepare_coord_array(y,  "y",  WORK_DTYPE)
    z  = _prepare_coord_array(z,  "z",  WORK_DTYPE)

    if bx.shape != by.shape or bx.shape != bz.shape:
        raise ValueError("bx, by, bz deben tener la misma forma (nz, ny, nx).")
    nz, ny, nx = bx.shape
    if x.size != nx or y.size != ny or z.size != nz:
        raise ValueError("Los tamaños de las coordenadas deben coincidir con bx.shape.")

    candidates, counts, poincare_indices = get_candidate_cells(bx, by, bz, use_poincare)

    empty = {
        "pos":          np.empty((0, 3),    dtype=WORK_DTYPE),
        "cell":         np.empty((0, 3),    dtype=INT_DTYPE),
        "q":            np.empty((0, 3),    dtype=WORK_DTYPE),
        "bnorm":        np.empty(0,         dtype=WORK_DTYPE),
        "jacobian":     np.empty((0, 3, 3), dtype=WORK_DTYPE),
        "poincare":     np.empty(0,         dtype=np.int32),
        "null_type":    np.empty(0,         dtype=np.int8),
        "eigenvalues":  np.empty((0, 3),    dtype=complex),
        "spine_vec":    np.empty((0, 3),    dtype=WORK_DTYPE),
        "fan_normal":   np.empty((0, 3),    dtype=WORK_DTYPE),
        "div_residual": np.empty(0,         dtype=WORK_DTYPE),
        "candidates":   candidates,
        "counts":       counts,
    }

    if len(candidates) == 0:
        return empty

    found_mask, pos, cell, q, bnorm, jac, pidx = refine_candidates(
        bx, by, bz, x, y, z, candidates, poincare_indices,
        int(max_iter), float(b_tol), float(q_tol), float(det_tol)
    )

    pos   = pos[found_mask]
    cell  = cell[found_mask]
    q     = q[found_mask]
    bnorm = bnorm[found_mask]
    jac   = jac[found_mask]
    pidx  = pidx[found_mask]

    if remove_duplicates and len(pos) > 1:
        pos, cell, q, bnorm, jac, pidx = _remove_duplicate_nulls(
            pos, cell, q, bnorm, jac, pidx, x, y, z, duplicate_tol
        )

    result = {
        "pos":       pos,
        "cell":      cell,
        "q":         q,
        "bnorm":     bnorm,
        "jacobian":  jac,
        "poincare":  pidx,
        "candidates": candidates,
        "counts":    counts,
    }

    if classify and len(pos) > 0:
        null_type, eigvals, sv, fn, divr = _classify_nulls(jac)
        result["null_type"]    = null_type
        result["eigenvalues"]  = eigvals
        result["spine_vec"]    = sv
        result["fan_normal"]   = fn
        result["div_residual"] = divr
    else:
        result["null_type"]    = np.full(len(pos), NULL_TYPE_UNKNOWN, dtype=np.int8)
        result["eigenvalues"]  = np.full((len(pos), 3), np.nan, dtype=complex)
        result["spine_vec"]    = np.full((len(pos), 3), np.nan)
        result["fan_normal"]   = np.full((len(pos), 3), np.nan)
        result["div_residual"] = np.full(len(pos), np.nan)

    return result

def plot_nulls_3d(
    res,
    x=None,
    y=None,
    z=None,
    ax=None,
    color_by="z",
    show_domain=True,
    marker_size=45,
    elev=22,
    azim=-55,
    title="Magnetic null points",
):
    """
    Plot magnetic null points in 3D.

    Parameters
    ----------
    res : dict
        Output dictionary from find_magnetic_nulls().
        Must contain res["pos"], with shape (Nnull, 3).

    x, y, z : ndarray or None
        Optional 1D coordinate arrays of the simulation domain.
        If provided and show_domain=True, the box limits are shown.

    ax : matplotlib 3D axis or None
        Existing 3D axis. If None, a new figure is created.

    color_by : {"z", "index", "bnorm", None}
        Quantity used to color the nulls.

    show_domain : bool
        If True and x,y,z are provided, show the simulation box limits.

    marker_size : float
        Marker size for the null points.

    elev, azim : float
        View angles.

    title : str
        Plot title.

    Returns
    -------
    fig, ax
    """

    pos  = np.asarray(res["pos"])
    tipo = np.asarray(res["null_type"])

    if pos.size == 0:
        print("[plot_nulls_3d] No nulls to plot.")
        fig = plt.figure(figsize=(7, 6))
        ax = fig.add_subplot(111, projection="3d")
        ax.set_title(title + " — none found")
        return fig, ax

    if pos.ndim != 2 or pos.shape[1] != 3:
        raise ValueError('res["pos"] must have shape (Nnull, 3).')

    xnull = pos[:, 0]
    ynull = pos[:, 1]
    znull = pos[:, 2]

    if ax is None:
        fig = plt.figure(figsize=(8, 7))
        ax = fig.add_subplot(111, projection="3d")
    else:
        fig = ax.figure

    # --------------------------------------------------------
    # Choose coloring
    # --------------------------------------------------------
    if color_by == "z":
        c = znull
        cbar_label = "z"
    elif color_by == "index":
        c = np.arange(len(pos))
        cbar_label = "Null index"
    elif color_by == "type":
        c = tipo
        cbar_label = "Null type"
    elif color_by == "bnorm":
        if "bnorm" not in res:
            raise ValueError('color_by="bnorm" requires res["bnorm"].')
        c = np.asarray(res["bnorm"])
        cbar_label = r"$|B|$ residual"
    elif color_by is None:
        c = None
        cbar_label = None
    else:
        raise ValueError('color_by must be "z", "index", "bnorm", or None.')

    sc = ax.scatter(
        xnull,
        ynull,
        znull,
        c=c,
        cmap="turbo",
        s=marker_size,
        marker="o",
        depthshade=True,
        edgecolors="k",
        linewidths=0.5,
    )

    if c is not None:
        cb = fig.colorbar(sc, ax=ax, shrink=0.75, pad=0.08)
        cb.set_label(cbar_label)

    # --------------------------------------------------------
    # Optional domain box
    # --------------------------------------------------------
    if show_domain and x is not None and y is not None and z is not None:
        xmin, xmax = np.nanmin(x), np.nanmax(x)
        ymin, ymax = np.nanmin(y), np.nanmax(y)
        zmin, zmax = np.nanmin(z), np.nanmax(z)

        # Box corners
        corners = np.array([
            [xmin, ymin, zmin],
            [xmax, ymin, zmin],
            [xmax, ymax, zmin],
            [xmin, ymax, zmin],
            [xmin, ymin, zmax],
            [xmax, ymin, zmax],
            [xmax, ymax, zmax],
            [xmin, ymax, zmax],
        ])

        edges = [
            (0, 1), (1, 2), (2, 3), (3, 0),
            (4, 5), (5, 6), (6, 7), (7, 4),
            (0, 4), (1, 5), (2, 6), (3, 7),
        ]

        #for a, b in edges:
        #    ax.plot(
        #        [corners[a, 0], corners[b, 0]],
        #        [corners[a, 1], corners[b, 1]],
        #        [corners[a, 2], corners[b, 2]],
        #        color="0.4",
        #        linewidth=0.8,
        #        alpha=0.9,
        #    )

        ax.set_xlim(xmin, xmax)
        ax.set_ylim(ymin, ymax)
        ax.set_zlim(zmin, zmax)

    # --------------------------------------------------------
    # Labels and view
    # --------------------------------------------------------
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_zlabel("z")

    ax.set_title(f"{title} — N = {len(pos)}")

    ax.view_init(elev=elev, azim=azim)

    # Try to keep aspect ratio physically meaningful
    try:
        if x is not None and y is not None and z is not None:
            ax.set_box_aspect((
                np.nanmax(x) - np.nanmin(x),
                np.nanmax(y) - np.nanmin(y),
                np.nanmax(z) - np.nanmin(z),
            ))
    except Exception:
        pass

    plt.tight_layout()

    return fig, ax
