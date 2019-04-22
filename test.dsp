import("stdfaust.lib");
import("ds.lib");

process =   m2.ph(1000, 0) : m2.diff : <(0),
            os.square(1000);
