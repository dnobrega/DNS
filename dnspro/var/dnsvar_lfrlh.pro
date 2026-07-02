PRO dnsvar_lfrlh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Ration betweeen the horizontal component of the tension and magntic pressure',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfrlh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx=d->getvar('bx',snaps,swap=swap)
       by=d->getvar('by',snaps,swap=swap)
       bz=d->getvar('bz',snaps,swap=swap)

       varx = xup(bx)*ddxup(bx)
       vary = yup(by)*ddyup(by)
       var1 = sqrt(varx*varx+vary*vary)
       
       var   = (xup(bx*bx) + yup(by*by) + zup(bz*bz))/2.0
       varx  = xup(ddxdn(var))
       vary  = yup(ddydn(var))       
       var2  = sqrt(varx*varx+vary*vary)

       var   = (var1 - var2)/(var1+var2)
       
       var_title="R!dL,h!n"
       var_range=[-1,1]
       var_log=0
    ENDELSE
END
