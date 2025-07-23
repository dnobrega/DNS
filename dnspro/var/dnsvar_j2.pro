PRO dnsvar_j2, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Current density squared: J2',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_j2, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('j2',snaps,swap=swap)*u.ui*u.ui
       var_title="J!u2!n"
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n s!u-2!n)"
       var_range=[1d4, 1d7]
       var_log=1
    ENDELSE
END
