PRO dnsvar_e10801tab, d, name, snaps, swap, var, units, $
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Fe XIII 10801',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_e10801, d, name, snaps, swap, var, units, ' $
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
       ; Feldman 1992 abundance for Fe 8.10
       ; Schmelz 2012 abundance for Fe 7.85
       ; (/ssw/packages/chianti/dbase/abundance/sun_coronal_1992_feldman.abund)
       myabund=7.85
       
       folder    = GETENV('DNS')+"/dnspro/var/goft_tables/"
       RESTORE, folder+"goft_table_fe_13_10800.77.sav"

       kk = 0
       mywh = where(nel le density[kk], nmywh)
       var(mywh) =  10^(myabund-12.0)*nel(mywh)*nh(mywh)*interpol(table[0,*],temperature,alog10(tg(mywh)))
       FOR kk=1,n_elements(density)-2 DO BEGIN
          mywh = where(nel gt density[kk-1] and nel le density[kk], nmywh)
          var(mywh) =  10^(myabund-12.0)*nel(mywh)*nh(mywh)*interpol(table[kk,*],temperature,alog10(tg(mywh)))
       ENDFOR
       mywh = where(nel gt density[kk], nmywh)
       var(mywh) =  10^(myabund-12.0)*nel(mywh)*nh(mywh)*interpol(table[kk,*],temperature,alog10(tg(mywh)))
       
       var(*,*,wh)=1e-32
       var=reform(var)
       var=var/((3600.0*180.0/!PI)^2.0) ; from sr-1 to arcsec-2
       var(where(var le 0))  = 1e-32
       var(where(tg le 1e4)) = 1e-32
       var_title='!4e!3 Fe XIII 10801 (phot cm!u-3!n s!u-1!n arcsec!u-2!n)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
