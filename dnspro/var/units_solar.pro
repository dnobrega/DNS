PRO units_solar, units

    ul  = 1e8
    ut  = 1e2
    ur  = 1e-7
    uu  = ul/ut
    up  = ur*(ul/ut)^2.0
    uee = uu^2
    ue  = ur*uee
    bk  = 1.380658E-16
    mh  = 1.6726219E-24
    me  = 9.1093897E-28
    ub  = uu*(4.*!pi*ur)^0.5
    cl  = 2.99792458e+10
    ui  = ub/ul*cl/4./!pi
    uel = ub*ul/ut/cl
    kr  = 0.1
    qe  = 4.80325e-10 
    
 units={$
   ul:ul,$      ; Lenght units: [Mm] -> [cm]
   ut:ut,$      ; Time units: [hs] -> [s]
   ur:ur,$      ; Density units: [..]  ->  [g/cm^3]
   uu:uu,$      ; Velocity units: [Mm/hs] -> [cm/s]
   up:up,$      ; Pressure units: [..] -> [erg/cm^3]
   uee:uee,$    ; Internal energer per grams: [..] -> [erg/g]
   ue:ue,$      ; Internal energy per unit volume units: [..] -> [erg/cm^3]
   bk:bk,$      ; Boltzmann constant: [erg/K]
   mh:mh,$      ; Hydrogen mass: [g]
   me:me,$      ; Electron mass: [g]
   kr:kr,$      ; Rosseland opacity: [..] -> [cm2/g]
   cl:cl,$      ; Speed of light: [cm/s]
   qe:qe,$      ; Electron charge: [Statcoulomb]
   ub:ub,$      ; Magnetic field units: [..] -> [G]
   ui:ui,$      ; J current units [..] -> G/s
   uel:uel}     ; Efield units  [..] -> statV/cm = G                

END
