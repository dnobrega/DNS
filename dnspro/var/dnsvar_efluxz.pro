PRO dnsvar_efluxz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Internal energy flux in z-direction: F_e',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_efluxz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("e",snaps,swap=swap)*u.ue
       uz=-d->getvar("uz",snaps,swap=swap)*u.ul*u.ut
       var=var*uz
       var_title='Fe!dz!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (erg cm!u-3!n cm s!u-1!n)"
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
