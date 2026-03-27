PRO dnsvar_e10749_pcorona, d, name, snaps, swap, var, units, $
                   var_title=var_title, var_range=var_range, var_log=var_log, $
                   info=info

  IF KEYWORD_SET(info) THEN BEGIN
     message, 'Emissivity from PCORONA for Fe XIII 10749',/info
     RETURN
  ENDIF ELSE BEGIN
     IF n_params() LT 6 THEN BEGIN
        message,'dnsvar_e10749_pcorona, d, name, snaps, swap, var, units, ' $
                +'var_title=var_title, var_range=var_range, var_log=var_log',/info
        RETURN
     ENDIF     
     d->readpars, snaps
     d->readmesh
     nx  = d->getmx()
     ny  = d->getmy()
     nz  = d->getmz()
     dz1d=d->getdz1d()
     z   = d->getz()
     spawn, "pwd", folder
     folder = folder+"/PCORONA/"
     file   = folder+'emisFe10747_'+STRTRIM(STRING(snaps),2)+'_halfres.h5'
     fid    = H5F_OPEN(file)
     did    = H5D_OPEN(fid, 'eps_I')
     var    = H5D_READ(did)
     H5D_CLOSE, did
     H5F_CLOSE, fid
     var    = transpose(var,  [1,2,0])
     var    = reverse(var, 2)
     var    = rebin(var, nx, ny, nz)
     maxz=MAX(z, MIN=minz)
     dz=(maxz-minz)/(nz-1)
     var    = reverse(reverse(var,3),2)
     IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
        zz    = minz+dz*FINDGEN(nz)
        index = indgen(nx)
        indey = indgen(ny)
        indez = interpol(indgen(nz),zz, z)
        var   = INTERPOLATE(var, index, indey, indez, /grid)
     ENDIF
     var_title='!4e!3 Fe XIII 10749 (phot cm!u-3!n s!u-1!n arcsec!u-2!n)'
     var_range=[1d-8,5d-7]
     var_log=1
  ENDELSE
END
