PRO dnsvar_uzperb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity in z-direction perpendicular to B: Uzperb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uzperb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  =  d->getvar('bx',snaps,swap=swap)
       by  = -d->getvar('by',snaps,swap=swap)
       bz  = -d->getvar('bz',snaps,swap=swap)
       uz  = -d->getvar('uz',snaps,swap=swap)
       var = zup(uz)*(1 - (zup(bz)/sqrt(xup(bx)^2+yup(by)^2+zup(bz)^2)))*u.ul/u.ut
       var_title='u!dz!9x!3B!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
