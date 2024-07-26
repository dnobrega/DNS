PRO dnsvar_bxob, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Normalized magnetic field in x-direction: Bx/B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_bxob, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=xup(d->getvar('bx',snaps,swap=swap))
       var=var/(d->getvar("modb",snaps,swap=swap))
       var_title='B!dx!n/B'
       var_range=[-5.0,5.0]
       var_log=0
    ENDELSE
END
