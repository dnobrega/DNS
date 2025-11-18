PRO dnsvar_lfay, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Acceleration due to Lorentz force in the Y direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfay, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = -(d->getvar('lfay',snaps,swap=swap))*u.ul/u.ut/u.ut
       var_title="aLfy"
       IF (units EQ "solar") THEN BEGIN
          var = var/1e5
          var_title=var_title+" (km s!u-2!n)"
       ENDIF
       var_range=[-100,100]
       var_log=0
    ENDELSE
END
