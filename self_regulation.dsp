import("stdfaust.lib");

w(x) = x*2*ma.PI/ma.SR;

clip(in, lower, upper) = in : max(lower) : min(upper);

lp1pint(in, cf) =   (in ,
                    _ : + : *(w(cf) : clip(_, 0, 2)) : fi.pole(1)
                    ) ~ *(-1);

rms(in, window) = in <: * : lp1pint(_, window) : sqrt;

process = _ <:  _ ,
                (   _ ,
                    1 : rms : clip(_, 0, 1) : pow(.25) :    1 , 
                                                            _ : - : *(ma.SR/2)) : lp1pint;
