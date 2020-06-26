PRO dnsvar_pg, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Gas pressure: Pg',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_pg, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('p',snaps,swap=swap)*u.up
       var_title='P!dg!n'
       IF (units EQ "solar") THEN var_title=var_title+" (Ba)"
       var_range=[1.d-4,1.d8]
       var_log=1
    ENDELSE
END
