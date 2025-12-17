PRO dnsvar_tau3d_kappa, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, '|b x eta jpar (kappa x b)|/B',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_tau3d_kappa, d, name, snaps, swap, var, units, ' $
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
       ; J par (centered)
       jx   = zup(yup(d->getvar('jx',snaps,swap=swap)))
       jy   = xup(zup(d->getvar('jy',snaps,swap=swap)))
       jz   = yup(xup(d->getvar('jz',snaps,swap=swap)))
       j2   = jx*jx + jy*jy + jz*jz 
       jpar = jx*bxob+jy*byob+jz*bzob
       ; Jpar * eta (centered)
       qj   = d->getvar('qjoule',snaps,swap=swap)
       eta  = jpar*(qj/j2)                       
       ; kappa (centered)
       kappax = xup(xdn(bxob)*ddxdn(bxob)) + yup(ydn(byob)*ddydn(bxob)) + zup(zdn(bzob)*ddzdn(bxob))
       kappay = xup(xdn(bxob)*ddxdn(byob)) + yup(ydn(byob)*ddydn(byob)) + zup(zdn(bzob)*ddzdn(byob))
       kappaz = xup(xdn(bxob)*ddxdn(bzob)) + yup(ydn(byob)*ddydn(bzob)) + zup(zdn(bzob)*ddzdn(bzob))

       ; Final jpar*eta(kappa x b) (centered)
       ux   = eta*(kappay*bzob - kappaz*byob)
       uy   = eta*(kappaz*bxob - kappax*bzob)
       uz   = eta*(kappax*byob - kappay*bxob)

       ; b x () (centered)                                                                                                                                
       ux   = (uy*bzob - uz*byob)
       uy   = (uz*bxob - ux*bzob)
       uz   = (ux*byob - uy*bxob) 
       var  = sqrt(ux*ux + uy*uy + uz*uz)/modb/u.ut
       var_title='|b x etaJ!dpar!n(kappa x b)|/B'
       IF (units EQ "solar") THEN var_title=var_title+" (s!u-1!n)"
       var_range=[2d-3,1.d]
       var_log=1
    ENDELSE
END
