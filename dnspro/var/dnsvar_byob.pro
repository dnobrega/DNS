PRO dnsvar_byob, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Normaliyed magnetic field in y-direction: By/B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_byob, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=-yup(d->getvar('by',snaps,swap=swap))
       var=var/(d->getvar("modb",snaps,swap=swap))
       var_title='B!dy!n/B'
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
