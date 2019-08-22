;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;--------------------------------------------------------------------------------- 
;                                   DNS_VAR
;--------------------------------------------------------------------------------- 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PRO dns_var,d,snaps,var,name,swap,$
            dim=dim, donde=donde, title1d=title1d,ytitle1d=ytitle1d,$
            title2d=title,btitle=btitle,$
            log=log,yrange=yrange,$
            myrange=myrange,mylog=mylog,$
            varunits=varunits, $
            shiftx=shiftx,$
            ix0=ix0,iy0=iy0,iz0=iz0, $
            ixstep=ixstep, iystep=iystep, izstep=izstep,$
            ixf=ixf,iyf=iyf,izf=izf,$
            im0=im0, imf=imf, imstep=imstep, $
            x3d=x3d,y3d=y3d,z3d=z3d

  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                   HELP                                      
;---------------------------------------------------------------------------------

  IF (n_params() LT 5) THEN BEGIN
      message,$
      'dns_var,d,snaps,var,name,swap,'+$
            'd1=d1,donde=donde, title1d=title1d,ytitle1d=ytitle1d,'+$
            'title2d=title,btitle=btitle,'+$
            'log=log,yrange=yrange,'+$
            'myrange=myrange,mylog=mylog,'+$
            'varunits=varunits,'+$
            'shiftx',/info
      RETURN
  ENDIF

  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;---------------------------------------------------------------------------------
;                                  VARIABLES                                    
;--------------------------------------------------------------------------------- 


;---------------------------------------------------------------------------------

;Cargamos las unidades del codigo
 UNITS, units

;Logaritmo en eje y
 log=0
 title=''

CASE name OF

    ;Temperatura
    'tg' : BEGIN
           var=d->getvar(name,snaps,swap=swap)
           varunits='T (K)'
           yrange=[1.d3,2.0d6]
           log=1
           END

    ;Campo magnetico en direccion X
    'bx' : BEGIN
           var=d->getvar(name,snaps,swap=swap)*units.ub 
           varunits='B!dx!n (G)'
           yrange=[-5.0,5.0]
           log=log
           END

    ;Valor absoluto del campo magnetico en direccion X
    'bvx' : BEGIN
            var=ABS(d->getvar('bx',snaps,swap=swap)*units.ub)
            varunits='| B!dx!n | (G)'
            yrange=[1.0,1.5d3]
            log=1
            END

    ;Campo magnetico en direccion Y
     'by' : BEGIN
            var=d->getvar(name,snaps,swap=swap)*units.ub
            varunits='B!dy!n (G)'
            yrange=[-1,1]
            log=log
            END


    ;Campo magnetico horizontal
     'bh' : BEGIN
            bx=d->getvar('bx',snaps,swap=swap)*units.ub
            by=d->getvar('by',snaps,swap=swap)*units.ub
            var=sqrt(xup(bx)^2.D + zup(by)^2.d)
            varunits='B!dh!n (G)'
            yrange=[1d-1,100]
            log=1
            END

    ;Valor absoluto del campo magnetico en direccion Y
    'bvy' : BEGIN
            var=ABS(d->getvar('by',snaps,swap=swap)*units.ub)
            varunits='| B!dy!n | (G)'
            yrange=[1,1000]  
            log=1
            END

    ;Campo magnetico en direccion Z
     'bz' : BEGIN
            var=d->getvar(name,snaps,swap=swap)*units.ub*(-1.0)
            varunits=' B!dz!n (G)'
            yrange=[-15.,15.d]
            log=log
            END

    ;Valor absoluto del campo magnetico en direccion Z
     'bvz' : BEGIN
             var=(ABS(d->getvar('bz',snaps,swap=swap)*units.ub))
             varunits='| B!dz!n | (G)'
             yrange=[1.d-3,1.d5]
             log=1
             END

    ;Cuadrado del modulo del campo magnetico
     'b2' : BEGIN
            var=d->getvar(name,snaps,swap=swap)*units.ub
            varunits='B!u2!n (G!u2!n)'
            yrange=[1.d-1,3.d]
            log=1
            END

     ;Modulo del campo magnetico
     'modb' : BEGIN
              var=d->getvar(name,snaps,swap=swap)*units.ub
              varunits='B (G)'
              yrange=[1.d,1.d3]
              log=1
              END
     

     ;Beta del plasma
     'beta' : BEGIN
              var=d->getvar(name,snaps,swap=swap)
              title='beta'
              varunits=''
              yrange=[1.d-2,1.d5]
              log=1
              END
           

    ;Divergencia del campo magnetico                                                              
     'divb' : BEGIN
              var=(d->getvar('divb',snaps,swap=swap))
              var=abs(var)/(d->getvar('modb',snaps,swap=swap))
              title='| divB | / | B |'
              varunits=' Mm!u-1!n'
              yrange=[1d-6,1d]
              log=1
              END

    ;Presion gaseosa
     'pg' : BEGIN
            var=d->getvar('p',snaps,swap=swap)*units.up;/aux
            title='P!dg!n'
            varunits='erg cm!u-3!n'
            yrange=[1.d-4,1.d8]
            log=1
            END

    ;Presion total
     'pt' : BEGIN
            pg=d->getvar('p',snaps,swap=swap)*units.up
            pb=d->getvar('b2',snaps,swap=swap)/2.*units.up
            var=pg + pb
            title='P!dtotal!n'
            varunits='erg cm!u-3!n'
            yrange=[1d-2,1d8]
            log=1
            END

    ;Densidad
     'r' : BEGIN
           var=d->getvar(name,snaps,swap=swap)*units.ur
           title='!4q!3'
           varunits='g cm!u-3!n'
           yrange=[1.d-15,1.d-11]
           log=1
           END

    ;Densidad cuadrado
     'r2' : BEGIN
            var=(d->getvar('r',snaps,swap=swap)*units.ur)^2.D
            title='!4q!3 !u2!n'
            varunits='g!u2!n cm!u-6!n'
            yrange=[1.d-16,1.d-8]
            log=1
            END
     
     ;Densidad electronica
     'nel' : BEGIN
             nel=d->getvar(name,snaps,swap=swap)
             var=nel
             title='n!del!n'
             varunits='cm!u-3!n'
             yrange=[1.d3,1.d14]
             log=1
             END

     ;Energia interna
     'e' : BEGIN
           var=d->getvar(name,snaps,swap=swap)*units.ue
           title='e'
           varunits='erg cm!u-3!n'
           yrange=[1.d-15,2.d-14]
           log=1
           END
     

     'ee' : BEGIN
           var=d->getvar(name,snaps,swap=swap)*units.uee
           title='ee'
           varunits='dyn cm!u-2!n'
           yrange=[1d12,1d15]
           log=1
           END
                                                                                                                                    
     ;Velocidad al cuadrado
     'u2' : BEGIN
            var=d->getvar(name,snaps,swap=swap)*10*10.
            title='u!u2!n'
            varunits='km!u2!n s!u-2!n'
            yrange=[0.1,3.d2]
            log=1
            END


     ;Modulo de la velocidad
     'modu' : BEGIN
              var=d->getvar(name,snaps,swap=swap)*10.
              title='u'
              varunits='km s!u-1!n'
              yrange=[1,300]
              log=1
              END
      
     ;Velocidad en direccion x
      'ux' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*10.
             title='u!dx!n'
             varunits='km s!u-1!n'
             yrange=[-5,5]
             log=log
             END

     ;Valor absoluto de la velocidad en direccion X                                     
     'uvx' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*10
             title='| u!dx!n |'
             varunits='km s!u-1!n'
             yrange=[0, 10]
             log=1
             END
  
     ;Velocidad en direccion y
      'uy' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*10.
             title='u!dy!n'
             varunits='km s!u-1!n'
             yrange=[-50,50]
             log=log
             END

     ;Valor absoluto de la velocidad en direccion Y
     'uvy' : BEGIN
             var=ABS(d->getvar('uy',snaps,swap=swap)*10)
             title='| u!dy!n |'
             varunits='km s!u-1!n'
             yrange=[0, 10]
             log=1
             END
     
     ;Velocidad en direccion Z
      'uz' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*(-10.)
             title='u!dz!n'
             varunits='km s!u-1!n'
             yrange=[-100,100]
             log=log
          END



     ;Valor absoluto de la velocidad en direccion Z
     'uvz' : BEGIN
             var=abs(d->getvar('uz',snaps,swap=swap)*10)
             title='| u!dz!n |'
             varunits='km s!u-1!n'
             yrange=[0, 10]
             log=1
             END


     ;Divergencia de la velocidad
     'divu' : BEGIN
              ux=d->getvar('ux',snaps,swap=swap)
              ;uy=d->getvar('uy',snaps,swap=swap)
              uz=d->getvar('uz',snaps,swap=swap)
              var=(ddxup(ux)  + ddzup(uz))/100
              title=textoidl('\nabla \cdot u ')
              varunits='s!u-1!n'
              yrange=[-1.5, -0.5]
              log=0
              END

     ;Tiempo caracteristico de cambio en velocidad
     'tau_divu' : BEGIN
                  ;ux=d->getvar('ux',snaps,swap=swap)
                  ;uy=d->getvar('uy',snaps,swap=swap)
                  ;uz=d->getvar('uz',snaps,swap=swap)
                  var=100./((ddxup(d->getvar('ux',snaps,swap=swap))  + ddzup(d->getvar('uz',snaps,swap=swap))))
                  title='| div u | !u-1!n '
                  varunits=' s '
                  yrange=[-1e-5,1e-5]
                  log=0
                  END

      ;Eta amb 
     'eta_amb' : BEGIN
                  var=d->getvar(name,snaps,swap=swap)*units.ul*units.ul/units.ut
                  title=textoidl("\eta_{amb}")
                  varunits='cm!u2!n s!u-1!n'
                  mylog=1
                  yrange=[min(var),max(var)]
                  log=log
                  END


     'tau_etaamb' : BEGIN
                    var=d->getvar('eta_amb',snaps,swap=swap)*units.ul*units.ul/units.ut
                    var2=1d8/d->getvar('job',snaps,swap=swap)
                    var=var2^2/var
                    title=textoidl("\eta_{amb}")
                    varunits='cm!u2!n s!u-1!n'
                    mylog=1
                    yrange=[1d,1d3]
                    log=log
                    END

     'eta_ambb' : BEGIN
                  var=d->getvar(name,snaps,swap=swap)*units.ul*units.ul/units.ut/units.ub/units.ub
                  title=textoidl("\eta_{amb}")
                  varunits='cm!u2!n s!u-1!n G!u-2!n'
                  mylog=1
                  yrange=[0.9*min(var),1.1*max(var)]
                  log=log
                  END

      ;Eta hall 
      'eta_hall' : BEGIN
                  var=d->getvar(name,snaps,swap=swap)*100/units.ut
                  title=textoidl("\eta_{Hall}")
                  varunits='km!u2!n s!u-1!n'
                  yrange=[-10,10]
                  log=log
                  END

      ;Eta hallb 
      'eta_hallb' : BEGIN
                  var=d->getvar(name,snaps,swap=swap)*100/units.ut/units.ub/units.ub
                  title=textoidl("'\eta'_{Hall}")
                  varunits='km!u2!n s!u-1!n G!u-2!n'
                  yrange=[min(var),max(var)]
                  log=log
                  END
     
      ;Tau500
      'tau' : BEGIN
             var=d->getvar(name,snaps,swap=swap)
             title='tau'
             varunits=''
             yrange=[1.d-6,1d6]
             log=1
             END
 
     ;Velocidad del sonido
      'cs' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*10 
             pfm5_var, d, snaps, job, "job",swap,mylog=0
             var(WHERE(job LT 1d-3))=1d7
             title='c!ds!n'
             varunits='km s!u-1!n'
             yrange=[1,1d3]
             log=1
             END

     ;Velocidad de Alfven
      'va' : BEGIN
             var=d->getvar(name,snaps,swap=swap)*10
             title='v!da!n'
             varunits='km s!u-1!n'
             yrange=[10.0,1000]
             log=0
             END

     ;tiempo de alfven
      'ta' : BEGIN
             var=d->getvar("va",snaps,swap=swap)
             var=1./d->getvar('job',snaps,swap=swap)/var
             title='t!da!n'
             varunits='s'
             yrange=[1d-3,1000]
             log=1
             END


     ;Numero de Mach sonico
       'mn' : BEGIN
              var=d->getvar(name,snaps,swap=swap)
              title='M!ds!n'
              varunits=''
              yrange=[1,1.5]
              log=1
              END

     ;Numero de Mach alfvenico
       'man' : BEGIN
               var=d->getvar(name,snaps,swap=swap)
               title='M!da!n'
               varunits=''
               yrange=[1d-3,1d2]
               log=1
               END
     
     ;Calentamiento termico
      'qspitz' : BEGIN
                 var=d->getvar(name,snaps,swap=swap)*units.ue/units.ut
                 title='q!dspitz!n'
                 varunits='erg cm!u-3!n s!u-1!n'
                 yrange=[-1d-6, 1.d-6]*units.ue/units.ut
                 log=0
                 END
      

     ;Tiempo caracteristimo para la conduccion termica
      'tauqspitz' : BEGIN
                    var=d->getvar('qspitz',snaps,swap=swap)
                    e=d->getvar('e',snaps,swap=swap)
                    var=ABS(e/(var + 1d-30))*100.  
                    title=TEXTOIDL('\tau_{qspitz}')
                    varunits='s'
                    yrange=[1d-6, 1.d6]
                    log=1
                    END


      ;Q joule
       'qjoule': BEGIN
                 var=d->getvar(name,snaps,swap=swap)*units.ue/units.ut
                 title='q!djoule!n'
                 varunits='erg s!u-1!n'
                 yrange=[1.d-5, 1.d1]
                 log=0
                 END

       'eta': BEGIN
                 var=d->getvar("qjoule",snaps,swap=swap)
                 var=1./(var/(d->getvar("j2",snaps,swap=swap))*units.ut)
                 title='eta'
                 varunits='Mm!u2!n s!u-1!n'
                 yrange=[1.d-8,1d8]
                 log=1
                 END       


      ;tauqjoule                                                                                                  
       'tauqjoule': BEGIN
                   var=d->getvar('qjoule',snaps,swap=swap)
                   e=d->getvar('e',snaps,swap=swap)
                   var=ABS(e/(var + 1d-20)*100.)
                   title=TEXTOIDL('\tau_{qjoule}')
                   varunits='s'
                   yrange=[1d-1, 1.d3]
                   log=1
                   END

     ELSE: BEGIN
           print, "Variable no definida en PFM5_VAR"
           var=d->getvar(name,snaps,swap=swap)
           varunits=''
           yrange=[min(var),max(var)]
           title=''
           END
ENDCASE


 sizevar=size(var)
 print, sizevar
 IF sizevar(0) EQ 3 THEN BEGIN

IF (N_ELEMENTS(ix0)+ N_ELEMENTS(ixf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(ix0) EQ 0) THEN im0=0 ELSE im0=ix0
   IF (N_ELEMENTS(ixf) EQ 0) THEN imf=sizevar(1)-1 ELSE imf=ixf
   IF (NOT KEYWORD_SET(ixstep)) THEN imstep=1 ELSE imstep=ixstep
   var=var(im0 : imf,*,*)
   x3d = 1 & y3d = 0 & z3d = 0
ENDIF

IF (N_ELEMENTS(iy0)+ N_ELEMENTS(iyf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(iy0) EQ 0) THEN im0=0 ELSE im0=iy0
   IF (N_ELEMENTS(iyf) EQ 0) THEN imf=sizevar(2)-1 ELSE imf=iyf
   IF (NOT KEYWORD_SET(iystep)) THEN imstep=1 ELSE imstep=iystep
   var=var(*,im0 : imf,*)
   x3d = 0 & y3d = 1 & z3d = 0
ENDIF

IF (N_ELEMENTS(iz0)+ N_ELEMENTS(izf) GE 1) THEN BEGIN
   IF (N_ELEMENTS(iz0) EQ 0) THEN im0=0 ELSE im0=iz0
   IF (N_ELEMENTS(izf) EQ 0) THEN imf=sizevar(3)-1 ELSE imf=izf
   IF (NOT KEYWORD_SET(izstep)) THEN imstep=1 ELSE imstep=izf
   var=var(im0 : imf,*,*)
   x3d = 0 & y3d = 0 & z3d = 1
ENDIF

ENDIF

PRINT, "------------------------------------------"
PRINT, " ",name, snaps, MIN(var,/NAN), MAX(var,/NAN)
PRINT, "------------------------------------------"





;Hacemos shift
;IF (KEYWORD_SET(shiftx)) THEN BEGIN
;   var=shift(var,shiftx,0)         ;Desplaza las columnas
;ENDIF

;Creamos el resto de titulos
;IF (KEYWORD_SET(dim)) THEN BEGIN
; IF (dim EQ 'z') THEN BEGIN
;     IF (N_ELEMENTS(donde) EQ 0 ) THEN BEGIN
;         title1d='< '+title+' > vs Z'
;      ENDIF ELSE BEGIN
;         x=d->getx()
;         title1d=title+' in X='+STRTRIM(STRING(x(donde), FORMAT='(F6.1)'),2)
;      ENDELSE
; ENDIF
; IF (dim EQ 'x') THEN BEGIN
;     IF (N_ELEMENTS(donde) EQ 0 ) THEN BEGIN
;        title1d='< '+title+' > vs X' 
;     ENDIF ELSE BEGIN
;         z=d->getz()
;         title1d=title+' in Z='+STRTRIM(STRING(-z(donde), FORMAT='(F6.1)'),2)
;     ENDELSE
; ENDIF
; ENDIF

 ytitle1d=varunits
 btitle=varunits
 title2d=title

;Escala y logaritmo
IF (KEYWORD_SET(myrange)) THEN yrange=myrange
IF N_ELEMENTS(mylog) NE 0 THEN log=mylog
IF log EQ 1 THEN BEGIN
   var=ALOG10(var)
   IF yrange(0) EQ 0 THEN yrange(0)=1.
   yrange=ALOG10(yrange)
ENDIF

END
