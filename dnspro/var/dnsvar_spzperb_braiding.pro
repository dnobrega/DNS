PRO dnsvar_spzperb_braiding, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Braiding term of the Poynting flux in the z-direction perpendicular to B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spzperb_braiding, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u

       ux=xup(d->getvar("ux",snaps,swap=swap)*u.uu)
       uy=-yup(d->getvar("uy",snaps,swap=swap)*u.uu)
       
       bx=xup(d->getvar('bx',snaps,swap=swap)*u.ub)
       by=-yup(d->getvar('by',snaps,swap=swap)*u.ub)
       bz=-d->getvar('bz',snaps,swap=swap)*u.ub

       modb = sqrt(bx*bx + by*by + zup(bz*bz))
       var = ux*bx*(1.0-bx/modb) + uy*by*(1.0-by/modb)
       var=-bz*( zdn(var) ) ; in the z-face

       var_title='S!dpz!9x!3B braiding!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
