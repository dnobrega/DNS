PRO dnsvar_eparb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'E parallel to B: eparb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eparb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx  =  xup(d->getvar('bx',snaps,swap=swap))
       by  =  yup(d->getvar('by',snaps,swap=swap))
       bz  =  zup(d->getvar('bz',snaps,swap=swap))
       ex  =  zup(yup(d->getvar('ex',snaps,swap=swap)))
       ey  =  xup(zup(d->getvar('ey',snaps,swap=swap)))
       ez  =  yup(xup(d->getvar('ez',snaps,swap=swap)))
       var = ((ez*bz+ex*bx+ey*by)/sqrt(bx^2+by^2+bz^2))
       var_title='E!d||B!n'
       IF (units EQ "solar") THEN BEGIN
          var = var*u.uel      
          var_title=var_title+" (statV cm!u-1!n)"
       ENDIF
       var_range=[-1.0,1.0]*1d-4
       var_log=0
    ENDELSE
END
