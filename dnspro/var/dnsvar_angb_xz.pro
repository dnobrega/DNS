PRO dnsvar_angb_xz, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Angle of the magnetic field in the XZ plane',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_angb_xz, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       bx=d->getvar('bx',snaps,swap=swap)*u.ub
       bz=-d->getvar('bz',snaps,swap=swap)*u.ub
       var=atan(bz,bx)*!radeg
       var_title='Angle B!dXZ!n'
       var_range=[-1,1]*180
       var_log=0
    ENDELSE
END
