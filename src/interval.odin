package main

import "core:math"

Interval :: struct { 
    min: f64,
    max: f64
}


interval_create :: proc(min: f64, max: f64) -> Interval { 
    return Interval { 
        min = min, 
        max = max,
    }
}


interval_create_default :: proc() -> Interval {
    return interval_create(math.F64_MIN, math.F64_MAX)
}


interval_size :: proc(inter: Interval) -> f64 { 
    return inter.max - inter.min
}

interval_contains :: proc(inter: Interval, x: f64) -> bool { 
    return inter.min <= x && x <= inter.max
}

interval_surrounds :: proc(inter: Interval, x: f64) -> bool { 
    return inter.min < x && x < inter.max
}

interval_clamp :: proc(inter: Interval, x: f64) -> f64 { 
    if x < inter.min do return inter.min
    if x > inter.max do return inter.max 

    return x
}


INTERVAL_EMPTY :: Interval { min = math.INF_F64,  max = math.NEG_INF_F64 } 
INTERVAL_UNIVERSE :: Interval { min = math.NEG_INF_F64,  max = math.INF_F64 } 
