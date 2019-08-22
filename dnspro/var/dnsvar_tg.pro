PRO dnsvar_tg, d, name, snaps, swap, $
    var, var_title, var_range, var_log
    var=d->getvar(name,snaps,swap=swap)
    var_title='T (K)'
    var_range=[1.d3,2.0d6]
    var_log=1
END
