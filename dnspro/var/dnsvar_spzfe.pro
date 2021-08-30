PRO dnsvar_spzfe, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Vertical Poynting flux',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_by, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=-d->getvar(name,snaps,swap=swap)*u.ub*u.ub*u.uu
       var_title='S!dv!n'
       IF (units EQ "solar") THEN var_title=var_title+" (CGS)"
       var_range=[-1.0,1.0]*1d7
       var_log=0
    ENDELSE
END
