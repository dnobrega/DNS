PRO dnsvar_gradpgz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Gas pressure gradient along Z: gradPgz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_gradpgz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('p',snaps,swap=swap)*u.up
       var=ddzdn(var)/u.ul      
       var_title='-dP!dg!n/dz' ; The sign is to ease the comparison with the Lorentz Force
       IF (units EQ "solar") THEN var_title=var_title+" (Ba cm!u-1!n)"
       var_range=[-1e-7,1e-7]
       var_log=0
    ENDELSE
END
