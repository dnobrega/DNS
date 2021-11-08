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
       
       ex=d->getvar("etax",snaps,swap=swap)*u.uu*u.ub
       ey=d->getvar("etay",snaps,swap=swap)*u.uu*u.ub
       
       bx=d->getvar("bx",snaps,swap=swap)*u.ub
       by=d->getvar("by",snaps,swap=swap)*u.ub

       ex = ex*zdn(by)
       ey = ey*zdn(bx)
       var= - ( yup(ex) - xup(ey)) ; in the z face

       var_title='S!dpz noideal!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n cm s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
