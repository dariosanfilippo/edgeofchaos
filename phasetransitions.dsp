import("ds.lib"); // imports all other faust libs besides "ds"

// GLOBAL PARAMETERS

rate = 1; // global responsiveness of the system
order = 4; // order of the network, i.e., number of delay lines

// AUXILIARY FUNCTIONS

dirac = 1 - 1';
var_del(in, del) = de.fdelay5(2^21, del, in);

// ADAPTIVE PROCESSING

feedback = 0 : - (1/180) : ds.line : +(-.5);
is1 = _ <: _ , fi.lowpass(4, rate) : ds.dyn_norm_rms(rate) : ds.clip(_, -1, 1);
as_delay(n) = is1 : *(7.25) : ds.prime_base_pow(n);

// MAIN

process(x) = (par(i, order, +(dirac)) : ro.hadamard(order) : par(i, order, 
ma.tanh)) ~ (par(i, order, _ , (x : as_delay(i)) : var_del) : (par(i, order, 
*(feedback)))) :> _ , _ : / (order/2) , / (order/2);
