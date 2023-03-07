PRO dnsvar_nelfluxz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Flux of the electron number density from LTE compuations in the z-direction: nelfluxz',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nelflux, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("nel",snaps,swap=swap) ; Already in cm-3 from Bifrost
       uz=-d->getvar("uz",snaps,swap=swap)*u.ul/u.ut
       var=zdn(var)*uz
       var_title='Fne!dz!n'
       IF (units EQ "solar") THEN var_title=var_title+" (cm!u-2!n s!u-1!n)"
       var_range=[-1d8,1d8]
       var_log=0
    ENDELSE
END
