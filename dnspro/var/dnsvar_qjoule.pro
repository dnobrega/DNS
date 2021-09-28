PRO dnsvar_qjoule, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Entropy term due to Jouleer Conductivity: qjoule',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tauqjoule, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('qjoule',snaps,swap=swap)*u.ue/u.ut
       var_title="Q!dJoule!n"
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-0.001, 0.001]
       var_log=0
    ENDELSE
END
