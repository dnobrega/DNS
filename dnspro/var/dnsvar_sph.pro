PRO dnsvar_sph, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Poynting flux in the horizontal-direction: (ExB)h',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_sph, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u

       ex = d->getvar("ex",snaps,swap=swap)*u.uu*u.ub
       ey = d->getvar("ey",snaps,swap=swap)*u.uu*u.ub
       ez = d->getvar("ez",snaps,swap=swap)*u.uu*u.ub

       bx = d->getvar("bx",snaps,swap=swap)*u.ub      
       by = d->getvar("by",snaps,swap=swap)*u.ub
       bz = d->getvar("bz",snaps,swap=swap)*u.ub

       ey = ey*xdn(bz)
       by = ez*xdn(by)
       by = zup(ey)-yup(by)
       by = yup(by)
       
       ez = ez*ydn(bx)
       bx = ex*ydn(bz)
       bx = -(xup(ez)-zup(bx))
       bx = xup(bx)

       var = sqrt(bx*bx + by*by)
       
       var_title='S!dph!n'
       IF (units EQ "solar") THEN var_title=var_title+" (G!u2!n cm s!u-1!n)"
       var_range=[1d,1d8]
       var_log=1
    ENDELSE
END
