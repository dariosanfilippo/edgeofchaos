import("stdfaust.lib");
import("ds.lib");

process = op.pitch_shift(os.oscsin(1000), 5, nentry("factor", 1, -16, 16, .01), nentry("frame", 1, -5, 5, .01)) : au.inspect(0, -1, 1);

