PRO dnsvar_ztg1e5, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'min z where T is 1e5 K',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ztg1e5, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar("tg",snaps,swap=swap)
       d->readpars, snaps
       d->readmesh
       dz  = d->getdz1d()*1e8
       z   = -d->getz()
       x   = d->getx()
       y   = d->gety()
       nelz = n_elements(dz)
       nelx = n_elements(x)
       nely = n_elements(y)
       value = 1e5           
       zz    = fltarr(nelx,nely,nelz)
       FOR i=0, nelx-1 DO BEGIN
          FOR j=0, nely-1 DO BEGIN
             zz[i,j,*] = interpol(z, var(i,j,*), value) 
          ENDFOR
       ENDFOR
       var = zz
       var_title='z [at T = 10!u5!n K]'
       IF (units EQ "solar") THEN var_title=var_title+" (Mm)"
       var_range=[1.0,3.0]
       var_log=0
    ENDELSE
END
