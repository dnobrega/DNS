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
       
       bx=xup(d->getvar("bx",snaps,swap=swap))
       by=yup(d->getvar("by",snaps,swap=swap))
       bz=zup(d->getvar("bz",snaps,swap=swap))

       rr=d->getvar("r",snaps,swap=swap)
       ux=xup(d->getvar("px",snaps,swap=swap))/rr
       uy=yup(d->getvar("py",snaps,swap=swap))/rr
       uz=zup(d->getvar("pz",snaps,swap=swap))/rr

       jx=yup(d->getvar("jx",snaps,swap=swap))
       jy=zup(d->getvar("jy",snaps,swap=swap))
       jz=xup(d->getvar("jz",snaps,swap=swap))
       
       var = -(zup(jx)*(uy*bz - uz*by) + xup(jy)*(uz*bx-ux*bz) + yup(jz)*(ux*by-uy*bx))*u.ue/u.ut

       var_title='u*(JXB)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
