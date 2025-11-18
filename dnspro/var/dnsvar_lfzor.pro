PRO dnsvar_lfzor, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Acceleration due to Lorentz force in the z-direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfzor, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jx = (d->getvar('jx',snaps,swap=swap))
       jy = (d->getvar('jy',snaps,swap=swap))

       bx = d->getvar('bx',snaps,swap=swap)
       by = d->getvar('by',snaps,swap=swap)

       r   = zdn(d->getvar("r",snaps,swap=swap))
       var = -(yup(jx*zdn(by)) - xup(jy*zdn(bx)))/r*u.ul/u.ut/u.ut

       var_title="(JxB)!dz!n/!4q!3"
       IF (units EQ "solar") THEN BEGIN
          var=var/1e5
          var_title=var_title+" (km s!u-2!n)"
       ENDIF
       var_range=[-200,200]
       var_log=0
    ENDELSE
END
