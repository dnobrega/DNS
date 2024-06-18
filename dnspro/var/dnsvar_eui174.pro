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
     folder    = GETENV('DNS')+"/dnspro/var/goft_tables/"
     goft      = readfits(folder+"goft_hri_174_sun_coronal_1992_feldman_ext.abund_chianti.ioneq_synthetic.fits",header)
     goft      = goft/1e2          ; from DN m-1 s-1 pix-1 to Dn cm-1 s-1 pix-1
     str       = fitshead2struct(header)
     maxx      = alog10(str.tmax)
     minx      = alog10(str.tmin)
     maxz      = alog10(str.nmax)-6 ;from m-3 to cm-3
     minz      = alog10(str.nmin)-6 ;from m-3 to cm-3
     nelx      = str.naxis1
     nelz      = str.naxis2
     factx     = (nelx-1)/(maxx-minx)
     factz     = (nelz-1)/(maxz-minz)

     tg_arr    = minx + (maxx-minx)*findgen(nelx)/(nelx-1)
     sswfolder = GETENV('SSW')+"/packages/chianti/dbase/abundance/"
     nhone     = proton_dens(tg_arr,abund=sswfolder+"sun_coronal_1992_feldman_ext.abund")
     nel_arr   = 10^(minz + (maxz-minz)*findgen(nelz)/(nelz-1))
     FOR kk=0,nelz-1 DO goft[*,kk]  = goft(*,kk)/(nel_arr[kk]^2.0)
     FOR kk=0,nelx-1 DO goft[kk, *] = goft[kk,*]/nhone[kk]
     
     nel       = alog10(d->getvar('nel',snaps,swap=swap))
     si        = size(nel)
     nel       = reform(nel,si[5])
     tg        = alog10(d->getvar('tg',snaps,swap=swap))
     whtg      = where(tg le 4)
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
     nel     = 10^nel
     var     = var*nh*nel
     var(whtg)=1e-32

     d->readpars, snaps
     d->readmesh
     z       = d->getz()
     wh      = where(z ge -1.0)
     var(*,*,wh)=1e-32
     var=reform(var)    
     
     var_title =  'EUI!dHRI!n 174'
     IF (units EQ "solar") THEN var_title=var_title+" (DN cm!u-1!n s!u-1!n pix!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
