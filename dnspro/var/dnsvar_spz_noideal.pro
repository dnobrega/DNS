PRO dnsvar_spz_noideal, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Noideal part of the Poynting flux in the z-direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spz_noideal, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ex=d->getvar("etax",snaps,swap=swap)
       ey=d->getvar("etay",snaps,swap=swap)
       
       bx=d->getvar("bx",snaps,swap=swap)
       by=d->getvar("by",snaps,swap=swap)

       ex = ex*zdn(by)
       ey = ey*zdn(bx)
       
       var= - ( yup(ex) - xup(ey))*u.ue*u.ul/u.ut  ; in the z face
       var_title='S!dpz noideal!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
