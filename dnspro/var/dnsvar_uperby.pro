PRO dnsvar_uperby, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, '(UxB)y/B: uperby',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uperby, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   = xup(d->getvar('bx',snaps,swap=swap))
       by   = yup(d->getvar('by',snaps,swap=swap))
       bz   = zup(d->getvar('bz',snaps,swap=swap))
       temp = sqrt(bx^2.0 + by^2.0+ bz^2.0)
       ux   = yup(d->getvar('ux',snaps,swap=swap))
       uz   = zup(d->getvar('uz',snaps,swap=swap))
       var  = ((uz*bx - ux*bz)/temp)
       var  = ydn(var)*u.ul/u.ut
       var_title='(uxB)!dy!n/B'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km s!u-1!n)"
          var=var/1e5
       ENDIF
       var_range=[-5,5]
       var_log=0
    ENDELSE
END
