
PRO dns_vapor26, var_3Dlist, isnaps, vdffile


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
    yy  = -reverse(y)
    zz  = -reverse(zu)
    nl  = 2
    nt  = 999
    dim = [nx,ny,nz]
    ext = [xx[0],yy[0],zz[0],xx[nx-1],yy[ny-1],zz[nz-1]]

    commandvdf="vdfcreate -level "+strtrim(string(nl),2)+ $
               " -vars3d "+strjoin(var_3Dlist,':')+ var_2Dlist + $
               " -dimension "+strjoin(strtrim(string(dim,format="(I4)"),2),'x')+ $
               " -extents "+strjoin(strtrim(string(ext),2),':')+ $
               " -numts "+string(nt)+" -periodic 1:1:0 " $
               + filetimesswitch +   ' '+vdffile
    SPAWN, commandvdf  



    
    FOR ll=0,N_ELEMENTS(var_3Dlist)-1 DO BEGIN
        name=var_3Dlist[ll]
        print, "Loading...  ", name, string(isnaps)
        dnsvar_name="dnsvar_"+name
        file_exists=STRLEN(file_which(dnsvar_name+".pro"))
        IF (file_exists GT 0) THEN BEGIN 
           CALL_PROCEDURE, dnsvar_name, d, name, isnaps, swap, var, units,$
                           var_log=var_log
           IF (var_log) THEN var=alog10(var)
           IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
              FOR i=0,nx-1 DO BEGIN
                 FOR j=0,ny-1 DO var(i,j,*)=INTERPOL(var(i,j,*),z,zu)
              ENDFOR
           ENDIF
           var=reverse(var,3)
           var=reverse(var,2)
           openw,lu,'var.dat',/get_lun
           writeu,lu,float(var)
           close,lu
           free_lun,lu
           spawn,'raw2vdf -ts '+string(isnaps)+' -varname ' +name +' '+vdffile+' var.dat'
           spawn,'rm -f var.dat'
        ENDIF
    ENDFOR

    
    STOP
    

    



END
