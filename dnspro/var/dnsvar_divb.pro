PRO dnsvar_divb, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the magnetic field: (G Mm^-1)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_divb, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=(d->getvar('divb',snaps,swap=swap))
       var_title='divB (G Mm!u-1!n)'
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
