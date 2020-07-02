PRO dnsvar_pt, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Total pressure: Pg + Pb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_pt, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('b2',snaps,swap=swap)/2.0
       pg=d->getvar('pg',snaps,swap=swap)
       var=(var+pg)*u.up
       var_title='P!dt!n'
       IF (units EQ "solar") THEN var_title=var_title+" (Ba)"
       var_range=[1.d-4,1.d8]
       var_log=1
    ENDELSE
END
