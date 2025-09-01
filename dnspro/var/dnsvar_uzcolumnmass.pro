PRO dnsvar_uzcolumnmass, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'uz Column mass: int (rho dz)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uzcolumnmass, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar("r",snaps,swap=swap)*u.ur
       uz  = -d->getvar("uz",snaps,swap=swap)*u.ul/u.ut
       d->readpars, snaps
       d->readmesh
       dz  = d->getdz1d()*1e8
       z   = -d->getz()
       x   = d->getx()
       y   = d->gety()
       nelz = n_elements(dz)
       nelx = n_elements(x)
       nely = n_elements(y)
       FOR k=0,nelz-1 DO var(*,*,k)=var(*,*,k)*dz(k)
       var = total(var[*, *, *], 3, /cumulative)
       value = 3e-5             ;g cm-2
       ir    = 1
       zz    = fltarr(nelx,nely,nelz)
       FOR i=0, nelx-1 DO BEGIN
          FOR j=0, nely-1 DO BEGIN
             ind  = max(where(var(i,j,*) le value))
             zz[i,j,*] = uz[i,j,ind]
          ENDFOR
       ENDFOR
       var = zz
       var_title='u!dz!n [at Column mass = 3e-5 g cm!u-2!n]'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[-12,12]
       var_log=0
    ENDELSE
END
