PRO dnsvar_n4, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'H I level 3 number density from HION compuation: n4',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_n4, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar("n4",snaps,swap=swap)    ; cm^-3
       var_title='n!dH I 3!n'
       IF (units EQ "solar") THEN var_title=var_title+" (cm!u-3!n)"
       var_range=[1.d4,1d12]
       var_log=1
    ENDELSE
END
