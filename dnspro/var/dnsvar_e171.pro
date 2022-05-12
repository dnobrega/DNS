PRO dnsvar_e171, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Fe IX 171',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_e171, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       nel   = d->getvar('nel',snaps,swap=swap)
       si    = size(nel)
       r     = d->getvar('r',snaps,swap=swap)
       tg    = d->getvar('tg',snaps,swap=swap)
       tg(where(tg le 1e4)) = 1e4
       tg    = reform(tg,si(1),si(2),si(3))
       var   = fltarr(si(1),si(2),si(3))
       ;
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
       M_H     = 1.00794D*AMU
       FOR il=0,nl-1 DO aweight(il)=aux->awgt(nameln[il])
       abnd    = abnd*aweight
       abnd    = abnd/total(abnd)
       l       = 0
       c2      = abnd(l)*r
       nh      = c2/m_h*u.ur
       nh      = reform(nh,si(1),si(2),si(3))
       ; ch_synthetic does not include the element abundances 
       ch_synthetic, 171.072, 171.074, density=1e9,/goft,SNGL_ION="fe_9",output=ion
       ; Feldman 1992 abundance for Fe 8.10 (/ssw/packages/chianti/dbase/abundance/sun_coronal_1992_feldman.abund)
       FOR j=0,si(2)-1 DO BEGIN
          var(*,j,*) = 10^(8.10-12.0)*nel(*,j,*)*nh(*,j,*)*interpol(ion.lines[0].goft,ion.IONEQ_LOGT,alog10(tg(*,j,*)))
       ENDFOR
       var(*,*,wh)=1e-32
       var=reform(var)
       var(where(var le 0)) = 1e-32
       var(where(tg le 1e4)) = 1e-32
       var_title='!4e!3 Fe IX 171 (erg cm!u-3!n sr!u-1!n s!u-1!n)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
