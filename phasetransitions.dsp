import("stdfaust.lib");

// SYSTEM PARAMETERS

// positive or negative FB coeff.
fb_phase = 1;
// global responsiveness of the system in Hz
response =  1 , 
            (lp1pint(1.1, .1) : min(_, 1-1/3600)) : -;
// prime numbers starting from the nth position
prime_offset = 49;
// jump among successive primes
prime_leap = 1;
// feedback growth (unity) rate in seconds
rate = 3600;
// order of the network, i.e., number of delay lines
order = 8; 

// MATH

primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 
67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 
151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 
239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311);
ny = ma.SR/2;
speriod = 1/ma.SR;
// NAN-safe divider
divider(x1, x2) = ba.if(x2 : ==(0), 0, (x1 , 
                                        x2 : /)); 
// angular frequency
w(x) = x*2*ma.PI/ma.SR; 
// 60-dB decay in a desired time
rt60(x) =   .001 , 
            (   speriod , 
                max(x, .001) : /) : pow; 
prime_base_pow(n) = ba.take(n, primes) , 
                    _ : pow;
// line: in signal sets x/y ratio
line =  _ , 
        ma.SR : / : + 
                    ~ _; 
// rate of change
delta(in, t) =  in , 
                (in : de.delay(max_del, t*ma.SR)) : -; 

// AUXILIARY CONSTANTS

// delay lengths maxima
max_del = 2^20; 
// interpolation size (samples) for sdelay
int_size = 1024; 
// order of Lagrange interpolation
pol_order = 6; 
// stability threshold (for linear FDN)
margin = 1/sqrt(order); 
// nonlinearities/saturators
nl = (tanh, sinatan, parabolic, hyperbolic);

// AUXILIARY FUNCTIONS

dirac = 1-1';
step(n) = 1 <:  _ , 
                @(n) : -;
// sample counter
timer = 1 : fi.pole(1); 
// minimum delay allowed for correct performance
min_del = max((pol_order-1)/2, _);
// fixed delay
del_int(in, del) = in : de.delay(max_del, del*ma.SR); 
// linear interpolation
del_lin(in, del) = in : de.sdelay(max_del, 1024, del*ma.SR); 
// polynomial interpolation
del_pol(in, del) = in : de.fdelayltv(pol_order, max_del, del*ma.SR : min_del); 
// 6-ch output busses for different orders
order4 = si.bus(4) <:   (si.bus(4) :> par(i, 2,   /(2))) , 
                        si.bus(4);
order8 = si.bus(8) <:   (   (   si.bus(6) , 
                                (_ : !) , 
                                (_ : !)) , 
                            (   (   par(i, 6, (_ : !)) , 
                                    (si.bus(2))
                                ) <: si.bus(6))
                        ) :> par(i, 6, /(2));
order16 = si.bus(order) :> par(i, order/2, /(2)) : order8;
// 2-ch output bus for different orders
output2 = si.bus(order) :>  /(order/2) , 
                            /(order/2);

// STABILITY PROCESSING

// hard clipping
clip(in, lower, upper) = in : max(lower) : min(upper); 
// reference_power-input_power ratio (with responsiveness parameter)
norm_fact_rms(ref, target, window) =    (   ref , 
                                            window : rms) , 
                                        (   target , 
                                            window : rms) : divider; 
// dynamical normalisation based on RMS
dyn_norm_rms(ref, target, window) = (ref , 
                                    target , 
                                    window) :   norm_fact_rms , 
                                                target : *; 

// STABILITY PROCESSING/NLTF (bounded saturators)

tanh(x) = (exp(2*x)-1)/(exp(2*x)+1);
cubic(x) = select3( cond,   -2/3, 
                            x-(x*x*x/3), 
                            2/3)
with {
    cond =  (   (x : >(-1)) ,
	        (x : <(1)) : &) ,
	    (x : >=(1))*2 :> _;
}; 
sinatan(x) = x/sqrt(1+x*x); 
parabolic(x) = ba.if(abs(x) : >=(2),    ma.signum(x), 
                                        x*(1-abs(x/4)));
hyperbolic(x) = x/(1+abs(x));

// FILTERS

// bounded integrator
clip_int(in, lower, upper) =    (_ , 
                                in : + : clip(_, lower, upper)
                                ) ~ _;
// spectrum splitter
crossover(in, cf) = lp1p1z(in, cf) , 
                    hp1p1z(in, cf); 
// 1-pole lowpass based on naive integration
lp1pint(in, cf) =   (in , 
                    _ : + : *(w(cf) : clip(_, 0, 2)) : fi.pole(1)
                    ) ~ *(-1);
// 1-pole highpass based on naive integration
hp1pint(in, cf) = in-lp1pint(in, cf);
// 1-pole-1-zero lowpass
lp1p1z(in, cf) =    in*a0 , 
                    in'*a0*a1 : + : + 
                                    ~ *(b1)
with {
    a0 = (1-b1)/2;
    a1 = 1;
    b1 =    (1-sin(w(cf))) , 
            cos(w(cf)) : divider;
};
// 1-pole-1-zero highpass
hp1p1z(in, cf) =    in*a0 , 
                    in'*a0*a1 : + : + 
                                    ~ *(b1)
with {
    a0 = (1+b1)/2;
    a1 = -1;
    b1 =    (1-sin(w(cf))) , 
            cos(w(cf)) : divider;
};

// INFORMATION PROCESSING

// infinitely fast attack and adjustable release
peak_env(in, release) = abs(in) :   max(_, _) 
                                    ~ *(release : rt60); 
// root mean square measurement using lowpasses
rms(in, window) = in <: * : lp1pint(_, window) : sqrt; 
// spectral energy difference (RMS) at a splitting point (Hz)
spec_bal(in, cf, window) =  in , 
                            cf : crossover <:   (   _ , 
                                                    window : rms : *(-1)) , 
                                                (   _ , 
                                                    window : rms) : +;
// spectral tendency (weighted median)
spec_ten(in, window) =  (   (   in , 
                                _ , 
                                window : spec_bal) , 
                            (   in , 
                                window : rms) : divider : /(ma.SR) : *(window) : clip_int(_, 0, 1) : *(ny)
                        ) ~ _;

// TIME-VARIANCE AND ADAPTIVITY

// information signal 
is_delay =  1 , 
            seq(i, 4, lp1pint(_, response)) , 
            response : dyn_norm_rms : tanh : *(.5);
// information signal
is_fb = (   _ , 
            50 : spec_ten : /(ny)) , 
        .02 : delta <: * : *(500) : tanh , 
                                    60 : peak_env : *(10) : +(1);
// adaptive signal
as_delay(n) = is_delay : +(1) : prime_base_pow(n) : *(.0001) : -(speriod);
// adaptive signal
as_fb = 1/rate , 
        is_fb : divider : line : +(margin*1.01) : *(fb_phase);

// SECTIONS

input = par(i, order, +(dirac));
matrix = ro.hadamard(order);
mixer = si.bus(order) :> /(order) <: si.bus(order);
router = ro.interleave(order, 2);
dcblocker = par(i, order,   _ , 
                            10 : hp1p1z);
delay(x) = par(i, order,    _ , 
                            (x : as_delay(i*prime_leap+prime_offset)) : del_pol);
nltf = par(i, order, ba.take(i : %(4) : +(1), nl));
fb = par(i, order, *(as_fb));
output = case{  (4) => order4; 
                (8) => order8; 
                (16) => order16;}(order);

// MAIN

process(x) =    (input : nltf : dcblocker)
                ~ (si.bus(order) <: matrix ,
                                    mixer : router : fb : delay(x)) <: output;
