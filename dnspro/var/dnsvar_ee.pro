PRO dnsvar_ee, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Internal energy per mass units: epsilon',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ee, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar(name,snaps,swap=swap)*u.uee
       var_title='!4e!3'
       IF (units EQ "solar") THEN var_title=var_title+" (erg g!u-1!n)"
       var_range=[1.d12,1.d15]
       var_log=1
    ENDELSE
END
