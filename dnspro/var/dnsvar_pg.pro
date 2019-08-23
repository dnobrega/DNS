PRO dnsvar_pg, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Gas pressure: Pg (Ba)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_pg, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar('p',snaps,swap=swap)*units.up
       var_title='P!dg!n (Ba)'
       var_range=[1.d-4,1.d8]
       var_log=1
    ENDELSE
END
