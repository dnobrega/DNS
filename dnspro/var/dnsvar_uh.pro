PRO dnsvar_uh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity in the horizontal-direction: Uh',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ux, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=(xup(d->getvar("ux",snaps,swap=swap)*u.ul/u.ut))^2.0
       var=sqrt(var + (yup(d->getvar("uy",snaps,swap=swap)*u.ul/u.ut))^2.0)
       var_title='u!dh!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[0.1,100.0]
       var_log=1
    ENDELSE
END
