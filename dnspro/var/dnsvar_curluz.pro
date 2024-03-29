PRO dnsvar_curluz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Vorticity in z-direction: curl(U)z',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_curluz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=-d->getvar(name,snaps,swap=swap)/u.ut
       var_title='!4x!3!dz!n'
       IF (units EQ "solar") THEN var_title=var_title+" (s!u-1!n)"
       var_range=[-100.0,100.0]
       var_log=0
    ENDELSE
END
