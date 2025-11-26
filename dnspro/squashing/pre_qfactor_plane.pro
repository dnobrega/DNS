PRO PRE_QFACTOR_PLANE, snap0, snapf, step, zplane, ztop=ztop, factor=factor, nbridges=nbridges, tol=tol

br_select_idlparam,idlparam
d=obj_new('br_data',idlparam)
br_getsnapind,idlparam,snaps
  
;---------------------------------------------------------
; Input parameters
;---------------------------------------------------------
IF ~keyword_set(tol)      THEN tol = 1e-4
IF ~keyword_set(factor)   THEN factor = 1
IF ~keyword_set(nbridges) THEN nbridges = 32

;---------------------------------------------------------
FOR snap=snap0,snapf,step DO BEGIN
    t0 = SYSTIME(/SECONDS)
    print, snap
    bx = d->getvar('bx',snap)
    by = d->getvar('by',snap)
    bz = d->getvar('bz',snap)
    
    xup_bx = xup(bx)
    yup_by = yup(by)
    zup_bz = zup(bz)
      
    xx   = d->getx()
    yy   = xx
    zz   = d->getz()

    nelx = d->getmx()
    nely = d->getmy()
    nelz = d->getmz()

    xup_bx   = reverse(xup_bx,3)
    xup_bx   = reverse(xup_bx,2)
    
    yup_by   = reverse(yup_by,3)
    yup_by   = -reverse(yup_by,2)
      
    zup_bz   = reverse(zup_bz,3)
    zup_bz   = -reverse(zup_bz,2)

    modb     = sqrt(xup_bx^2.0 + yup_by^2.0 + zup_bz^2.0)
    zz       = -reverse(zz)
    IF ~keyword_set(ztop) THEN ztop = max(zz)
    
    xup_bx = xup_bx/modb
    yup_by = yup_by/modb
    zup_bz = zup_bz/modb

    wh = where(zz GE zplane)
    xup_bx = xup_bx[*,*,wh[0]-1 : wh[-1]]
    yup_by = yup_by[*,*,wh[0]-1 : wh[-1]]
    zup_bz = zup_bz[*,*,wh[0]-1 : wh[-1]]
    zz     = zz[wh[0]-1 : wh[-1]]
    
    wh     = min(where(zz GE ztop))
    xup_bx = xup_bx[*,*,0 : wh]
    yup_by = yup_by[*,*,0 : wh]
    zup_bz = zup_bz[*,*,0 : wh]
    zz     = zz[0 : wh]

    t1 = SYSTIME(/SECONDS)
    PRINT, 'Time: ', (t1-t0), ' seg'

    qfactor, xup_bx, yup_by, zup_bz, xa=xx, ya=yy, za=zz, $
             factor=factor, fstr="q_perp_xy_"+STRTRIM(STRING(zplane, FORMAT='(F0.1)'),2)+"_"+STRTRIM(STRING(factor),2)+"_"+STRTRIM(STRING(snap),2), $
             no_preview=1, nbridges=nbridges, /scottFlag, /twistFlag, xfile="qfactor_plane.x"

ENDFOR


END
