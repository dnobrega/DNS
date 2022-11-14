PRO dnsvar_jx, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Current density in the x-direction: Jx',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jx, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('jx',snaps,swap=swap)*u.ub/(u.ul)
       var_title="J!dx!n"
       IF (units EQ "solar") THEN var_title=var_title+" (G cm!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
