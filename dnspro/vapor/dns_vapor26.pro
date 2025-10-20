
PRO dns_vapor26, var_3Dlist=var_3Dlist, var_2Dlist=var_2Dlist, $
                 isnaps=isnaps, vdffile=vdffile, do_vdf=do_vdf, do_data=do_data

  default_3Dlist = ["bxob","byob","bzob","bz","eparb","eui174","keparb","q_perp3d","r","tg","twist3d","ux","uy","uz"]
  default_2Dlist = ["aia171xy","aia193xy","aia211xy","eui174xy","xrt_alpolyxy"]

  IF (N_ELEMENTS(var_3Dlist) EQ 0) THEN var_3Dlist = default_3Dlist
  IF (N_ELEMENTS(var_2Dlist) EQ 0) THEN var_2Dlist = default_2Dlist
  IF (N_ELEMENTS(isnaps) EQ 0)     THEN isnaps     = 2*indgen(806)
  IF (N_ELEMENTS(vdffile) EQ 0)    THEN vdffile    = "vapor"
  
    swap=0
    units="solar"
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

    list_xy = []
; For Vapor 2.6 xz and yz are not available.    
;    list_xz = []
;    list_yz = []

    FOR i=0, N_ELEMENTS(var_2Dlist)-1 DO BEGIN
       ending = strmid(var_2Dlist[i], strlen(var_2Dlist[i])-2, 2)
       CASE ending OF
          'xy': list_xy = [list_xy, var_2Dlist[i]]
;          'xz': list_xz = [list_xz, var_2Dlist[i]]
;          'yz': list_yz = [list_yz, var_2Dlist[i]]
       ENDCASE
    ENDFOR


    IF (KEYWORD_SET(do_vdf)) THEN BEGIN
       
       PRINT, "VDF 3D:", var_3Dlist
       PRINT, "VDF 2D:", var_2Dlist
       
       commandvdf="vdfcreate -level "+strtrim(string(nl),2)+ $
                  " -vars3d "+strjoin(var_3Dlist,':') + $
                  " -vars2dxy "+strjoin(list_xy,':')+ $
;                  " -vars2dxz "+strjoin(list_xz,':')+ $
;                  " -vars2dyz "+strjoin(list_yz,':')+ $
                  " -dimension "+strjoin(strtrim(string(dim,format="(I4)"),2),'x')+ $
                  " -extents "+strjoin(strtrim(string(ext),2),':')+ $
                  " -numts "+string(nt)+" -periodic 1:1:0 " $
                  + filetimesswitch +   ' '+vdffile
       SPAWN, commandvdf
    ENDIF ELSE print, "No vdf created"

    IF (KEYWORD_SET(do_data)) THEN BEGIN

       PRINT, "Preparing to create 3D data:", var_3Dlist
       PRINT, "Preparing to create 2D data:", var_2Dlist
       
       FOR jj=0,ns-1 DO BEGIN
          print, "----------------------------------------------------------"
          print, "Snapshot: "+strtrim(string(isnaps[jj]),2)
          print, "----------------------------------------------------------"
          FOR ll=0,N_ELEMENTS(var_3Dlist)-1 DO BEGIN
             name = var_3Dlist[ll]
             dnsvar_name="dnsvar_"+name
             IF (NOT KEYWORD_SET(save_dnsfolder)) THEN save_dnsfolder='dnsvar'
             saved_dnsvar_name=save_dnsfolder+'/'+name+'_'+strtrim(string(isnaps[jj]),2)+'.sav'
             
             IF file_test(saved_dnsvar_name) EQ 1 THEN BEGIN
                print, "Restoring variable"
                restore, saved_dnsvar_name,/verbose
                IF (dnsvar_log) THEN var=alog10(var)
             ENDIF ELSE BEGIN
                print, "Loading...  ", name, string(isnaps[jj])
                dnsvar_name="dnsvar_"+name
                file_exists=STRLEN(file_which(dnsvar_name+".pro"))
                IF (file_exists GT 0) THEN BEGIN 
                   CALL_PROCEDURE, dnsvar_name, d, name, isnaps[jj], swap, var, units,$
                                   var_log=var_log
                   IF (var_log) THEN var=alog10(var)
                ENDIF
             ENDELSE
             IF (abs(min(dz1d)-dz) GT 1e-5) THEN BEGIN
                index  = findgen(nx)
                indey  = findgen(ny)
                indez  = interpol(findgen(nz), z, zu)
                var    = INTERPOLATE(var, index, indey, indez, /grid)
             ENDIF
             var=reverse(var,3)
             var=reverse(var,2)
             datfile = "var_"+name+".dat"
             openw,lu,datfile,/get_lun
             spawn, 'ls '+datfile
             writeu,lu,float(var)
             close,lu
             free_lun,lu
             spawn,'raw2vdf -ts '+STRTRIM(string(isnaps[jj]),2)+' -varname ' +name +' '+vdffile+' '+datfile
             spawn,'rm -f '+datfile
          ENDFOR

       FOR ll=0,N_ELEMENTS(var_2Dlist)-1 DO BEGIN
          name = strmid(var_2Dlist[ll], 0, strlen(var_2Dlist[ll])-2)
          dim  = strmid(var_2Dlist[ll], strlen(var_2Dlist[ll])-2, strlen(var_2Dlist[ll])) 
          dns_var, d, name, isnaps[jj], swap, var, units=units,$
                   /integration, dim=dim
          IF dim EQ "xy" THEN var = alog10(var(*,*,-1))
          IF dim EQ "xz" THEN var = alog10(var(*,-1,*))
          IF dim EQ "yz" THEN var = alog10(var(-1,*,*))
          datfile = "var_"+name+dim+".dat"
          openw,lu,datfile,/get_lun
          spawn, 'ls '+datfile
          writeu,lu,float(var)
          close,lu
          free_lun,lu
          spawn,'raw2vdf -ts '+STRTRIM(string(isnaps[jj]),2)+' -varname ' +name+dim +' '+vdffile+' '+datfile
          spawn,'rm -f '+datfile
       ENDFOR
    ENDFOR
    ENDIF ELSE print, "No data created"

END
