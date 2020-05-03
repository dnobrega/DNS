PRO dnsvar_tau500, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Optical depth at lambda=500 mm: tau',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_tau500, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=d->getvar('tau',snaps,swap=swap)
       var_title='!4s!3'
       var_range=[1d-3,1d3]
       var_log=1
    ENDELSE
END
