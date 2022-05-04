PRO dnsvar_solo174, d, name, snaps, swap, var, units, $
                    var_title=var_title, var_range=var_range, var_log=var_log, $
                    info=info
  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Solar Orbiter EUI/HRI 174 response (DN cm-1 s-1)',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_solo174, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     CALL_PROCEDURE, "units_"+units, u
     goft = readfits("gof_hri_174_sun_coronal_1992_feldman_ext.abund_chianti.ioneq_synthetic.fits",header)
     str  = fitshead2struct(header)
     maxx=str.tmax & minx=str.tmin
     maxz=str.nmax-6 & minz=str.nmin-6
     nelx=str.naxis1 & nelz=str.naxis2
     factx=nelx/(maxx-minx)
     factz=nelz/(maxz-minz)
     
     nel   = alog10(d->getvar('nel',snaps,swap=swap))
     si    = size(nel)
     nel   = reform(nel,si[0])
     tg    = alog10(d->getvar('tg',snaps,swap=swap))
     tg    = reform(tg,si[0])
     posx  = (tg - minx)*factx
     posz  = (nel -minz)*factz

     d->readpars, snaps
     d->readmesh
     z           = d->getz()
     wh          = where(z ge -1.0)
     var         = INTERPOLATE(goft,posx,posz)
     var         = reform(var,si(1),si(2),si(3))
;     var(*,*,wh) = 1e-32
     var         = reform(var)
;     var(where(var le 0)) = 1e-32
     var_title='Solar Orbiter EUI/HRI 174'
     IF (units EQ "solar") THEN var_title=var_title+" (DN cm!u-1!n s!u-1!n)"
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
