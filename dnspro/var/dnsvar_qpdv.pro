PRO dnsvar_qpdv, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Energy due to expansion or compression: -p div U',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_qpdv, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=(d->getvar('divu',snaps,swap=swap))
       var=-d->getvar('p',snaps,swap=swap)*var*u.ue/u.ut
       var_title='Q!dpdv!n'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       ENDIF
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
