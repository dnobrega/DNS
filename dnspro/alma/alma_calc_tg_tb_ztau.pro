PRO ALMA_CALC_TG_TB_ZTAU


   f=alma_synthfiles()
   si=transpose(alma_readsynth(f,"Stokes_I"),[1,2,0])
   wv=alma_readsynth(f,"Wavelength")
   nwv=n_elements(wv)
   tau1=transpose(alma_readsynth(f,"Tau1"),[1,2,0])

   FOR i=0,nwv-1 DO PRINT, i, wv(i)
   READ, index, PROMPT="Enter index of Wavelength: "

   wave_name=STRTRIM(STRING(wv(index),format='(f10.3)'),2)+'mm'

   br_select_idlparam,idlparam
   d=obj_new('br_data',idlparam)
   br_getsnapind,idlparam,snaps
   swap=0 & nsnaps=n_elements(snaps)
   d->readpars, snaps
   d->readmesh
   x=d->getx() & nelx=N_ELEMENTS(x)
   y=d->gety() & nely=N_ELEMENTS(y)
   z=-reverse(d->getz())


   tb=reform(si(*,*,index),nelx,nely,nsnaps)
   tau1=reform(tau1(*,*,index),nelx,nely,nsnaps)
   tg=fltarr(nelx,nely,nsnaps)

   FOR kk=0, nsnaps-1 DO BEGIN
       dns_var,d,'tg',snaps(kk),swap,var,dim="xz"
       FOR ii=0, nelx-1 DO BEGIN
           FOR jj=0, nely-1 DO  tg(ii,jj,kk) = INTERPOL(reform(var(ii,jj,*)), z, tau1(ii,jj,kk))
       ENDFOR
   ENDFOR

   save, tg, tb, tau1, filename='tg_tb_tau1_'+wave_name+".sav" 

END
