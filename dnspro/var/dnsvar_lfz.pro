PRO dnsvar_lfz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Lorentz force in the z-direction: (JxB)z',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx=(d->getvar('jx',snaps,swap=swap))
       jy=-(d->getvar('jy',snaps,swap=swap))

       bx=d->getvar('bx',snaps,swap=swap)
       by=-d->getvar('by',snaps,swap=swap)

       var = (yup(jx*zdn(by)) - xup(jy*zdn(bx)))*u.up/u.ul

       var_title="(JxB)!dz!n"
       IF (units EQ "solar") THEN var_title=var_title+" (Ba cm!u-1!n)"
       var_range=[-1e-7,1e-7]
       var_log=0
    ENDELSE
END
