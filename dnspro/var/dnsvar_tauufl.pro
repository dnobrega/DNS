PRO dnsvar_tauufl, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Characteristic time of the work by the Lorentz force u dot JxB',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tauufl, d, name, snaps, swap, var, units, ' $
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

       vari=zdn(ey)*bz-ydn(ez)*by
       varj=xdn(ez)*bx-zdn(ex)*bz
       vark=ydn(ex)*by-xdn(ey)*bx

       ux=d->getvar("ux",snaps,swap=swap)*u.uu
       uy=d->getvar("uy",snaps,swap=swap)*u.uu
       uz=d->getvar("uz",snaps,swap=swap)*u.uu

       var=(ddxup(vari*ux)+ddyup(varj*uy)+ddzup(vark*uz))

       e=d->getvar("e",snaps,swap=swap)*u.ue
       var=e/ABS(var + 1d-30)

       
       var_title='!4s!3!duFl!n'
       IF (units EQ "solar") THEN var_title=var_title+" (s)"
       var_range=[1d-1,1.d3]
       var_log=1
    ENDELSE
END
