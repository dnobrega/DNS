PRO dnsvar_thetaeresj, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, ' theta = arccos(E_res dot J / |E_res||J|)',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_thetaeresj, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       ex   = d->getvar('ex',snaps,swap=swap)
       ey   = d->getvar('ey',snaps,swap=swap)
       ez   = d->getvar('ez',snaps,swap=swap)
       bx   = d->getvar('bx',snaps,swap=swap)
       by   = d->getvar('by',snaps,swap=swap)
       bz   = d->getvar('bz',snaps,swap=swap)
       ux   = d->getvar('ux',snaps,swap=swap)
       uy   = d->getvar('uy',snaps,swap=swap)
       uz   = d->getvar('uz',snaps,swap=swap)

       eres_x = ex + (zdn(uy)*ydn(bz)-ydn(uz)*zdn(by))
       eres_y = ey + (xdn(uz)*zdn(bx)-zdn(ux)*xdn(bz))
       eres_z = ez + (ydn(ux)*xdn(by)-xdn(uy)*ydn(bx))

       jx = d->getvar('jx',snaps,swap=swap)
       jy = d->getvar('jy',snaps,swap=swap)
       jz = d->getvar('jz',snaps,swap=swap)

       ux = yup(eres_x)
       ux = zup(ux)
       uy = zup(eres_y)
       uy = xup(uy)
       uz = xup(eres_z)
       uz = yup(uz)
       
       moderes = sqrt(ux^2 + uy^2 + uz^2)
       
       bx   = yup(jx)
       bx   = zup(bx)
       by   = zup(jy)
       by   = xup(by)
       bz   = xup(jz)
       bz   = yup(bz)
       modj = sqrt(bx^2 + by^2 + bz^2)
       
       var = abs(ux*bx + uy*by + uz*bz)/(modj*moderes)
       var = (180/!PI)*acos(var)
       var_title='(180/pi)*arccos(| E!dres!n dot J |/ |E!dres!n||J|)'
       var_range=[0,90]
       var_log=0
    ENDELSE
END
