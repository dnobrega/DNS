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

       ex = d->getvar("ex",snaps,swap=swap)
       ey = d->getvar("ey",snaps,swap=swap)
       ez = d->getvar("ez",snaps,swap=swap)

       bx = d->getvar("bx",snaps,swap=swap)
       by = d->getvar("by",snaps,swap=swap)
       bz = d->getvar("bz",snaps,swap=swap)

       ey = ey*xdn(bz)
       by = ez*xdn(by)
       by = zup(ey)-yup(by)
       by = yup(by)
       
       ez = ez*ydn(bx)
       bx = ex*ydn(bz)
       bx = -(xup(ez)-zup(bx))
       bx = xup(bx)

       var = sqrt(bx*bx + by*by)*u.ue*u.ul/u.ut
       
       var_title='S!dph!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[1d,1d8]
       var_log=1
    ENDELSE
END
