PRO dnsvar_bz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Magnetic field in z-direction: Bz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_bz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=-d->getvar(name,snaps,swap=swap)*u.ub
       var_title='B!dz!n'
       IF (units EQ "solar") THEN var_title=var_title+" (G)"
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
