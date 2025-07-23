PRO dnsvar_jx2, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Square value of the current density in the x-direction: Jx2',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jx2, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=(d->getvar('jx',snaps,swap=swap)*u.ui)^2.0
       var_title="J!dx!n!u2!n"
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n s!u-2!n)"
       var_range=[1d-8,1d-2]
       var_log=1
    ENDELSE
END
