PRO dnsvar_nheii, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'He II number density from Saha compuation: nheii',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nheii, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       ; Main variables
       nel = d->getvar("nel",snaps,swap=swap)    ; cm^-3
       tg  = d->getvar("tg",snaps,swap=swap)      ; K
       r   = d->getvar("r",snaps,swap=swap)*u.ur  ; g cm-3
       ; Constants
       AMU      = 1.6605402d-24 
       me       = 9.11d-28           ; g  
       kb       = 1.38d-16           ; erg/K
       u0       = 1.
       u1       = 2.
       u2       = 1.
       hh       = 6.63d-27           ; erg s
       EVTOERG  = 1./6.24d11
       totconst = 2.0*!dpi*me*kb/(hh^2.0)
       phit     = (totconst*tg)^(1.5d)*2.0/nel
       xi1      = 24.58*EVTOERG
       xi2      = 54.42*EVTOERG
       n1_n0    = phit*u1/u0*exp(-xi1/(kb*tg))
       n2_n1    = phit*u2/u1*exp(-xi2/(kb*tg))
       n2_n0    = n1_n0*n2_n1
       ifracpos = n1_n0/(1. + n1_n0 + n2_n0)

       aux      = obj_new('br_aux')
       abnd     = d->gettababund()
       nl       = n_elements(abnd)
       aweight  = fltarr(nl)
       nameline = d->gettabelements()
       FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameline[il])
       awght    = aweight*amu
       abnd     = abnd*aweight
       abnd     = abnd/total(abnd)
       c2       = abnd(1)*r
       nhet     = c2/awght(1)
       
       ; Result
       var      = nhet*ifracpos
       var_title='n!dHe II!n'
       IF (units EQ "solar") THEN var_title=var_title+" (cm!u-3!n)"
       var_range=[1.d4,1d12]
       var_log=1
    ENDELSE
END
