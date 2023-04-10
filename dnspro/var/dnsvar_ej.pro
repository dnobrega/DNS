PRO dnsvar_ej, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'E·J',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_ej, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       jx=d->getvar("jx",snaps,swap=swap)
       jy=d->getvar("jy",snaps,swap=swap)
       jz=d->getvar("jz",snaps,swap=swap)
       
       ex=d->getvar("ex",snaps,swap=swap)
       ey=d->getvar("ey",snaps,swap=swap)
       ez=d->getvar("ez",snaps,swap=swap)

       jx=yup(jx*ex)
       jy=zup(jy*ey)
       jz=xup(jz*ez)

       var=(zup(jx)+xup(jy)+yup(jz))*u.ue/u.ut
       var_title='E J'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1,1]*1d-2
       var_log=0
    ENDELSE
END
