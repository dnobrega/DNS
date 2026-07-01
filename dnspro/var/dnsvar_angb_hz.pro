PRO dnsvar_angb_hz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Angle of the magnetic field horizontal vs Z',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_angb_hz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx=xup(d->getvar('bx',snaps,swap=swap))
       by=-yup(d->getvar('by',snaps,swap=swap))
       bh=sqrt(bx*bx+by*by)
       bz=-d->getvar('bz',snaps,swap=swap)
       var=atan(bh,bz)*!radeg
       var_title='Angle B!dHZ!n'
       var_range=[-1,1]*180
       var_log=0
    ENDELSE
END
