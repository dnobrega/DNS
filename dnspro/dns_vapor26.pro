
PRO dns_vapor26, var_3Dlist, isnaps, vdffile, do_vdf=do_vdf, do_data=do_data

    swap=0
    units="solar"
    br_select_idlparam,idlparam
    d=obj_new('br_data',idlparam)
    br_getsnapind,idlparam,snaps
    var_2Dlist      = ""
    filetimesswitch = ""
    IF(strpos(vdffile,'.vdf') LT 0) THEN vdffile=vdffile+'.vdf'
    
    d->readpars, snaps[0]
    d->readmesh
    xx  = d->getx()
    y   = d->gety()
    z   = d->getz()
    nx  = d->getmx()
    ny  = d->getmy()
    nz  = d->getmz()
    maxz= MAX(z, MIN=minz)
    dz  = (maxz-minz)/(nz-1)
    dz1d=d->getdz1d()
    IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
       zu=minz+dz*FINDGEN(nz)
    ENDIF ELSE BEGIN
       zu=z
    ENDELSE
    yy  = xx
    zz  = -reverse(zu)
    nl  = 2
    ns  = n_elements(isnaps)
    nt  = 9999
    dim = [nx,ny,nz]
    ext = [xx[0],yy[0],zz[0],xx[nx-1],yy[ny-1],zz[nz-1]]

    IF (KEYWORD_SET(do_vdf)) THEN BEGIN
       commandvdf="vdfcreate -level "+strtrim(string(nl),2)+ $
                  " -vars3d "+strjoin(var_3Dlist,':')+ var_2Dlist + $
                  " -dimension "+strjoin(strtrim(string(dim,format="(I4)"),2),'x')+ $
                  " -extents "+strjoin(strtrim(string(ext),2),':')+ $
                  " -numts "+string(nt)+" -periodic 1:1:0 " $
                  + filetimesswitch +   ' '+vdffile
       SPAWN, commandvdf
    ENDIF ELSE print, "No vdf created"

    IF  (KEYWORD_SET(do_data)) THEN BEGIN
       FOR jj=0,ns-1 DO BEGIN
       
          FOR ll=0,N_ELEMENTS(var_3Dlist)-1 DO BEGIN
             name=var_3Dlist[ll]
             print, "Loading...  ", name, string(isnaps[jj])
             dnsvar_name="dnsvar_"+name
             file_exists=STRLEN(file_which(dnsvar_name+".pro"))
             IF (file_exists GT 0) THEN BEGIN 
                CALL_PROCEDURE, dnsvar_name, d, name, isnaps[jj], swap, var, units,$
                                var_log=var_log
                IF (var_log) THEN var=alog10(var)
                IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
                   index  = findgen(nx)
                   indey  = findgen(ny)
                   indez  = interpol(findgen(nz), z, zu)
                   var = INTERPOLATE(var, index, indey, indez, /grid)
                ENDIF
                var=reverse(var,3)
                var=reverse(var,2)
                help, var
                openw,lu,'var.dat',/get_lun
                spawn, 'ls var.dat'
                writeu,lu,float(var)
                close,lu
                free_lun,lu
                spawn,'raw2vdf -ts '+STRTRIM(string(isnaps[jj]),2)+' -varname ' +name +' '+vdffile+' var.dat'
                spawn,'rm -f var.dat'
             ENDIF
          ENDFOR
       ENDFOR
    ENDIF ELSE print, "No data created"

END
