PRO dnsvar_bvx, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Absolute value of the magnetic field in x-direction: |Bx|',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_bvx, d, name, snaps, swap, var, units,' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar(name,snaps,swap=swap)*u.ub
       var_title='|B!dx!n|'
       IF (units EQ "solar") THEN var_title=var_title+" (G)"
       var_range=[1d-4,1d4]
       var_log=1
    ENDELSE
END
