PRO dnsvar_tauqlyaqhh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic time of qlya-qhh (Eq. 16 Golding et al. 2016): tau_qlyaqhh',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tauqlyaqhh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('qlya',snaps,swap=swap)
       var=var - d->getvar('qhh',snaps,swap=swap)
       e=d->getvar('e',snaps,swap=swap) 
       var=ABS(e/(var + 1d-30))*u.ut
       var_title='!4s!3!dLya!n'
       IF (units EQ "solar") THEN var_title=var_title+" (s)"
       var_range=[-1d3, 1.d3]
       var_log=0
    ENDELSE
END
