PRO dnsvar_qviscor, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Entropy term due to Visc heating per gram: qviscor',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_qviscor, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar('qvisc',snaps,swap=swap)*u.ue/u.ut
       var=var/(d->getvar('r',snaps,swap=swap)*u.ur)
       var_title="Q!dVisc!n/!4q!3"
       IF (units EQ "solar") THEN var_title=var_title+" (erg g!u-1!n s!u-1!n)"
       var_range=[1d-5, 1d5]
       var_log=1
    ENDELSE
END
