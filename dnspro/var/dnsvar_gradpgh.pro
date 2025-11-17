PRO dnsvar_gradpgh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Gas pressure gradient in the horizontal direction: gradPgh',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_gradpgh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       pg=d->getvar('p',snaps,swap=swap)
       var1=xup(ddxdn(pg))           
       var2=yup(ddydn(pg))
       var = sqrt(var1*var1 + var2*var2)*u.up/u.ul
       var_title='|dP!dg!n/dH|' 
       IF (units EQ "solar") THEN var_title=var_title+" (Ba cm!u-1!n)"
       var_range=[1e-12,1e-7]
       var_log=1
    ENDELSE
END
