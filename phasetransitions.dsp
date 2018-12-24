import("stdfaust.lib");

push = button("Dirac");
dirac = max(0, push - push');

ramp = _ / ma.SR : + ~ _; // in signal sets growth rate in Hz
feedback = (0 , (1 / 180)) : - : ramp : +(-.5);

primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311);

primepow(x) = _ <: par(i, x, ba.take(i + 1, primes) , _ : pow);

window = .0001;
delrange = ma.SR * 7;
rms(x) = _ <: * : fi.lowpass(2, x) : sqrt;
norm(x) = (1 , (_ : rms(x))) : /; // dynamical normalisation -- the reference signal is now 1 but it can be based on the RMS of another signal
delay(x) = (x : fi.lowpass(8, window)) * (x : norm(window)) * delrange; // delay modulation
vardel(x) = _ <: de.fdelay5(2^18, delay(x), _); // 6-point LaGrange interpolation for fractional delays

//process(x) = (par(i, 4, +(dirac)) : ro.hadamard(4) : par(i, 4, ma.tanh)) ~ (par(i, 4, vardel(x)) : (par(i, 4, *(1 / 604800 : ramp : +(.5))))); // "x" here will be the signal from a mic; 1/604800 is one week in Hz

process(x) = (par(i, 4, +(dirac)) : ro.hadamard(4) : par(i, 4, ma.tanh)) ~ (par(i, 4, de.delay(delrange, ba.take(i + 61, primes))) : (par(i, 4, *(feedback)))) :> _ , _ : /(2) , /(2);

//process(x) = (par(i, 4, +(dirac)) : ro.hadamard(4) : par(i, 4, ma.tanh)) ~ (par(i, 4, _ <: de.fdelay5(2^18, hslider("delay%i", 0, 0, 192, .000001), _)) : (par(i, 4, *(feedback)))) :> (_ , _) : /(2) , /(2);