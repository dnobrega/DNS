PRO PRE_QFACTOR, snap0, snapf, step, factor=factor, nbridges=nbridges, tol=tol

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
    yy   = d->gety()
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

    xup_bx = xup_bx/modb
    yup_by = yup_by/modb
    zup_bz = zup_bz/modb

    wh = where(zz GE 0.0)

    xup_bx = xup_bx[*,*,wh[0]-1 : wh[-1]]
    yup_by = yup_by[*,*,wh[0]-1 : wh[-1]]
    zup_bz = zup_bz[*,*,wh[0]-1 : wh[-1]]
    
    zz = zz[wh[0]-1 : wh[-1]]
    t1 = SYSTIME(/SECONDS)
    PRINT, 'Time: ', (t1-t0), ' seg'

    qfactor, xup_bx, yup_by, zup_bz, xa=xx, ya=yy, za=zz, $
             xreg=[xx[0],xx[-1]], yreg=[yy[0],yy[-1]],zreg=[zz[0],zz[-1]],$
             factor=factor, fstr="q_perp3d_"+STRTRIM(STRING(snap),2), $
             no_preview=1, nbridges=nbridges, /scottFlag, /twistFlag

ENDFOR


END
