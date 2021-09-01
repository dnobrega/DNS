PRO dnsvar_tauqh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic time of the hydrogen losses: tau_qh',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tauqh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('qh',snaps,swap=swap)
       e=d->getvar('e',snaps,swap=swap) 
       var=ABS(e/(var + 1d-30))*u.ut
       var_title='!4s!3!dh!n'
       IF (units EQ "solar") THEN var_title=var_title+" (s)"
       var_range=[1d-1, 1.d3]
       var_log=1
    ENDELSE
END
