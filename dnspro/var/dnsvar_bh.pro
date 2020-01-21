PRO dnsvar_bh, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Horizontal magnetic field: |Bh| (G)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_bh, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar(name,snaps,swap=swap)*units.ub
       var_title='|B!dh!n| (G)'
       var_range=[1d-1,1d3]
       var_log=1
    ENDELSE
END
