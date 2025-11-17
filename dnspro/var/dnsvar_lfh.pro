PRO dnsvar_lfh, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Lorentz force in the horizontal direction: (JxB)h',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfh, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx=(d->getvar('jx',snaps,swap=swap))
       jy=-(d->getvar('jy',snaps,swap=swap))
       jz=-(d->getvar('jz',snaps,swap=swap))

       bx=d->getvar('bx',snaps,swap=swap)
       by=-d->getvar('by',snaps,swap=swap)
       bz=-d->getvar('bz',snaps,swap=swap)

       varx = xup((zup(jy*xdn(bz)) - yup(jz*xdn(by))))
       vary = yup((yup(jz*ydn(bx)) - zup(jx*ydn(bz))))

       var=sqrt(varx*varx+vary*vary)*u.up/u.ul

       var_title="(JxB)!dh!n"
       IF (units EQ "solar") THEN var_title=var_title+" (Ba cm!u-1!n)"
       var_range=[1e-12,1e-7]
       var_log=1
    ENDELSE
END
