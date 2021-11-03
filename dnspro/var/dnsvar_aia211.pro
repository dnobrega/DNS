PRO dnsvar_aia211, d, name, snaps, swap, var, units, $
                    var_title=var_title, var_range=var_range, var_log=var_log, $
                    info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'AIA Fe XIV 211 response',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_aia211, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     aia_tresp = aia_get_response(/temp,/dn,/all,/full)
     nel   = d->getvar('nel',snaps,swap=swap)
     si    = size(nel)
     r     = d->getvar('r',snaps,swap=swap)
     tg    = d->getvar('tg',snaps,swap=swap)
     tg(where(tg le 1e4)) = 1e4
     tg    = reform(tg,si(1),si(2),si(3))
     var   = fltarr(si(1),si(2),si(3))
     ; ---------------------------------------------------
     ; Computing the total number of hydrogen
     ; ---------------------------------------------------
     d->readpars, snaps
     d->readmesh
     z       = d->getz()
     wh      = where(z ge -1.0)
     abnd    = d->gettababund()
     nl      = n_elements(abnd)
     aweight = fltarr(nl)
     nameln  = d->gettabelements()
     aux     = obj_new('br_aux')
     AMU     = 1.6605402d-24 
     M_H     = 1.007211D*AMU 
     FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameln[il])
     abnd    = abnd*aweight
     abnd    = abnd/total(abnd)
     l       = 0
     c2      = abnd(l)*r
     nh      = c2/m_h*u.ur 
     nh      = reform(nh,si(1),si(2),si(3))
     ; ---------------------------------------------------
     FOR j=0,si(2)-1 DO BEGIN
        var(*,j,*) = nel(*,j,*)*nh(*,j,*)*interpol(aia_tresp.a211.tresp,aia_tresp.a211.logte,alog10(tg(*,j,*)))
     ENDFOR
     var(*,*,wh)=1e-32
     var=reform(var)
     var(where(var le 0)) = 1e-32
     var(where(tg le 1e4)) = 1e-32
     var_title='AIA211'
     IF (units EQ "solar") THEN var_title=var_title+" (DN cm!u-1!n s!u-1!n pix!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
