PRO dnsvar_gradpghor, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Acceleration due to gas pressure gradient in the horizontal direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_gradpghor, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       pg   = d->getvar('p',snaps,swap=swap)
       var1 = xup(ddxdn(pg))           
       var2 = yup(ddydn(pg))
       r    = d->getvar('r',snaps,swap=swap)
       var  = sqrt(var1*var1 + var2*var2)/r*u.ul/u.ut/u.ut
       var_title='|dP!dg!n/dH|/!4q!3' 
       IF (units EQ "solar") THEN BEGIN
          var=var/1e5
          var_title=var_title+" (km s!u-2!n)"
       ENdif
       var_range=[1,100]
       var_log=1
    ENDELSE
END
