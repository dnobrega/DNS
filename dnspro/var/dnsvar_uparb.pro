PRO dnsvar_uparb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity parallel to B: Uparb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uparb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  =  d->getvar('bx',snaps,swap=swap)
       by  = -d->getvar('by',snaps,swap=swap)
       bz  = -d->getvar('bz',snaps,swap=swap)
       ux  =  d->getvar('ux',snaps,swap=swap)
       uy  = -d->getvar('uy',snaps,swap=swap)
       uz  = -d->getvar('uz',snaps,swap=swap)
       var = ( (zup(uz*bz)+xup(ux*bx)+yup(uy*by))/sqrt(xup(bx)^2+yup(by)^2+zup(bz)^2))*u.ul/u.ut
       var_title='u!d||B!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
