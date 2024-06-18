PRO dnsvar_lf, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Lorentz force: |JxB|',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lf, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx=(d->getvar('jx',snaps,swap=swap)*u.ub/(u.ul))
       jy=(d->getvar('jy',snaps,swap=swap)*u.ub/(u.ul))
       jz=(d->getvar('jz',snaps,swap=swap)*u.ub/(u.ul))

       bx=d->getvar('bx',snaps,swap=swap)*u.ub
       by=d->getvar('by',snaps,swap=swap)*u.ub
       bz=d->getvar('bz',snaps,swap=swap)*u.ub

       varx = zup(jy*xdn(bz)) - yup(jz*xdn(by))
       vary = zup(jx*ydn(bz)) - xup(jz*ydn(bx))
       varz = yup(jx*zdn(by)) - xup(jy*zdn(bx))

       var  = sqrt(xup(varx*varx) + yup(vary*vary) + zup(varz*varz))

       var_title="|JxB|"
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm!u-1!n)"
       var_range=[1d-13,1]
       var_log=1
    ENDELSE
END
