
PRO dns_vapor26_2D

    ;----------------------------------------------------------------------------------------
    var_3Dlist = ["bxob", "byob","bzob","eparb","eui174","r","sqf","tg","tw","ux","uy","uz"]
    vdffile    = "test"
    isnaps     = 2*indgen(806)  
    var_2Dlist = ["eui174"]
    do_data    = 1
    ;----------------------------------------------------------------------------------------
    swap       = 0
    units      = "solar"
    br_select_idlparam,idlparam
    d=obj_new('br_data',idlparam)
    br_getsnapind,idlparam,snaps
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
                  " -vars3d "+strjoin(var_3Dlist,':')+$
                  " -vars2dxy "+strjoin(var_2Dlist+"xy",':')+ $
                  " -dimension "+strjoin(strtrim(string(dim,format="(I4)"),2),'x')+ $
                  " -extents "+strjoin(strtrim(string(ext),2),':')+ $
                  " -numts "+string(nt)+" -periodic 1:1:0 " $
                  + filetimesswitch +   ' '+vdffile
       SPAWN, commandvdf
    ENDIF ELSE print, "No vdf created"

    IF (KEYWORD_SET(do_data)) THEN BEGIN
          FOR jj=0,ns-1 DO BEGIN
       
             FOR ll=0,N_ELEMENTS(var_2Dlist)-1 DO BEGIN
                name=var_2Dlist[ll]
                print, "Loading...  ", name, string(isnaps[jj])
                dns_var, d, name, isnaps[jj], swap, var, units=units,$
                         /integration, dim="xy"
                var = alog10(var)
                var = var(*,*,nz-1)
                datfile = "var_"+name+".dat"
                openw,lu,datfile,/get_lun
                spawn, 'ls '+datfile
                writeu,lu,float(var)
                close,lu
                free_lun,lu
                spawn,'raw2vdf -ts '+STRTRIM(string(isnaps[jj]),2)+' -varname ' +name+"xy" +' '+vdffile+' '+datfile
                spawn,'rm -f '+datfile
             ENDFOR
          ENDFOR
    ENDIF ELSE print, "No data created"

END
