PRO dnsvar_jvy, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Absolute value of the current density in the y-direction: Jvy',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jvy, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=xup(d->getvar('jvy',snaps,swap=swap))*u.ui
       var=zup(var)
       var(where(var lt 0))=0.0
       var_title="|J!dy!n|"
       IF (units EQ "solar") THEN var_title=var_title+" (G s!u-1!n)"
       var_range=[1d-8,1d-2]
       var_log=1
    ENDELSE
END
