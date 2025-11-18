PRO dnsvar_gradpgxor, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Acceleration due to gas pressure gradient along X',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_gradpgxor, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar('p',snaps,swap=swap)
       r   = xdn(d->getvar('r',snaps,swap=swap))
       var = -ddxdn(var)/r*u.ul/u.ut/u.ut
       var_title='-dP!dg!n/dx/!4q!3' ; The sign is to ease the comparison with the Lorentz Force
       IF (units EQ "solar") THEN BEGIN
          var = var/1e5
          var_title=var_title+" (km s!u-2!n)"
       ENDIF
       var_range=[1,100]
       var_log=0
    ENDELSE
END
