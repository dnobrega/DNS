PRO dnsvar_spx, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Poynting flux in the x-direction: (ExB)x',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_spx, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ey=d->getvar("ey",snaps,swap=swap)
       ez=d->getvar("ez",snaps,swap=swap)
       
       by=d->getvar("by",snaps,swap=swap)
       bz=d->getvar("bz",snaps,swap=swap)

       ey = ey*xdn(bz)
       ez = ez*xdn(by)
       var=(zup(ey)-yup(ez))*u.ue*u.ul/u.ut ; in the x face 

       var_title='S!dpx!n'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-2!n s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
