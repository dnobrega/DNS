

;---------------------------------------------------------
; Input parameters
;---------------------------------------------------------
snap0        = 1210 
snapf        = 1211
step         = 2

nbridges        = !CPU.HW_NCPU-4
factor          = 1
tol             = 1e-4
max_trace_steps = 200

;---------------------------------------------------------
units_solar, u
FOR snap=snap0,snapf,step DO BEGIN
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
    
    wh = where(zz GE 1.0)

    xup_bx = xup_bx[*,*,wh]
    yup_by = yup_by[*,*,wh]
    zup_bz = zup_bz[*,*,wh]
    
    zz = zz[wh]

    qfactor, xup_bx, yup_by, zup_bz, xa=xx, ya=yy, za=zz, $
             xreg=[xx[0],xx[-1]], yreg=[yy[0],yy[-1]],zreg=[zz[0],zz[-1]],$
             factor=factor, fstr="q_perp3d_"+STRTRIM(STRING(snap),2), $
             no_preview=1, nbridges=nbridges, /scottFlag, /twistFlag

ENDFOR


END
