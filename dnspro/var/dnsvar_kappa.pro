PRO dnsvar_kappa, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, '|kappa|: curvature',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_kappa, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       ; Unit vector
       bx   = d->getvar('bx',snaps,swap=swap)
       by   = d->getvar('by',snaps,swap=swap)
       bz   = d->getvar('bz',snaps,swap=swap)
       bxob = xup(bx)                         
       byob = yup(by)
       bzob = zup(bz)
       modb = sqrt(bxob^2+byob^2+bzob^2) ;modb centered
       bxob = bx/modb                    ;unit vector x centered
       byob = by/modb                    ;unit vector y centered
       bzob = bz/modb                    ;unit vector z centered

       ; kappa (centered)
       kappax = xup(xdn(bxob)*ddxdn(bxob)) + yup(ydn(byob)*ddydn(bxob)) + zup(zdn(bzob)*ddzdn(bxob))
       kappay = xup(xdn(bxob)*ddxdn(byob)) + yup(ydn(byob)*ddydn(byob)) + zup(zdn(bzob)*ddzdn(byob))
       kappaz = xup(xdn(bxob)*ddxdn(bzob)) + yup(ydn(byob)*ddydn(bzob)) + zup(zdn(bzob)*ddzdn(bzob))
       var    = sqrt(kappax*kappax + kappay*kappay + kappaz*kappaz)
       var_title='!4j!3'
       IF (units EQ "solar") THEN var_title=var_title+" (Mm!u-1!n)"
       var_range=[2d-3,1.d]
       var_log=1
    ENDELSE
END
