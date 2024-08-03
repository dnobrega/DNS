PRO dnsvar_eperpb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'E perpendicular to B: eperpb',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_eperpb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   =  xup(d->getvar('bx',snaps,swap=swap))
       by   =  yup(d->getvar('by',snaps,swap=swap))
       bz   =  zup(d->getvar('bz',snaps,swap=swap))
       modb =  sqrt(bx^2.0+by^2.0+bz^2.0)
       bx   =  bx/modb
       by   =  by/modb
       bz   =  bz/modb
       ex   =  zup(yup(d->getvar('ex',snaps,swap=swap)))
       ey   =  xup(zup(d->getvar('ey',snaps,swap=swap)))
       ez   =  xup(yup(d->getvar('ez',snaps,swap=swap)))
       ex   =  ex*(1.0-bx)
       ey   =  ey*(1.0-by)
       ez   =  ez*(1.0-bz)
       var  =  sqrt(ex^2.0+ey^2.0+ez^2.0)
       var_title='E!d_|_B!n'
       IF (units EQ "solar") THEN BEGIN
          var = var*u.ul/u.ut*u.ub/3e10        ; light speed in cm/s
          var_title=var_title+" (G)"
       ENDIF
       var_range=[-1.0,1.0]*1d-4
       var_log=0
    ENDELSE
END
