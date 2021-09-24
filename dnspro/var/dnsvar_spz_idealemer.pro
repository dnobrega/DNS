PRO dnsvar_spz_idealemer, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Module of the Poynting flux only emergence in the vertical direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spz_idealemer, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       uz=-d->getvar("uz",snaps,swap=swap)*u.uu
       b2=d->getvar("b2",snaps,swap=swap)*u.ub*u.ub
       var=zup(uz)*b2

       var_title='S!dpz ideal,emer!n'
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
