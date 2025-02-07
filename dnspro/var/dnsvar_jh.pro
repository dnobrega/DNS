PRO dnsvar_jh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Current density in the horizontal plane: Jh',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=zup(d->getvar('jvx',snaps,swap=swap)*u.ui)
       var=yup(var)^2.0
       var2=zup(d->getvar('jvy',snaps,swap=swap)*u.ui)
       var2=xup(var2)^2.0
       var=sqrt(var+var2)
       var_title="J!dh!n"
       IF (units EQ "solar") THEN var_title=var_title+" (G s!u-1!n)"
       var_range=[1d-8,1d-5]
       var_log=1
    ENDELSE
END
