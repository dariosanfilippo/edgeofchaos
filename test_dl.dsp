import("stdfaust.lib");
import("ds.lib");

size = 2^16;
test = os.osc(44.1);
index = ba.period(size);
rate = 4410;
dl(in, del) = de.fdelayltv(6, size, del, in);
zc_index(pos) = (test : ip.zc),
                index : ba.sAndH,
                        pos : dl;

get_zc_index(r) =   (   ba.pulse(r),
                        index : ba.sAndH),
                    (   ba.pulse(r),
                        (no.noise : +(1) : *(.5) : *(size) : int : zc_index) : ba.sAndH) : - : m2.wrap(_, 0, size);

process =   (   test,
                get_zc_index(rate) : dl),
            test,
            get_zc_index(rate)/size,
            ba.pulse(rate);
