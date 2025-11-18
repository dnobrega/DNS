PRO dnsvar_hpg, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Scale height H',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_hpg, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('p',snaps,swap=swap)
       var=var/(2.74*(d->getvar('r',snaps,swap=swap)))
       var_title='H!dPg!n'
       IF (units EQ "solar") THEN var_title=var_title+" (Mm)"
       var_range=[1.d-4,1.d8]
       var_log=1
    ENDELSE
END
