PRO dnsvar_px, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Momentum in x-direction: px',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_px, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar(name,snaps,swap=swap)*u.ur*u.ul/u.ut
       var_title='p!dx!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (g cm!u-2!n s!u-1!n)"
       ENDIF
       var_range=[-1.0,1.0]
       var_log=0
    ENDELSE
END
