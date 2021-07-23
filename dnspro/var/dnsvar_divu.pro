PRO dnsvar_divu, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the velocity field: div U',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_divu, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=(d->getvar('divu',snaps,swap=swap))/u.ut
       var_title='divU'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (s!u-1!n)"
       ENDIF
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
