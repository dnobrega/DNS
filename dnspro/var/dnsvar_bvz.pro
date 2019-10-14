PRO dnsvar_bvz, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Absolute value of the magnetic field in y-direction: |Bz| (G)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_by, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar(name,snaps,swap=swap)*units.ub
       var_title='|B!dz!n| (G)'
       var_range=[1d-4,1d4]
       var_log=1
    ENDELSE
END
