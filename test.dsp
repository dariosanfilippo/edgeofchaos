import("stdfaust.lib");
import("ds.lib");

process(x) = op.pitch_shift(x, 5, nentry("factor", 0, -16, 16, .01), nentry("frame", 0, -5, 5, .01));

