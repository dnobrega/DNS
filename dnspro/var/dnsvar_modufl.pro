PRO dnsvar_modufl, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Module of the work by the Lorentz force u dot JxB',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_modufl, d, name, snaps, swap, var, units, ' $
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

       var=abs(ddxup(vari*ux)+ddyup(varj*uy)+ddzup(vark*uz))
       
       var_title='u*(JXB)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[1d-5,1d5]*1d
       var_log=1
    ENDELSE
END