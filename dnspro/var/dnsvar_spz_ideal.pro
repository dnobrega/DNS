PRO dnsvar_spz_ideal, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Ideal term of the Poynting flux in the z-direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spz_ideal, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       ux=xup(d->getvar("ux",snaps,swap=swap))
       uy=-yup(d->getvar("uy",snaps,swap=swap))
       uz=-zup(d->getvar("uz",snaps,swap=swap))
       
       bx=xup(d->getvar('bx',snaps,swap=swap))
       by=-yup(d->getvar('by',snaps,swap=swap))
       bz=-zup(d->getvar('bz',snaps,swap=swap))

       var = uy*bz*by - uz*by*by - uz*bx*bx + ux*bx*bz
       var = -zdn(var)*u.ue*u.ul/u.ut ; in the z-face

       var_title='S!dpz ideal!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
