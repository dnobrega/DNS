PRO dnsvar_abseparb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'abs(E parallel to B): abseparb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eparb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  =  d->getvar('bx',snaps,swap=swap)
       by  =  d->getvar('by',snaps,swap=swap)
       bz  =  d->getvar('bz',snaps,swap=swap)
       ux  =  d->getvar('ex',snaps,swap=swap)
       uy  =  d->getvar('ey',snaps,swap=swap)
       uz  =  d->getvar('ez',snaps,swap=swap)
       var = abs(((zup(uz*bz)+xup(ux*bx)+yup(uy*by))/sqrt(xup(bx)^2+yup(by)^2+zup(bz)^2)))
       var_title='|E!d||B!n|'
       IF (units EQ "solar") THEN BEGIN
          var = var*u.ul/u.ut*u.ub/3e10
          var_title=var_title+" (G)"
       ENDIF
       var_range=[1e-2,1e-4]
       var_log=1
    ENDELSE
END