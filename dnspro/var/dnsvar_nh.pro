PRO dnsvar_nh, d, name, snaps, swap, var, units, $
                  var_title=var_title, var_range=var_range, var_log=var_log, $
                  info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Hydrogen number density nh',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_aia131_ly, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     r     = d->getvar('r',snaps,swap=swap)
     ; ---------------------------------------------------
     ; Computing the total number of hydrogen
     ; ---------------------------------------------------
     d->readpars, snaps
     abnd    = d->gettababund()
     nl      = n_elements(abnd)
     aweight = fltarr(nl)
     nameln  = d->gettabelements()
     aux     = obj_new('br_aux')
     AMU     = 1.6605402d-24 
     M_H     = 1.007131D*AMU 
     FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameln[il])
     abnd    = abnd*aweight
     abnd    = abnd/total(abnd)
     l       = 0
     c2      = abnd(l)*r
     var     = c2/m_h*u.ur 
     ; ---------------------------------------------------
     var_title='n!dH!n'
     IF (units EQ "solar") THEN var_title=var_title+" (cm!u-3!n)"
     var_range=[1d9,1d12]
     var_log=1
  ENDELSE
END
