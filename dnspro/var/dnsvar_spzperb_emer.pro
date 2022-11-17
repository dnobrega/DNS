PRO dnsvar_spzperb_emer, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emergence term of the Poynting flux in the z-direction perpendicular to B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spzperb_emer, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       uz=d->getvar("uz",snaps,swap=swap)*u.uu
       bx=xup(d->getvar('bx',snaps,swap=swap)*u.ub)
       by=yup(d->getvar('by',snaps,swap=swap)*u.ub)
       bz=-d->getvar('bz',snaps,swap=swap)*u.ub

       modb = bx*bx + by*by
       var  = -uz*zdn(modb)
       modb = zdn(sqrt(modb + zup(bz*bz)))
       var  =  var*(1.0 - bz/modb) ; in the z-face

       var_title='S!dpz!9x!3B emer!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
