PRO dnsvar_thetajb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, ' theta = arccos(J dot B / |J||B|)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_thetajb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx   = xup(d->getvar('bx',snaps,swap=swap))
       by   = yup(d->getvar('by',snaps,swap=swap))
       bz   = zup(d->getvar('bz',snaps,swap=swap))
       modb = sqrt(bx^2 + by^2 + bz^2)
       jx   = yup(d->getvar('jx',snaps,swap=swap))
       jx   = zup(jx)
       jy   = zup(d->getvar('jy',snaps,swap=swap))
       jy   = xup(jy)
       jz   = xup(d->getvar('jz',snaps,swap=swap))
       jz   = yup(jz)
       modj = sqrt(jx^2 + jy^2 + jz^2)
       var = abs(jz*bz + jx*bx + jy*by)/(modj*modb)
       var = (180/!PI)*acos(var)
       var_title='(180/pi)*arccos(| J dot B |/ |J||B|)'
       var_range=[0,90]
       var_log=0
    ENDELSE
END
