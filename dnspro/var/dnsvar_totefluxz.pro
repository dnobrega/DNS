PRO dnsvar_totefluxz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Internal+kinetic+worky by pressure energy flux in z-direction: F_E',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_totefluxz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("e",snaps,swap=swap)*u.ue
       var=d->getvar("pg",snaps,swap=swap)*u.ue + var
       r=d->getvar("r",snaps,swap=swap)*u.ur
       u2=d->getvar("u2",snaps,swap=swap)*u.uu*u.uu
       var=0.5*r*u2 + var
       uz=-d->getvar("uz",snaps,swap=swap)*u.ul/u.ut
       var=zdn(var)*uz
       var_title='F!dEz!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (erg cm!u-3!n cm s!u-1!n)"
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
