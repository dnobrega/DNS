PRO dnsvar_eui174, d, name, snaps, swap, var, units, $
                    var_title=var_title, var_range=var_range, var_log=var_log, $
                    info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Solar Orbiter EUI/HRI 174 response (DN cm-1 s-1)',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_eui174, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     folder    = GETENV('DNS')+"/dnspro/var/"
     goft      = readfits(folder+"gof_hri_174_sun_coronal_1992_feldman_ext.abund_chianti.ioneq_synthetic.fits",header)
     str       = fitshead2struct(header)
     maxx      = alog10(str.tmax)
     minx      = alog10(str.tmin)
     maxz      = alog10(str.nmax)-6 ;from m-3 to cm-3
     minz      = alog10(str.nmin)-6 ;from m-3 to cm-3
     nelx      = str.naxis1
     nelz      = str.naxis2
     factx     = (nelx-1)/(maxx-minx)
     factz     = (nelz-1)/(maxz-minz)

     nel_arr   = 10^(minz + (maxz-minz)*findgen(nelz)/(nelz-1))
     FOR kk=0,nelz-1 DO goft[*,kk] = goft(*,kk)/1e2/nel_arr[kk]
     
     nel       = alog10(d->getvar('nel',snaps,swap=swap))
     si        = size(nel)
     nel       = reform(nel,si[5])
     tg        = alog10(d->getvar('tg',snaps,swap=swap))
     tg        = reform(tg,si[5])
     posx      = (tg  - minx)*factx
     posz      = (nel - minz)*factz
     var       = INTERPOLATE(goft,posx,posz,MISSING=1e-32)
     var       = reform(var,si(1),si(2),si(3))
     nel       = reform(nel,si(1),si(2),si(3))

     r       = d->getvar('r',snaps,swap=swap)
     r       = reform(r,si(1),si(2),si(3))
     abnd    = d->gettababund()
     nl      = n_elements(abnd)
     aweight = fltarr(nl)
     nameln  = d->gettabelements()
     aux     = obj_new('br_aux')
     AMU     = 1.6605402d-24
     M_H     = 1.00794D*AMU
     FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameln[il])
     abnd    = abnd*aweight
     abnd    = abnd/total(abnd)
     l       = 0
     c2      = abnd(l)*r
     nh      = c2/m_h*u.ur
     
     var       = reform(var*nh*nel)
     var_title =  'EUI!dHRI!n 174'
     IF (units EQ "solar") THEN var_title=var_title+" (DN cm!u-1!n s!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
