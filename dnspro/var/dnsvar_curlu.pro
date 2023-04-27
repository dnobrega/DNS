PRO dnsvar_curlu, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Vorticity: curl(U)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_curlu, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       varx=zup(yup(d->getvar("curlux",snaps,swap=swap)))
       vary=xup(zup(d->getvar("curluy",snaps,swap=swap)))
       varz=yup(xup(d->getvar("curluz",snaps,swap=swap)))
       var = sqrt(varx*varx + vary*vary + varz*varz)/u.ut
       var_title='!4x!3'
       IF (units EQ "solar") THEN var_title=var_title+" (s!u-1!n)"
       var_range=[1d-2,10]
       var_log=1
    ENDELSE
END
