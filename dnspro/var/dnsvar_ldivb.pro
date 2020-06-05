PRO dnsvar_ldivb, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic length of the divergence of the magnetic field: L (Mm^-1)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_ldivb, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       var=d->getvar('modb',snaps,swap=swap)
       var=abs((d->getvar('divb',snaps,swap=swap)))/var
       var_title='L!ddivB!n (Mm!u-1!n)'
       var_range=[1d-3,1d3]
       var_log=1
    ENDELSE
END
