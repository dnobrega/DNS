PRO dnsvar_uperb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Velocity perpendicular to B: Uperb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uperb, d, name, snaps, swap, var, units, ' $
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
       temp = sqrt(xup(bx)^2.0+yup(by)^2.0+zup(bz)^2.0)
       varx = xup(ux - ux*bx/xdn(temp))
       vary = yup(uy - uy*by/ydn(temp))
       varz = zup(uz - uz*bz/zdn(temp))
       var = sqrt(varx^2.0 + vary^2.0 + varz^2.0)*u.ul/u.ut
       var_title='u!dperpB!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[5d,1d2]
       var_log=1
    ENDELSE
END
