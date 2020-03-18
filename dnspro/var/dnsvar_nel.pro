PRO dnsvar_nel, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Electron number density from LTE compuations: nel (cm-3)',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_nel, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=d->getvar(name,snaps,swap=swap)
       var_title='n!de!n (cm!u-3!n)'
       var_range=[1.d4,1d12]
       var_log=1
    ENDELSE
END
