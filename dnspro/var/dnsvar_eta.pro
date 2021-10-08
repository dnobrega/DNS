PRO dnsvar_eta, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Estimation of the diffusion coefficient: eta',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eta, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       qjoule=d->getvar('qjoule',snaps,swap=swap);*u.ue/u.ut
       var=d->getvar('iy',snaps,swap=swap)
       var=var*var
       var=(qjoule/var)*u.ul*u.ul/u.ut
       var_title="eta"
       IF (units EQ "solar") THEN var_title=var_title+" (km!u2!n s!u-1!n)"
       var_range=[1d-5, 1d5]
       var_log=1
    ENDELSE
END
