PRO dnsvar_tg, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Temperature: T (K)',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_tg, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=d->getvar(name,snaps,swap=swap)
       var_title='T (K)'
       var_range=[1.d3,2.0d6]
       var_log=1
    ENDELSE
END
