PRO dnsvar_eb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Magnetic energy per unit volume: eb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=0.5*d->getvar("b2",snaps,swap=swap)*u.ue
       var_title='eB'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n)"
       var_range=[1.d-2,2.d8]
       var_log=1
    ENDELSE
END
