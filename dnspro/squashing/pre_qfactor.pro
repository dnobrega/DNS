

;---------------------------------------------------------
; Input parameters
;---------------------------------------------------------
snap0        = 0 
snapf        = 1
step         = 2
save_uniform = 0
save_squash  = 1
factor       = 1
traceFlag    = 1
tol          = 1e-4
max_trace_steps = 200
;---------------------------------------------------------
units_solar, u
IF save_uniform THEN BEGIN

   FOR snap=snap0,snapf,step DO BEGIN
      print, snap
      bx = d->getvar('bx',snap)
      by = d->getvar('by',snap)
      bz = d->getvar('bz',snap)

      xup_bx = xup(bx)
      yup_by = yup(by)
      zup_bz = zup(bz)
      
      xx   = d->getx()
      dx   = d->getdx()
      yy   = d->gety()
      z    = d->getz()
      dz   = dx
      nelx = d->getmx()
      nely = d->getmy()
      nz   = d->getmz()
      maxz = MAX(z, MIN=minz)
      nelz = floor((maxz-minz)/(dz) + 1)
      dz1d = d->getdz1d()
      zz   = minz+dz*FINDGEN(nelz)
      IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
         index  = indgen(nelx)
         indey  = indgen(nely)
         indez  = interpol(indgen(nz), z, zz)
         xup_bx = INTERPOLATE(xup_bx, index, indey, indez, /grid)
         yup_by = INTERPOLATE(yup_by, index, indey, indez, /grid)
         zup_bz = INTERPOLATE(zup_bz, index, indey, indez, /grid)
      ENDIF 
      
      xup_bx   = reverse(xup_bx,3)
      xup_bx   = reverse(xup_bx,2)
      
      yup_by   = reverse(yup_by,3)
      yup_by   = -reverse(yup_by,2)
      
      zup_bz   = reverse(zup_bz,3)
      zup_bz   = -reverse(zup_bz,2)

      modb     = sqrt(xup_bx^2.0 + yup_by^2.0 + zup_bz^2.0)

      zz       = -reverse(zz)

      save, xx, yy, zz, xup_bx, yup_by, zup_bz, modb, filename="CENUNI/cenuni_bfield_"+STRTRIM(STRING(snap),2)+".sav"

   ENDFOR
   
ENDIF

IF save_squash EQ 1 THEN BEGIN
   
   FOR snap=snap0,snapf,step DO BEGIN

      print, snap
      RESTORE, filename="CENUNI/cenuni_bfield_"+STRTRIM(STRING(snap),2)+".sav"

      xup_bx = xup_bx/modb
      yup_by = yup_by/modb
      zup_bz = zup_bz/modb
    
      wh = where(zz GE 1.0)

      xup_bx = xup_bx[*,*,wh]
      yup_by = yup_by[*,*,wh]
      zup_bz = zup_bz[*,*,wh]

      zz = zz[wh]

      xreg = [0,n_elements(xx)-1]
      yreg = [0,n_elements(yy)-1]
      zreg = [0,n_elements(zz)-1]

      qfactor, xup_bx, yup_by, zup_bz, xreg=xreg, yreg=yreg, zreg=zreg, factor=factor, fstr="qfactor_"+STRTRIM(STRING(snap),2), $
               no_preview=1, nbridges=32, scottFlag=1, /twistFlag, traceFlag=traceFlag, traceint=snap, tol=tol, max_trace_steps=max_trace_steps

   ENDFOR

ENDIF

END
