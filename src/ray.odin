package main

import "core:math"
import la "core:math/linalg"

Ray :: struct { 
    origin: Vec3,
    direction: Point3
}

ray_at :: proc(ray: ^Ray, t: f32) -> Point3 { 
    return ray.origin + t * ray.direction
}

ray_color :: proc(r: ^Ray, world: ^HitList) -> Vec3 { 
    hr, ok := hitlist_hit(world, r, 0, math.INF_F32).?
    if ok {
        return 0.5 * (hr.normal + Vec3 { 1, 1, 1 })
    }

    unit_direction := la.normalize(r.direction)
    a := 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Vec3 { 1.0, 1.0, 1.0 } + a * Vec3 {0.5, 0.7, 1.0 }
}

