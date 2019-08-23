PRO dnsvar_bx, d, name, snaps, swap, var, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Magnetic field in x-direction: Bx (G)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 5 THEN BEGIN
          message,'dnsvar_bx, d, name, snaps, swap, var' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       UNITS, units
       var=d->getvar(name,snaps,swap=swap)*units.ub
       IF (NOT (KEYWORD_SET(var_title))) var_title='B!dx!n (G)'
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
