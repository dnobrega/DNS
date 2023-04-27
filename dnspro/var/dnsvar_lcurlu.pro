PRO dnsvar_lcurlu, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic length of the vorticity: curl(U)/U',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_Lcurlu, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var = d->getvar("modu",snaps,swap=swap)
       varx=zup(yup(d->getvar("curlux",snaps,swap=swap)))
       vary=xup(zup(d->getvar("curluy",snaps,swap=swap)))
       varz=yup(xup(d->getvar("curluz",snaps,swap=swap)))
       var = (sqrt(varx*varx + vary*vary + varz*varz)/var)
       var_title='L!du!n!u-1!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km!u-1!n)"
          var=var/1e3
       ENDIF
       var_range=[1d-2,10]
       var_log=1
    ENDELSE
END
