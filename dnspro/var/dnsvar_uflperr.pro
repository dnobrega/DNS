PRO dnsvar_uflperr, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Work by the Lorentz force u dot JxB per particle',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_uflperr, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       jx=d->getvar("jx",snaps,swap=swap)*u.ub/u.ul
       jy=d->getvar("jy",snaps,swap=swap)*u.ub/u.ul
       jz=d->getvar("jz",snaps,swap=swap)*u.ub/u.ul
       
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       by=d->getvar("by",snaps,swap=swap)*u.ub
       bz=d->getvar("bz",snaps,swap=swap)*u.ub

       vari=zdn(jy)*bz-ydn(jz)*by
       varj=xdn(jz)*bx-zdn(jx)*bz
       vark=ydn(jx)*by-xdn(jy)*bx

       ux=d->getvar("ux",snaps,swap=swap)*u.uu
       uy=d->getvar("uy",snaps,swap=swap)*u.uu
       uz=d->getvar("uz",snaps,swap=swap)*u.uu

       r=d->getvar("r",snaps,swap=swap)*u.ur
       
       var=(ddxup(vari*ux)+ddyup(varj*uy)+ddzup(vark*uz))
       var=var/r
       
       var_title='u*(JXB)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg g!u-1!n s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
