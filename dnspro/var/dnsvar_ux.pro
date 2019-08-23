PRO dnsvar_ux, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity in x-direction: Ux (km/s)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_ux, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar(name,snaps,swap=swap)*10.
       var_title='u!dx!n (km s!u-1!n)'
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
