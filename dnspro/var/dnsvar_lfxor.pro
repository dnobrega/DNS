PRO dnsvar_lfxor, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Acceleration due to Lorentz force in the X direction',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_lfxor, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       jy  = (d->getvar('jy',snaps,swap=swap))
       jz  = (d->getvar('jz',snaps,swap=swap))
       by  = d->getvar('by',snaps,swap=swap)
       bz  = d->getvar('bz',snaps,swap=swap)
       r   = xdn(d->getvar('r',snaps,swap=swap))
       var = (zup(jy*xdn(bz)) - yup(jz*xdn(by)))/r*u.ul/u.ut/u.ut
       
       var_title="(JxB)!dx!n/!4q!3"
       IF (units EQ "solar") THEN BEGIN
          var = var/1e5
          var_title=var_title+" (km s!u-2!n)"
       ENDIF
       var_range=[-100,100]
       var_log=0
    ENDELSE
END
