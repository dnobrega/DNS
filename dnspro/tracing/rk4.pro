PRO RK4, xarray, zarray, $
         x, z, h, $
         ux, uz, ux1, uz1, ux2, uz2

   ;----------------------------------------
   ; Setting parameters
   ;----------------------------------------
   ; xarray is x coordinates array
   ; zarray is z coordinates array
   ; x is x-position of the tracers
   ; z is z-position of the tracers
   ; h is integration step
   ; ux and uz are the field at time n
   ; ux1 and uz1 are the field at time n+h/2 
   ; ux2 and uz2 are the field at time n+h

   ;----------------------------------------
   ; Setting parameters
   ;----------------------------------------
    maxx=MAX(xarray,MIN=minx)
    maxz=MAX(zarray,MIN=minz)
    nelx=N_ELEMENTS(xarray) 
    nelz=N_ELEMENTS(zarray)
    factx=(nelx-1d)/(maxx-minx)
    factz=(nelz-1d)/(maxz-minz)

   ;----------------------------------------
   ; K1 & L1
   ;----------------------------------------
    posx=(x-minx)*factx
    posz=(z-minz)*factz
    K1=INTERPOLATE(ux,posx,posz)
    L1=INTERPOLATE(uz,posx,posz)
    
   ;----------------------------------------
   ; K2 & L2
   ;----------------------------------------
    posx=(x+0.5*h*K1-minx)*factx
    posz=(z+0.5*h*L1-minz)*factz
    K2=INTERPOLATE(ux1,posx,posz)
    L2=INTERPOLATE(uz1,posx,posz)
    
   ;----------------------------------------
   ; K3 & L3
   ;----------------------------------------
    posx=(x+0.5*h*K2-minx)*factx
    posz=(z+0.5*h*L2-minz)*factz
    K3=INTERPOLATE(ux1,posx,posz)
    L3=INTERPOLATE(uz1,posz,posz)
    
   ;----------------------------------------
   ; K4 & L4
   ;----------------------------------------
    posx=(x+h*K3-minx)*factx
    posz=(z+h*L3-minz)*factz
    K4=INTERPOLATE(ux2,posx,posz)
    L4=INTERPOLATE(uz2,posx,posz)

   ;----------------------------------------
   ; New positions x and z
   ;----------------------------------------
    x = x + h*(K1 + 2.*K2 + 2.*K3 + K4)/6.d
    z = z + h*(L1 + 2.*L2 + 2.*L3 + L4)/6.d


END
