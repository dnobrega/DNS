PRO dnsvar_qspitz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Entropy term due to Spitzer Conductivity: qspitz',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_qspitz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('qspitz',snaps,swap=swap)*u.ue/u.ut
       var_title="Q!dSpitz!n"
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-0.001, 0.001]
       var_log=0
    ENDELSE
END
