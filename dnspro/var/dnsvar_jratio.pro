PRO dnsvar_jratio, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Ratio between horizontal and vertical componente of the current density: rJ',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_jh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       var=zup(d->getvar('jvx',snaps,swap=swap))
       var=yup(var)^2.0
       var2=zup(d->getvar('jvy',snaps,swap=swap))
       var2=xup(var2)^2.0
       var=var+var2
       var1=xup(d->getvar('jvz',snaps,swap=swap))
       var1=yup(var1)^2.0
       var=(var1-var)/(var1+var)
       var_title="r!dJ!n"
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
