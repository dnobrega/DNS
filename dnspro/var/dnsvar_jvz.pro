PRO dnsvar_jvz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEZWORD_SET(info) THEN BEGIN
       message, 'Absolute value of the current density in the z-direction: Jvz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jvz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('jvz',snaps,swap=swap)*u.ub/(u.ul)
       var_title="|J!dz!n|"
       IF (units EQ "solar") THEN var_title=var_title+" (G cm!u-1!n)"
       var_range=[1d-6,1d-2]
       var_log=1
    ENDELSE
END
