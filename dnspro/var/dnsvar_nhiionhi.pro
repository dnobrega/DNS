PRO dnsvar_nhiionhi, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'H II/HI fraction from LTE compuation: nhiionhi',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nhiionhi, d, name, snaps, swap, var, units, ' $
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
       u0       = 2.
       u1       = 1.
       hh       = 6.63d-27           ; erg s
       EVTOERG  = 1./6.24d11
       totconst = 2.0*!dpi*me*kb/(hh^2.0)
       phit     = (totconst*tg)^(1.5d)*2.0/nel
       xi       = 13.59*EVTOERG
       var      = phit*u1/u0*exp(-xi/(kb*tg))
       ; Result
       var_title='n!dH II!n/n!dH I!n (LTE)'
       var_range=[1.d-8,1d12]
       var_log=1
    ENDELSE
END
