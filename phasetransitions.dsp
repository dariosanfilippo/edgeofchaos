import("stdfaust.lib");

ny = ma.SR/2;
speriod = 1/ma.SR;
rate = 1;
order = 4;
primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311);

dirac = 1 - 1';

rt60(x) = .001 , (speriod , max(x, .001) : /) : pow;
peak_env(in, release) = abs(in) : max(_, _) ~ *(release : rt60);

line = _ / ma.SR : + ~ _; // in signal sets growth rate in Hz

clip(in, lower, upper) = in : max(lower) : min(upper);

prime_base_pow(n) = ba.take(n + 1, primes) , _ : pow;

var_del(in, del) = de.fdelay5(2^18, del, in);

rms(in, window) = in <: * : fi.lowpass(2, window) : sqrt;
norm_fact_rms(ref, target, window) = (ref , window : rms) , (target , window : rms) : /; // reference power-input power ratio (with responsiveness parameter)
dyn_norm_rms(ref, target, window) = ref , target , window : norm_fact_rms , target : *; // dynamical normalisation

clip_int(in, lower, upper) = (_ , in : + : clip(_, lower, upper)) ~ _;
crossover(in, cf) = (in : fi.lowpass(2, cf)) , (in : fi.highpass(2, cf));
spec_bal(in, cf, window) = in , cf : crossover <: (_ , window : rms : -(0)) , (_ , window : rms) : +;
spec_ten(in, window) = ((in , _,  window : spec_bal) , (in, window : rms) : / : /(ma.SR) : *(window) : clip_int(_, 0, 1) : *(ny)) ~ _;

feedback = 0 : - (1 / 180) : line : +(-.5);
is1 = _ <: _ , fi.lowpass(4, rate) : dyn_norm_rms(rate) : clip(_, -1, 1);
as_delay(n) = is1 : *(7.25) : prime_base_pow(n);

process(x) = (par(i, order, +(dirac)) : ro.hadamard(order) : par(i, order, ma.tanh)) ~ (par(i, order, _ , (x : as_delay(i)) : var_del) : (par(i, order, *(feedback)))) :> _ , _ : / (order / 2) , / (order / 2) , x , feedback , (par(i, order, (x : as_delay(i)))) , ma.SR;
