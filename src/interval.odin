package main

import "core:math"

Interval :: struct { 
    min: f32,
    max: f32
}


interval_create :: proc(min: f32, max: f32) -> Interval { 
    return Interval { 
        min = min, 
        max = max,
    }
}


interval_create_default :: proc() -> Interval {
    return interval_create(math.F32_MIN, math.F32_MAX)
}


interval_size :: proc(inter: Interval) -> f32 { 
    return inter.max - inter.min
}

interval_contains :: proc(inter: Interval, x: f32) -> bool { 
    return inter.min <= x && x <= inter.max
}

interval_surrounds :: proc(inter: Interval, x: f32) -> bool { 
    return inter.min < x && x < inter.max
}


INTERVAL_EMPTY :: Interval { min = math.INF_F32,  max = math.NEG_INF_F32 } 
INTERVAL_UNIVERSE :: Interval { min = math.NEG_INF_F32,  max = math.INF_F32 } 
