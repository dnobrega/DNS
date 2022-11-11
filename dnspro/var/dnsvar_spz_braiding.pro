PRO dnsvar_spz_braiding, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Braiding term of the Poynting flux in the z-direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spz_braiding, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u

       ux=d->getvar("ux",snaps,swap=swap)*u.uu
       uy=-d->getvar("uy",snaps,swap=swap)*u.uu
       
       bx=d->getvar('bx',snaps,swap=swap)*u.ub
       by=-d->getvar('by',snaps,swap=swap)*u.ub
       bz=-d->getvar('bz',snaps,swap=swap)*u.ub

       var = xup(ux*bx) + yup(uy*by)
       var=-bz*( zdn(var) ) ; in the z-face

       var_title='S!dpz braiding!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1,1]*1d6
       var_log=0
    ENDELSE
END
