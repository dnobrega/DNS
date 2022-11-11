PRO dnsvar_divsp, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Divergence of the Poynting flux',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_divsp, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF       
       CALL_PROCEDURE, "units_"+units, u
       
       ex=d->getvar("ex",snaps,swap=swap)
       ey=d->getvar("ey",snaps,swap=swap)
       ez=d->getvar("ez",snaps,swap=swap)
       
       bx=d->getvar("bx",snaps,swap=swap)
       by=d->getvar("by",snaps,swap=swap)
       bz=d->getvar("bz",snaps,swap=swap)

       scr1 = ex*zdn(by)
       scr2 = ey*zdn(bx)
       var  = ddzup(yup(scr1) - xup(scr2))

       scr1 = ey*xdn(bz)
       scr2 = ez*xdn(by)
       var  = var + ddxup(zup(scr1)-yup(scr2))

       scr1 = ez*ydn(bx)
       scr2 = ex*ydn(bz)
       var  = var + ddyup(xup(scr1)-zup(scr2))
       var  = var*u.ue/u.ut
       
       var_title='div(S!dp!n)'
       IF (units EQ "solar") THEN var_title=var_title+" (erg cm!u-3!n s!u-1!n)"
       var_range=[-1.0,1.0]*1d-1
       var_log=0
    ENDELSE
END
