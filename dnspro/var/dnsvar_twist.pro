PRO dnsvar_twist, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, ' twist = (J dot B) / (|B||B|)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_twist, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   = xup(d->getvar('bx',snaps,swap=swap))
       by   = yup(d->getvar('by',snaps,swap=swap))
       bz   = zup(d->getvar('bz',snaps,swap=swap))
       b2   = bx^2 + by^2 + bz^2
       jx   = yup(d->getvar('jx',snaps,swap=swap))
       jx   = zup(jx)
       jy   = zup(d->getvar('jy',snaps,swap=swap))
       jy   = xup(jy)
       jz   = xup(d->getvar('jz',snaps,swap=swap))
       jz   = yup(jz)
       var = abs(jz*bz + jx*bx + jy*by)/b2
       var_title='Q!dtwist!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km!u-1!n)"
          var=var/1e3
       ENDIF
       var_range=[1d-6,1d-2]
       var_log=1
    ENDELSE
END
