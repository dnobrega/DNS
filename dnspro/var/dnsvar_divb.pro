PRO dnsvar_divb, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the magnetic field: div B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_divb, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=(d->getvar('divb',snaps,swap=swap))*u.ub/u.ul
       var_title='divB'
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (G Mm!u-1!n)"
          var=var*u.ul
       ENDIF
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
