PRO dnsvar_lu, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic length of the velocity field: Lu^-1',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ldivb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var  = d->getvar('divu',snaps,swap=swap)
       modu = d->getvar('modu',snaps,swap=swap)
       var  = abs(var)/modu
       var_title='L!du!n!u-1!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km!u-1!n)"
          var=var/1e3
       ENDIF
       var_range=[1d-3,1d3]
       var_log=1
    ENDELSE
END
