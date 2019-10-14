PRO dnsvar_beta, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Plasma beta: !4b!3',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_modb, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=d->getvar(name,snaps,swap=swap)
       var_title='!4b!3'
       var_range=[1d-3,1d3]
       var_log=1
    ENDELSE
END
