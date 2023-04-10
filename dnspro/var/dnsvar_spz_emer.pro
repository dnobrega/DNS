PRO dnsvar_spz_emer, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emergence term of the Poynting flux in the z-direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spz_emer, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       uz=d->getvar("uz",snaps,swap=swap)
       bx=d->getvar('bx',snaps,swap=swap)
       by=d->getvar('by',snaps,swap=swap)

       var = ( xup(bx*bx) + yup(by*by) )
       var = -uz*zdn(var)*u.ue*u.ul/u.ut ; in the z-face

       var_title='S!dpz emer!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
