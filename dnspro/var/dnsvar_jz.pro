PRO dnsvar_jz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Current density in the z-direction: Jz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=-d->getvar('jz',snaps,swap=swap)*u.ui
       var_title="J!dz!n"
       IF (units EQ "solar") THEN var_title=var_title+" (G s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
