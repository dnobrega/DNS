PRO dnsvar_bx, d, name, snaps, swap, $
    var, var_title, var_range, var_log
    UNITS, units
    var=d->getvar(name,snaps,swap=swap)*units.ub
    var_title='B!dx!n (G)'
    var_range=[-5.0,5.0]
    var_log=var_log
END
