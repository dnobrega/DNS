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
       
       bx=d->getvar("bx",snaps,swap=swap)
       by=d->getvar("by",snaps,swap=swap)
       bz=d->getvar("bz",snaps,swap=swap)

       ux=d->getvar("ux",snaps,swap=swap)
       uy=d->getvar("uy",snaps,swap=swap)
       uz=d->getvar("uz",snaps,swap=swap)

       jx=d->getvar("jx",snaps,swap=swap)
       jy=d->getvar("jy",snaps,swap=swap)
       jz=d->getvar("jz",snaps,swap=swap)
       
       ex = (- zdn(uy)*ydn(bz) + ydn(uz)*zdn(by) )*jx
       ex = zup(ex)
       ey = (- xdn(uz)*zdn(bx) + zdn(ux)*xdn(bz) )*jy
       ey = xup(ey)
       ez = (- ydn(ux)*xdn(by) + xdn(uy)*ydn(bx) )*jz
       ez = yup(ez)
      
       var = (yup(ex) + zup(ey) + xup(ez))*u.ue/u.ut

       var_title='u*(JXB)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
