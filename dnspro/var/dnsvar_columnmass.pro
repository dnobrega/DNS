PRO dnsvar_columnmass, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Column mass: int (rho dz)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_columnmass, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar("r",snaps,swap=swap)*u.ur
       d->readpars, snaps
       d->readmesh
       dz  = d->getdz1d()*1e8
       nelz = n_elements(dz)
       FOR k=0,nelz-1 DO var(*,*,k)=var(*,*,k)*dz(k)
       var = total(var[*, *, *], 3, /cumulative)
       var_title='Column mass'
       IF (units EQ "solar") THEN var_title=var_title+" (g cm!u-2!n)"
       var_range=[1.d-5,1.d1]
       var_log=1
    ENDELSE
END
