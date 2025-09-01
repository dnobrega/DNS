PRO qfactor, bx, by, bz, xreg=xreg, yreg=yreg, zreg=zreg, csFlag=csFlag, factor=factor, $
             RK4Flag=RK4Flag, step=step, tol=tol, scottFlag=scottFlag, maxsteps=maxsteps, $
             twistFlag=twistFlag, nbridges=nbridges, odir=odir, fstr=fstr, $
             no_preview=no_preview, tmpB=tmpB, RAMtmp=RAMtmp, traceFlag=traceFlag, traceint=traceint, max_trace_steps=max_trace_steps
;+
; PURPOSE:
;   Calculate the squashing factor Q at the photosphere or a cross section
;   or a box volume, given a 3D magnetic field with uniform grids
; 
;   For details see:
;     Liu et al. (2016, ApJ)  
;
; PROCEDURES USED:
; ------IDL procedures used
;   doppler_color
;      
; ------FORTRAN procedures used
;   qfactor.f90
;   trace_bline.f90
;   trace_scott.f90
;
; ------COMPILATION (one of them): 
;      ifort -o qfactor.x qfactor.f90 -fopenmp -mcmodel=medium -O3 -xHost -ipo
;   gfortran -o qfactor.x qfactor.f90 -fopenmp -mcmodel=medium -O3
;
;   -O3, -xHost, -ipo are for a better efficiency
;  the efficiency of ifort (version 2021.4.0) is slightly (~1.40 times) faster than gfortran (version 9.3.0)
;  please specify the path of qfactor.x at the line of "spawn, 'qfactor.x' " in this file, or move qfactor.x to the $PATH (e.g. /usr/local/bin/) of the system
;
;
; INPUTS               
;   Bx, By, Bz: 3D magnetic field.
;   
; OPTIONAL INPUTS  
;   xreg, yreg, zreg:  pixel coordinates of the field region, in arrays of two elements
;                      default is to include all available pixels		               
;                 --- If (xreg[0] ne xreg[1]) AND (yreg[0] ne yreg[1]) AND (zreg[0] ne zreg[1]) AND NOT csFlag
;                     calculate Q in a box volume
;                     invoke vFlag
;                 --- If (xreg[0] eq xreg[1]) OR (yreg[0] eq yreg[1]) or (zreg[0] eq zreg[1])
;                     calculate Q in a cross section perpendicular to X or Y or Z axis
;                     invoke cFlag 
;                 --- If zreg=[0, 0], calculate Q at the photosphere
;                     invoke z0Flag 
;                 --- If csFlag is set, see below
;                     invoke cFlag
;   
;   csFlag:     to calculate Q in a cross section defined by three points; default is 0
;               point0=[xreg[0],yreg[0],zreg[0]] ; origin
;               point1=[xreg[1],yreg[1],zreg[0]] ; point0 -> point1, first axis
;               point2=[xreg[0],yreg[0],zreg[1]] ; point0 -> point2, second axis
;      
;   factor:     to bloat up the original resolution, i.e. grid spacing = 1/factor; default is 4 
;
;   RK4Flag:    to trace bline by RK4; default is 0B (RKF45)
;   			   
;   step:       step size in tracing field lines for RK4; default=1.0
;
;   tol:        tolerance of a step in RKF45; default is 10.^(-4)
;
;   scottFlag:  calculate Q and Q_perp by the method of Scott_2017_ApJ_848_117; default is 0B (method 3 of Pariat_2012_A&A_541_A78)
;               memory occupation in qfactor.x: 
; 			if scottFlag=0B, 3D magnetic field + some 2D arrays 
; 			if scottFlag=1B, 3D magnetic field + some 2D arrays + grad_unit_vec_B (3 times as the 3D magnetic field)
;
;   maxsteps:   maxium steps for stracing a field line at one direction; default is 40*(nx+ny+nz)/step
;
;   twistFlag:  to calculate twist number Tw; see Liu et al. (2016, ApJ); default is 0
;
;   nbridges:   number of processors to engage; default is 8
;		
;   odir:       directory to save the results
;		
;   fstr:       filename to save the results
; 
;   no_preview: don't produce PNG images for preview; default is 0B
;
;   tmpB:       use temporary() to Bx, By, Bz to reduce the memory occupation of 3D magnetic field in IDL after writing b3d.bin to tmp_dir; default is 0B
;
;   RAMtmp:     use RAM (/dev/shm/tmp/) to speed up the data transmission; default is 0B
;		if invoked, please run only one task of qfactor.pro simultaneously on one machine
;
;
; OUTPUTS:
;   q/qcs/q3d:  squashing factor 
;  
;   q_perp:     q_perp in Titov 2007, ApJ, 660, 863
;
;   slogq/slogq_perp:            sign(Bz) x log_10(Q/Q_\perp); if q = NaN, then slogq = 0.0. Calculated with all the field lines
;   slogq_orig/slogq_perp_orig:  only include field lines with both footpoints on the photoshere
;  
;   twist/twist3d:       twist number = \int \mu_0 J \cdot B /(4\pi) B^2 ds
;
;   rboundary/rsboundary/reboundary: (s:start point, e:end point)
;                nature of the ends of field lines, see 'subroutine vp_rboundary' in trace_bline.f90
;                0 - inside
;                1 - end at zmin
;                2 - end at zmax
;                3 - end at ymin
;                4 - end at ymax
;                5 - end at xmin
;                6 - end at xmax
;                7 - others
;   rboundary3d=rsboundary3d+8*reboundary3d; For saving storage
;
;   rF/rsF/reF: coordinates of mapping points
; 
;   length: length of field lines
; 
;
; MODIFICATION HISTORY:
;   Developed by R. Liu, J. Chen and Peijing, Zhang @ USTC
;   
;   Jun 30,2014 R. Liu @ USTC, IDL edition 
;   Jul  2,2014 R. Liu, introduce nchunks > nbridges to utilize idle child processes
;   Apr 21,2015 R. Liu and J. Chen, deal with field lines pass through the boundary other than bottom
;   Apr 29,2015 R. Liu and J. Chen, further optimization on shared memory
;   Apr 30,2015 R. Liu, correct the size of qmap
;   Apr 27,2015 R. Liu, qcs
;   Jun 15,2015 J. Chen, Fortran Edition, correct foot points with RK4_Boundary
;   Jul  8,2015 J. Chen, q3d
;   Oct 29,2015 J. Chen, deal with field lines touching the cut plane: use the plane quasi-perp to the field line  
;   Nov 1, 2015 J. Chen,
;		(1) fuse qcs and qfactor in qfactor.f90;  
;		(2) the cross section can be paralleled to the photosphere;
;		(3) set tmp_dir;	  
;   Nov 4, 2015 J. Chen, introduce rboundary3d=byte(rsboundary3d+8*reboundary3d),
;		so if rboundary3d[i, j, k] eq 9B, both two mapping surfaces of q3d[i, j, k] are photosphere;		
;   Jun 22,2016 J. Chen, add the map of field line length
;   Oct 30,2017 J. Chen, add the map of Bnr=abs(Bn_local/Bn_target) at the photosphere; correct the output of Q: Modify -1,0 to NaN
;   Aug 28,2018 J. Chen, supplement Q at maginal points
;   May  1,2021 Peijing Zhang and J. Chen, trace field line with RKF45; RK4 is remainded, modify classic RK4 to the 3/8-rule RK4
;   May  1,2021 J. Chen, adapted to gfortran compiler
;   Jun  1,2021 J. Chen, supplement Q at the point where surronding 4 points have different mapping planes;
;                        forcibly convert the input Bx, By, Bz to float arrays in IDL (Real(4) in Fortran)
;   Jun  5,2021 J. Chen, deal part of the points where surronding 4 points have different mapping planes with the method of Scott_2017_ApJ_848_117
;   Jun 10,2021 J. Chen, provide a keyword of maxsteps for the case that has extremely long field lines
;   Jun 11,2021 J. Chen, add the coordinates of mapping points to '*.sav' data
;   Jun 13,2021 J. Chen, mark 0 for inside and 7 for others in 'subroutine vp_rboundary'
;   Jul  5,2021 J. Chen, switch the order of indexes of Bfield in trace_bline.f90 for a better efficiency
;   Jul  9,2021 J. Chen, provide the option with the method of Scott_2017_ApJ_848_117, and q_perp as an output
;   Jul 24,2021 J. Chen, improve I/O between IDL and Fortran
;   Dec  1,2021 J. Chen, optimize the correction of foot point
;   Dec 13,2021 J. Chen, adjust tol or step by incline
;   Dec 25,2021 J. Chen, remove the dependency of SolarSoftWare
;   Jan 21,2022 J. Chen, fix a bug in trace_scott.f90 in case ny != nz
;   Jan 26,2022 J. Chen, fix a bug of RKF45 in case the difference between RK4 and RK5 is 0
;   Jan 30,2022 J. Chen, remove the color table of doppler_color_mix, due to the poor recognizability of green-white-yellow
;   Feb 16,2022 J. Chen, reduce the memory occupation for 3D case in qfactor.x
;   Apr 27,2022 J. Chen, 
;		(1) fix a bug of "segmentation fault" during the output of qfactor.x;
;		(2) calculate slogq in qfactor.x, sign2d.pro is not more necessary;
;		(3) forcibly assign the minimum value of Q to 2, the theoretical minimum;
;		(4) zreg[0] can be non-zero for 3D case;
;		(5) add a keyword of tmpB;
; 		(6) cut_str can be a format of '(i0)', '(f0.1)' or '(f0.2)', according to the value of input
;   Apr 29,2022 J. Chen, extract subroutine round_weigh() for interpolation
;   May 10,2022 J. Chen, determine qx, qy, qz, z0flag, cflag, vflag in qfactor.x
;   May 19,2022 J. Chen, check the existence of nulls on grids; add a keyword of RAMtmp
;
;   This software is provided without any warranty. Permission to use,
;   copy, modify. Distributing modified or unmodified copies is granted
;   provided this disclaimer and information are included unchanged.
;-

;----------------------------------------------------------------------------------------------
; check input; region of output
sbx=size(Bx)
sby=size(By)
sbz=size(Bz)

if sbx[0] ne 3 or sby[0] ne 3 or sbz[0] ne 3 then message, 'Bx, By and Bz must be 3D arrays!'
if sbx[1] ne sby[1] or sbx[1] ne sbz[1] or $
   sbx[2] ne sby[2] or sbx[2] ne sbz[2] or $
   sbx[3] ne sby[3] or sbx[3] ne sbz[3] then message, 'Bx, By and Bz must have the same dimensions!' 
nx=sbz[1] & ny=sbz[2] & nz=sbz[3]

; check the existence of nulls on grids, to avoid "segmentation fault occurred" in qfactor.x
ss=where((bx eq 0.0) and (by eq 0.0) and (bz eq 0.0))
n_ss=n_elements(temporary(ss))
if (n_ss gt 3) then message, string(n_ss)+" nulls (B=0) on grids! Too many!"


if ~keyword_set(xreg) then xreg=[0, nx-1]
if ~keyword_set(yreg) then yreg=[0, ny-1]
if ~keyword_set(zreg) then zreg=[0,    0]
if n_elements(xreg) ne 2 or n_elements(yreg) ne 2 or n_elements(zreg) ne 2 then $
   message, 'xreg, yreg and zreg must be 2-element arrays!'

if keyword_set(csFlag) then csFlag=1B else csFlag=0B

if total([xreg[0] eq xreg[1], yreg[0] eq yreg[1], zreg[0] eq zreg[1]]) ge 2 then $
message,'Something is wrong with the cross section .......'

if csFlag and (zreg[0] eq zreg[1]) then message,'Something is wrong with the cross section .......'

b2dz=Bz[*,*,0]
;----------------------------------------------------------------------------------------------
if ~keyword_set(nbridges)   then nbridges=8
max_threads=!CPU.HW_NCPU
nbridges=nbridges < max_threads

if  keyword_set(twistFlag)  then twistFlag =1B else twistFlag =0B
if  keyword_set(RK4Flag)    then RK4Flag   =1B else RK4Flag   =0B
if  keyword_set(scottFlag)  then scottFlag =1B else scottFlag =0B
if  keyword_set(traceFlag)  then traceFlag =1B else traceFlag =0B
if  keyword_set(no_preview) then no_preview=1B else no_preview=0B
if  keyword_set(tmpB)       then tmpB      =1B else tmpB      =0B
if  keyword_set(RAMtmp)     then RAMtmp    =1B else RAMtmp    =0B
if ~keyword_set(tol)        then tol=10.0^(-4.)
if ~keyword_set(step)       then step=1.
if ~keyword_set(factor)     then factor=4L
if ~keyword_set(maxsteps)   then maxsteps=long(4*(nx+ny+nz)/step)
;----------------------------------------------------------------------------------------------
; the directory for output
spawn, 'pwd', /noshell, cdir
cdir=cdir[0]
IF STRMID(cdir, STRLEN(cdir)-1) NE '/' THEN cdir=cdir+'/'

if  keyword_set(odir) then  begin 
	preset_odir=1B
	IF STRMID(odir, STRLEN(odir)-1) NE '/' THEN odir=odir+'/'
endif else begin 
	preset_odir=0B
	odir= cdir+'qfactor/'
endelse
spawn,'ls -d '+odir, out, error_out
if (out eq '') then spawn, 'mkdir '+odir
;----------------------------------------------------------------------------------------------
; the temporary directory for the data transmission between Fortran and IDL
if RAMtmp then tmp_dir='/dev/shm/tmp/' else tmp_dir= odir+'tmp/'
spawn,'ls -d '+tmp_dir, out, error_out
if (out eq '') then spawn, 'mkdir '+tmp_dir
dummy=file_search(tmp_dir+'*.txt',count=nf)
if nf ne 0 then spawn,'rm '+tmp_dir+'*.txt'
dummy=file_search(tmp_dir+'*.bin',count=nf)
if nf ne 0 then spawn,'rm '+tmp_dir+'*.bin'
;----------------------------------------------------------------------------------------------
;  transmit data to Fortran
get_lun,unit
openw,  unit, tmp_dir+'head.txt'
printf, unit, long(nx), long(ny), long(nz), long(nbridges), long(factor), long(maxsteps)
printf, unit, float(xreg), float(yreg), float(zreg), float(step), float(tol)
printf, unit, long(twistFlag), long(RK4flag), long(scottFlag), long(csflag), long(traceFlag), long(traceint), long(max_trace_steps)
close,  unit

openw,  unit, tmp_dir+'b3d.bin'
if keyword_set(tmpB) then $
     writeu, unit, float(temporary(Bx)), float(temporary(By)), float(temporary(Bz)) $
else writeu, unit, float(Bx), float(By), float(Bz)
close,  unit
;----------------------------------------------------------------------------------------------
; calculate in Fortran
cd, tmp_dir
tnow=systime(1)
spawn, 'qfactor.x' ; if not known by the system, specify the path
tend=systime(1)
cd, cdir
tcalc=tend-tnow

if (tcalc ge 3600) then begin
	time_elapsed=string(tcalc/3600.0,format='(f0.2)')+' hours'
endif else begin 
	if (tcalc ge 60) then time_elapsed=string(tcalc/60.0,format='(f0.2)')+' minutes' $
	                 else time_elapsed=string(tcalc,     format='(f0.2)')+' seconds'
endelse
print, time_elapsed+' elapsed for calculating qfactor' 

; ################################### retrieving results ###################################################### 
qx=0 & qy=0 & qz=0 & q1=0 & q2=0
z0Flag=0 & vFlag=0 & cFlag=0
openr,  unit, tmp_dir+'tail.txt'
readf,  unit, qx, qy, qz, q1, q2
readf,  unit, z0Flag, cFlag, vFlag
close,  unit
;----------------------------------------------------------------------------------------------
; the name of .sav file
if keyword_set(fstr) then begin
	preset_fstr=1B
endif else begin 

	preset_fstr=0B
	
	factor_str='f'+string(factor,format='(i02)')
	cut_str=''
	
	if vflag then begin
		head_str='q3d_' 		
	endif else  begin
		head_str='qcs_'
		 
		xFlag=qx eq 1 ; calculate Q in a cross section parallel to x=0  
		yFlag=qy eq 1 ; calculate Q in a cross section parallel to y=0
		zFlag=qz eq 1 ; calculate Q in a cross section parallel to the photosphere
		
		if xFlag then cut_str0='_x'
		if yFlag then cut_str0='_y'
		if zFlag then cut_str0='_z'
		
		if xFlag then cut_coordinate=xreg[0]
		if yFlag then cut_coordinate=yreg[0]
		if zFlag then cut_coordinate=zreg[0]

		if (xFlag or yFlag or zFlag) then begin
			if abs(cut_coordinate - round(cut_coordinate)) lt 0.0001 then begin 
				cut_str=cut_str0+string(cut_coordinate,'(i0)')
			endif else begin
				if abs(cut_coordinate*10 - round(cut_coordinate*10)) lt 0.0001 then $
					cut_str=cut_str0+string(cut_coordinate,'(f0.1)') $
				else 	cut_str=cut_str0+string(cut_coordinate,'(f0.2)')
			endelse
		endif
	endelse
	
	fstr = head_str + factor_str + cut_str
endelse

file_sav=odir+fstr+'.sav'
;----------------------------------------------------------------------------------------------
; mark the area for calculation on the magnetogram
if (~no_preview) then begin
	cur_device=!D.name
	SET_PLOT, 'Z' 
	DEVICE, SET_RESOLUTION=[nx,ny]
	
	half_maxb2dz= max(abs(b2dz))/2.
	if half_maxb2dz ge 1000 then begin
		tv,bytscl(b2dz,min=-1000,max=1000,/nan)
	endif else begin
		tv,bytscl(b2dz,min=-half_maxb2dz,max=half_maxb2dz,/nan)
	endelse
	
	if csflag then plots,[xreg[0],xreg[1]],[yreg[0],yreg[1]],/dev $
	          else plots,[xreg[0],xreg[1],xreg[1],xreg[0],xreg[0]],[yreg[0],yreg[0],yreg[1],yreg[1],yreg[0]],/dev
	
	im=TVRD(0,0,nx,ny)
	write_png, odir+fstr+'_bz.png', im	

	set_plot, cur_device
	
	; load doppler_color table
	doppler_color, redvector=r_doppler, greenvector=g_doppler, bluevector=b_doppler	
endif

; Q at the photosphere ----------------------------------------------------------------------------------------------
IF z0Flag THEN BEGIN
  ; get data From Fortran
	q=fltarr(q1,q2)
	slogq=fltarr(q1,q2)
  	length=fltarr(q1,q2)
	Bnr=fltarr(q1,q2)
	rF=fltarr(3,q1,q2)
	rboundary=bytarr(q1,q2)
	
	openr, unit, tmp_dir+'qfactor0.bin'
	readu, unit, q, length, Bnr, rF, rboundary
	close, unit
	
	openr, unit, tmp_dir+'slogq.bin'
	readu, unit, slogq
	close, unit
  
  	ss=where(rboundary ne 1)
	slogq_orig=slogq
	if(ss[0] ne -1) then slogq_orig[ss]=0.0

  ; slogQ map  	
  	if (~no_preview) then begin
		im=bytscl(slogq_orig,min=-5,max=5,/nan)
		write_png, odir+fstr+'_slogq_orig.png', im, r_doppler, g_doppler, b_doppler
		
		im=bytscl(slogq,min=-5,max=5,/nan)
		write_png, odir+fstr+'_slogq.png', im, r_doppler, g_doppler, b_doppler	
			
		im=bytscl(length,min=0,max=sqrt(nx^2.0+ny^2.0+nz^2.0),/nan)  
		write_png, odir+fstr+'_length.png', im
		
		ss=where(Bnr eq 0.0)
		Bnr_tmp=Bnr
		if(ss[0] ne -1) then Bnr_tmp[ss]=1.   ;to avoid "Program caused arithmetic error: Floating divide by 0"
		im=bytscl(alog10(Bnr_tmp),min=-2,max=2,/nan) 
		write_png, odir+fstr+'_lg(Bnr).png', im, r_doppler, g_doppler, b_doppler
	endif
		
  ; q_perp map
	if scottFlag then begin
		q_perp=fltarr(q1,q2)
		slogq_perp=fltarr(q1,q2)
		openr, unit, tmp_dir+'q_perp.bin'
		readu, unit, q_perp
		close, unit
		
		openr, unit, tmp_dir+'slogq_perp.bin'
		readu, unit, slogq_perp
		close, unit
		
		slogq_perp_orig=slogq_perp
		if(ss[0] ne -1) then slogq_perp_orig[ss]=0.0
		
		if (~no_preview) then begin
			im=bytscl(slogq_perp_orig,min=-5,max=5,/nan)
			write_png, odir+fstr+'_slogq_perp_orig.png', im, r_doppler, g_doppler, b_doppler	
			im=bytscl(slogq_perp,min=-5,max=5,/nan)
			write_png, odir+fstr+'_slogq_perp.png', im, r_doppler, g_doppler, b_doppler
		endif
	endif  
  
  ; twist map
	if twistFlag then begin
		twist=fltarr(q1,q2)
		openr, unit, tmp_dir+'twist.bin'
		readu, unit, twist
		close, unit
		if (~no_preview) then begin
			im=bytscl(twist,min=-2,max=2,/nan)
			write_png, odir+fstr+'_twist.png', im, r_doppler, g_doppler, b_doppler
		endif
	endif

  ; save results 
	if scottFlag then begin
	 	if twistFlag then save, filename=file_sav, slogq, slogq_orig, q, length, Bnr, rboundary, xreg, yreg, zreg, factor, $
	 	                  rF, q_perp, slogq_perp, slogq_perp_orig, twist $
		             else save, filename=file_sav, slogq, slogq_orig, q, length, Bnr, rboundary, xreg, yreg, zreg, factor, $
		                  rF, q_perp, slogq_perp, slogq_perp_orig
	endif else begin
		if twistFlag then save, filename=file_sav, slogq, slogq_orig, q, length, Bnr, rboundary, xreg, yreg, zreg, factor, rF, twist $
		             else save, filename=file_sav, slogq, slogq_orig, q, length, Bnr, rboundary, xreg, yreg, zreg, factor, rF
	endelse
ENDIF 

; Q at the cross section ----------------------------------------------------------------------------------------------
IF cFlag THEN BEGIN

	qcs=fltarr(q1,q2)
	length=fltarr(q1,q2)
	rsF=fltarr(3,q1,q2)
	reF=fltarr(3,q1,q2)
	rsboundary=bytarr(q1,q2)		
	reboundary=bytarr(q1,q2)
	openr, unit, tmp_dir+'qcs.bin'
	readu, unit, qcs, length, rsF, reF, rsboundary, reboundary
	close, unit
	
	logq=alog10(qcs>1.)
	qcs_orig=qcs
	ss1=where(rsboundary ne 1)
	ss2=where(reboundary ne 1)
	if(ss1[0] ne -1) then qcs_orig[ss1]=!values.F_NAN
	if(ss2[0] ne -1) then qcs_orig[ss2]=!values.F_NAN

	
	if (~no_preview) then begin
		im=bytscl(alog10(qcs_orig>1.),min=0,max=5,/nan)
		write_png, odir+fstr+'_logq_orig.png', im
		
		im=bytscl(logq,min=0,max=5,/nan)
		write_png, odir+fstr+'_logq.png', im

		im=bytscl(length,min=0,max=sqrt(nx^2.0+ny^2.0+nz^2.0),/nan)
		write_png, odir+fstr+'_length.png', im
	endif

	if scottFlag then begin
		q_perp=fltarr(q1,q2)
		openr, unit, tmp_dir+'q_perp.bin'
		readu, unit, q_perp
		close, unit
		
		q_perp_orig=q_perp
		if(ss1[0] ne -1) then q_perp_orig[ss1]=!values.F_NAN
		if(ss2[0] ne -1) then q_perp_orig[ss2]=!values.F_NAN
		logq_perp_orig=alog10(q_perp_orig>1)
		logq_perp=alog10(q_perp>1.)		
		
		if (~no_preview) then begin
			im=bytscl(logq_perp_orig,min=0,max=5,/nan)
			write_png, odir+fstr+'_logq_perp_orig.png', im
			im=bytscl(logq_perp,min=0,max=5,/nan)
			write_png, odir+fstr+'_logq_perp.png', im
		endif
	endif

	if twistFlag then begin	
		twist=fltarr(q1,q2)
		openr, unit, tmp_dir+'twist.bin'
		readu, unit, twist
		close, unit
		if (~no_preview) then begin
			im=bytscl(twist,min=-2,max=2,/nan)
			write_png, odir+fstr+'_twist.png', im, r_doppler, g_doppler, b_doppler
		endif
	endif	   

  ; save results 
	if scottFlag then begin
		if twistFlag then save, filename=file_sav, qcs, qcs_orig, length, rsboundary, reboundary, xreg, yreg, zreg, factor, csFlag, rsF, reF, q_perp, q_perp_orig, twist $
		             else save, filename=file_sav, qcs, qcs_orig, length, rsboundary, reboundary, xreg, yreg, zreg, factor, csFlag, rsF, reF, q_perp, q_perp_orig	
	endif else begin
		if twistFlag then save, filename=file_sav, qcs, qcs_orig, length, rsboundary, reboundary, xreg, yreg, zreg, factor, csFlag, rsF, reF, twist $
		             else save, filename=file_sav, qcs, qcs_orig, length, rsboundary, reboundary, xreg, yreg, zreg, factor, csFlag, rsF, reF
	endelse
	
ENDIF

; Q in the 3D box volume ----------------------------------------------------------------------------------------------
IF vflag THEN BEGIN
  ;get data From Fortran
	q3d=fltarr(qx,qy,qz)
	openr, unit, tmp_dir+'q3d.bin'
	readu, unit, q3d
	close, unit
	
	if scottFlag then begin
		q_perp3d=fltarr(qx,qy,qz)
		openr, unit, tmp_dir+'q_perp3d.bin'
		readu, unit, q_perp3d
		close, unit
	endif  

	if twistFlag then begin
		twist3d=fltarr(qx,qy,qz)
		openr, unit, tmp_dir+'twist3d.bin'
		readu, unit, twist3d
		close, unit
	endif
	
	if (zreg[0] eq 0.0) and (~no_preview) then begin
		slogq=fltarr(q1,q2)	
		openr, unit, tmp_dir+'slogq.bin'
		readu, unit, slogq
		close, unit
		im=bytscl(slogq,min=-5,max=5,/nan)
		write_png, odir+fstr+'_z0_slogq.png', im, r_doppler, g_doppler, b_doppler
	endif 
		
  ; save results 
	if scottFlag then begin
		if twistFlag then save, filename=file_sav, q3d, xreg, yreg, zreg, factor, q_perp3d, twist3d $
		             else save, filename=file_sav, q3d, xreg, yreg, zreg, factor, q_perp3d
	endif else begin
		if twistFlag then save, filename=file_sav, q3d, xreg, yreg, zreg, factor, twist3d $
		             else save, filename=file_sav, q3d, xreg, yreg, zreg, factor	
	endelse
ENDIF 
;----------------------------------------------------------------------------------------------	
print,"Results are saved in '"+file_sav+"'"

; hourse keeping
spawn, 'rm -r '+tmp_dir
free_lun, unit
if ~(preset_odir) then dummy=temporary(odir)
if ~(preset_fstr) then dummy=temporary(fstr)

print,'--------------------Done--------------------'
END

