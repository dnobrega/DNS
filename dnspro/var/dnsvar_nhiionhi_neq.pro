PRO dnsvar_nhiionhi_neq, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'H II/HI fraction from NEQ compuation: nhiionhi_neq',/info
       RETURN
    ENDIF ELSE BEGIN 
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_nhiionhi_neq, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       ; Main variables
       n1 = d->getvar("n1",snaps,swap=swap)
       n2 = d->getvar("n2",snaps,swap=swap)
       n3 = d->getvar("n3",snaps,swap=swap)
       n4 = d->getvar("n4",snaps,swap=swap)
       n5 = d->getvar("n5",snaps,swap=swap)
       n6 = d->getvar("n6",snaps,swap=swap)
       var  = n6/(n1+n2+n3+n4+n5)
       var_title='n!dH II!n/n!dH I!n (NEQ)'
       var_range=[1.d-8,1d12]
       var_log=1
    ENDELSE
END
