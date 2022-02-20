PRO dnsvar_uzparb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity in z-direction parallel to B: Uzparb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uzparb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  =  d->getvar('bx',snaps,swap=swap)
       by  =  d->getvar('by',snaps,swap=swap)
       bz  = -d->getvar('bz',snaps,swap=swap)
       uz  = -d->getvar('uz',snaps,swap=swap)
       var = (zup(uz*bz)/sqrt(xup(bx)^2+yup(by)^2+zup(bz)^2))*u.ul/u.ut
       var_title='u!dz||B!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
