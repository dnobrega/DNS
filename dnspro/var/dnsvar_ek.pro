PRO dnsvar_ek, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Kinetic energy per unit volume: ek',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ek, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=d->getvar("r",snaps,swap=swap)*u.ur
       var=0.5*var*(d->getvar("u2",snaps,swap=swap))*u.uu*u.uu
       var_title='eK'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n)"
       var_range=[1.d-2,2.d8]
       var_log=1
    ENDELSE
END
