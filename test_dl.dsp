import("stdfaust.lib");
import("ds.lib");

size = 2^16;
g_pos = no.noise : abs : *(size) : int;
index = ba.period(size);
dl_pol(in, del) = de.fdelayltv(6, size, del, in);
dl_lin(in, del) = in : de.fdelay(size, del);

zc_index_up(input, pos) =   (   (input : ip.zc),
                                (m2.diff(input) : >=(0)) : &),
                            index : ba.sAndH,
                                    pos : dl_lin;

zc_index_down(input, pos) = (   (input : ip.zc),
                                (m2.diff(input) : <(0)) : &),
                            index : ba.sAndH,
                                    pos : dl_lin;

read_grain(input, fb, pitch, rate, pos) =   (   trigger,
                                                index : ba.sAndH),
                                            (   trigger,
                                                (   input, 
                                                    pos, 
                                                    fb : zc_index) : ba.sAndH) : - : +(shift) : m2.wrap(_, 0, size)
with {
    zc_index(input, position, direction) = ba.if(   (m2.diff(direction) : >=(0)), 
                                                    (   input, 
                                                        position : zc_index_up), 
                                                    (   input, 
                                                        position : zc_index_down)) : +(1);
    trigger =   check 
                ~ _  
    with {
        check(ready) =  (fb : ip.zc),
                        (m2.line_reset(rate, ready) : >=(1)) : &;
    };
    shift = (1-pitch)*(1/rate)*ma.SR*m2.line_reset(rate, trigger);
};

grains(input, pitch, rate, pos) =   (input,
                                    (   input,
                                        _,
                                        pitch,
                                        rate, 
                                        pos : read_grain) : dl_pol) 
                                    ~ _;

process(input) = grains(input, 4, 1000, g_pos);

