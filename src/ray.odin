package main

import "core:math"
import la "core:math/linalg"

Ray :: struct { 
    origin: Vec3,
    direction: Point3
}

ray_at :: proc(ray: ^Ray, t: f64) -> Point3 { 
    return ray.origin + t * ray.direction
}


