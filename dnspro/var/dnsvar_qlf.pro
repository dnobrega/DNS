PRO dnsvar_qlf, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Work by the Lorentz force u dot JxB',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ufl, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       jx=d->getvar("jx",snaps,swap=swap)
       jy=d->getvar("jy",snaps,swap=swap)
       jz=d->getvar("jz",snaps,swap=swap)
       
       bx=d->getvar("bx",snaps,swap=swap)
       by=d->getvar("by",snaps,swap=swap)
       bz=d->getvar("bz",snaps,swap=swap)

       ux=zup(jy*xdn(bz)) - yup(jz*xdn(by))
       uy=xup(jz*ydn(bx)) - zup(jx*ydn(bz))
       uz=yup(jx*zdn(by)) - xup(jy*zdn(bx))

       ux=(d->getvar("ux",snaps,swap=swap))*ux
       uy=(d->getvar("uy",snaps,swap=swap))*uy
       uz=(d->getvar("uz",snaps,swap=swap))*uz

       var=(xup(ux)+yup(uy)+zup(uz))*u.ue/u.ut
       var_title='u*(JXB)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
