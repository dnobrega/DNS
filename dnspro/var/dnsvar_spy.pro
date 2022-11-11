PRO dnsvar_spy, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Poynting flux in the y-direction: (ExB)y',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spy, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ex=d->getvar("ex",snaps,swap=swap)
       ez=d->getvar("ez",snaps,swap=swap)
       
       bx=d->getvar("bx",snaps,swap=swap)
       bz=d->getvar("bz",snaps,swap=swap)

       ez = ez*ydn(bx)
       ex = ex*ydn(bz)
       var= -(xup(ez)-zup(ex))*u.uu*u.ub*u.ub ; in the y-face

       var_title='S!dpy!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
