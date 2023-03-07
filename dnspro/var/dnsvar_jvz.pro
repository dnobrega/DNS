PRO dnsvar_jvz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Absolute value of the current density in the z-direction: Jvz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jvz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=xup(d->getvar('jvz',snaps,swap=swap)*u.ub/(u.ul))
       var=yup(var)
       var(where(var lt 0))=0.0
       var_title="|J!dz!n|"
       IF (units EQ "solar") THEN var_title=var_title+" (G cm!u-1!n)"
       var_range=[1d-8,1d-5]
       var_log=1
    ENDELSE
END
