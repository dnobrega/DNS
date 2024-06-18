PRO dnsvar_lfob2, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Lorentz force: |JxB|/B^2',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfob2, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx=d->getvar('jx',snaps,swap=swap)
       jy=d->getvar('jy',snaps,swap=swap)
       jz=d->getvar('jz',snaps,swap=swap)

       bx=d->getvar('bx',snaps,swap=swap)
       by=d->getvar('by',snaps,swap=swap)
       bz=d->getvar('bz',snaps,swap=swap)

       varx = zup(jy*xdn(bz)) - yup(jz*xdn(by))
       vary = zup(jx*ydn(bz)) - xup(jz*ydn(bx))
       varz = yup(jx*zdn(by)) - xup(jy*zdn(bx))

       var  = sqrt(xup(varx*varx) + yup(vary*vary) + zup(varz*varz))
       bb   = xup(bx*bx) + yup(by*by) + zup(bz*bz)
       var  = var/bb
       var_title="|JxB|/B!u2!n"
       IF (units EQ "solar") THEN BEGIN
          var_title=var_title+" (km!u-1!n)"
          var=var/1e3
       ENDIF
       var_range=[1d-13,1]
       var_log=1
    ENDELSE
END
