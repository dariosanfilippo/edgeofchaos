import("stdfaust.lib");
import("ds.lib");

process(x) =    m2.lin_map(x, 1, 10),
                m2.pow_map(x, 4, 2, 20),
                m2.log_map(x, 3, -5, 5),
                m2.par_map(x, 1.5, 3, 7),
                m2.pcw_map(x, .3, .1, 8, 12, 18, -2, -6);
