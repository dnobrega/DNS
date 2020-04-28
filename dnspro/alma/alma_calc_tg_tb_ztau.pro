PRO ALMA_CALC_TG_TB_ZTAU


   f=alma_synthfiles()
   si=transpose(alma_readsynth(f,"Stokes_I"),[1,2,0])
   wv=alma_readsynth(f,"Wavelength")
   nwv=n_elements(wv)
   tau1=transpose(alma_readsynth(f,"Tau1"),[1,2,0])

   FOR i=0,nwv-1 DO PRINT, i, wv(i)
   READ, index, PROMPT="Enter index of Wavelength: "

   si=reform(si(*,*,index))
   tau1=reform(tau1(*,*,index))
   wave_name=STRTRIM(STRING(wv(index),format='(f10.3)'),2)+' mm'

   br_select_idlparam,idlparam
   d=obj_new('br_data',idlparam)
   br_getsnapind,idlparam,snaps
   swap=0 & nsnaps=n_elements(snaps)
   d->readpars, snaps
   d->readmesh
   x=d->getx() & nelx=N_ELEMENTS(x)
   y=d->gety()
   z=d->getz()

   tg=0.0*si

   FOR kk=0, nsnaps-1 DO BEGIN
       dns_var,d,'tg',snaps(kk),swap,var,dim="xz"
       FOR ii=0, nelx-1 DO BEGIN
          tg(ii,k) = -INTERPOL(var(ii,*), z, tau1(ii,*))
       ENDFOR
   print, tg(*,k)
   stop
   ENDFOR



END
