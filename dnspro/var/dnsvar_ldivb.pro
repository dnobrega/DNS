PRO dnsvar_ldivb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic length of the divergence of the magnetic field: Lb^-1',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ldivb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('modb',snaps,swap=swap)
       var=abs((d->getvar('divb',snaps,swap=swap)))/var
       var_title='L!ddivB!n!u-1!n'
       IF (units EQ "solar") THEN var_title=var_title+" (Mm!u-1!n)"
       var_range=[1d-3,1d3]
       var_log=1
    ENDELSE
END
