PRO dnsvar_nh2, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'H I number density from Saha compuation: nhi',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nh2, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       H2readtab,h2_tg,h2_pf       
       ; Main variables
       nel = d->getvar("nel",snaps,swap=swap)    ; cm^-3
       tg  = d->getvar("tg",snaps,swap=swap)     ; K
       wh  = where(tg le  max(h2_tg), nwh)
       r   = d->getvar("r",snaps,swap=swap)*u.ur  ; g cm-3
       ; Constants
       AMU      = 1.6605402d-24 
       me       = 9.11d-28           ; g  
       kb       = 1.38d-16           ; erg/K
       u0       = 2.
       u1       = 1.
       hh       = 6.63d-27           ; erg s
       EVTOERG  = 1./6.24d11
       kbtg     = kb*tg
       totconst = 2.0*!dpi*me*kb/(hh^2.0)
       phit     = (totconst*tg)^(1.5d)*2.0/nel
       xi       = 13.59*EVTOERG
       n1_n0    = phit*u1/u0*exp(-xi/(kbtg))
       ifracpos = 1/(1. + n1_n0)

       aux      = obj_new('br_aux')
       abnd     = d->gettababund()
       nl       = n_elements(abnd)
       aweight  = fltarr(nl)
       nameline = d->gettabelements()
       FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameline[il])
       awght    = aweight*amu
       abnd     = abnd*aweight
       abnd     = abnd/total(abnd)
       c2       = abnd(0)*r
       nht      = c2/awght(0)
       
       ; Result
       var      = 0*nht
       n0       = ifracpos*nht
       n1       = (1-ifracpos)*nht
       di       = 4.478007D*EVTOERG       ; Dissociation energy of H2 from Barklem and Collet (2016)                                           
       pf_h2    = interpol(h2_pf,h2_tg,tg(wh),/quadratic)
       n02_nh2  = 2.0d*(!dpi*awght(0)*kb*tg(wh)/hh^2)^(1.5d)*u1/pf_h2*exp(-di/(kbtg(wh)))
       n0(wh)   = (-(n1_n0(wh) + 1.0d) + sqrt((n1_n0(wh) + 1.0d)^2.0d + 8.0d*nht(wh)/n02_nh2))/(4.0d/n02_nh2)
       var(wh)  = n0(wh)*n0(wh)/n02_nh2
       var_title='n!dH2!n'
       IF (units EQ "solar") THEN var_title=var_title+" (cm!u-3!n)"
       var_range=[1.d4,1d12]
       var_log=1
    ENDELSE
END
