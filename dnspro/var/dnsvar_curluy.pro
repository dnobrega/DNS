PRO dnsvar_curluy, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Vorticity in y-direction: curl(U)y (1/s)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_curluy, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=-d->getvar(name,snaps,swap=swap)*units.ut
       var_title='!4x!3!dy!n (s!u-1!n)'
       var_range=[-100.0,100.0]
       var_log=0
    ENDELSE
END
