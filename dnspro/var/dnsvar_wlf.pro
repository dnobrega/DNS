PRO dnsvar_wlf, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Work by the Lorentz force: v*(JxB)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_wlf, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx=(d->getvar('jx',snaps,swap=swap))
       jy=(d->getvar('jy',snaps,swap=swap))
       jz=(d->getvar('jz',snaps,swap=swap))

       bx=d->getvar('bx',snaps,swap=swap)
       by=d->getvar('by',snaps,swap=swap)
       bz=d->getvar('bz',snaps,swap=swap)

       ux=d->getvar('ux',snaps,swap=swap)
       uy=d->getvar('uy',snaps,swap=swap)
       uz=d->getvar('uz',snaps,swap=swap)

       varx = zup(jy*xdn(bz)) - yup(jz*xdn(by))
       vary = zup(jx*ydn(bz)) - xup(jz*ydn(bx))
       varz = yup(jx*zdn(by)) - xup(jy*zdn(bx))

       var  = xup(varx*ux) + yup(vary*uy) + zup(varz*uz)
       var  = var*u.ue/u.ut
       var_title="u(JxB)"
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1,1]*1e10
       var_log=0
    ENDELSE
END
