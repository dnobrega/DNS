PRO dnsvar_e_fe_10_174, d, name, snaps, swap, var, units, $ 
    var_title=var_title, var_range=var_range, var_log=var_log, $
    info=info
    IF KEYWORD_SET(info) THEN BEGIN
       message, 'Emissivity of Fe X 174',/info
       RETURN
    ENDIF ELSE BEGIN
       IF n_params() LT 6 THEN BEGIN
          message,'dnsvar_e_fe_10_174, d, name, snaps, swap, var, units, ' $
                 +'var_title=var_title, var_range=var_range, var_log=var_log',/info
          RETURN
       ENDIF
       CALL_PROCEDURE, "units_"+units, u
       nel   = d->getvar('nel',snaps,swap=swap)
       si    = size(nel)
       r     = d->getvar('r',snaps,swap=swap)
       tg    = d->getvar('tg',snaps,swap=swap)
              
       tg    = reform(tg,si(1)*si(2)*si(3))
       nel   = reform(nel,si(1)*si(2)*si(3))
       
                               
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
       nh      = reform(nh,si(1)*si(2)*si(3))

       myabund = 8.10
       folder  = GETENV('DNS')+"/dnspro/var/goft_tables/"
       RESTORE, folder+"goft_table_fe_10_174.5310.sav"
       dlogt   = temperature[1]-temperature[0]
       dlogr   = density[1]-density[0]

       indr    = (alog10(nel)-density[0])/dlogr
       indt    = (alog10(tg)-temperature[0])/dlogt

       var = 10^(myabund-12.0)*nel*nh*interpolate(table,indr,indt,missing=0)
       var = reform(var,si(1),si(2),si(3))

       var_title='!4e!3 Fe X 174 (erg cm!u-3!n sr!u-1!n s!u-1!n)'
       var_range=[1d-8,5d-7]
       var_log=1
    ENDELSE
END
