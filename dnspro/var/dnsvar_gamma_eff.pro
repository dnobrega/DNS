PRO dnsvar_gamma_eff, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Effective Gamma',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_gamma_check, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("e",snaps,swap=swap)
       var=d->getvar("p",snaps,swap=swap)/var+1
       var_title='!4c!3!deff!n'
       var_range=[1.0,1.7]
       var_log=0
    ENDELSE
END
