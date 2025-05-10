package main

import "core:math"
import la "core:math/linalg"
import "core:math/rand"

Vec3 :: [3]f64
Point3 :: Vec3

vec3_random :: proc() -> Vec3 {
    return Vec3 { 
        rand.float64(),
        rand.float64(),
        rand.float64(),
    }
}

vec3_random_range :: proc(min, max: f64) -> Vec3 { 
    return Vec3 { 
        rand.float64_range(min, max),
        rand.float64_range(min, max),
        rand.float64_range(min, max),
    }
}

vec3_random_unit_vector :: proc() -> Vec3 { 
    for { 
        p := vec3_random_range(-1, 1)
        lensq := la.vector_length2(p)

        if 1e-160 < lensq && lensq <= 1 do return p / la.sqrt(lensq)
    }
}

vec3_random_on_hemisphere :: proc(normal: Vec3) -> Vec3 { 
    on_unit_sphere := vec3_random_unit_vector()

    if(la.vector_dot(on_unit_sphere, normal) > 0.0) { 
        return on_unit_sphere
    } else { 
        return -on_unit_sphere
    }
}

vec3_near_zero :: proc(v: Vec3) -> bool { 
    s := 1e-8
    return (math.abs(v.x) < s) && (math.abs(v.y) < s) && (math.abs(v.z) < s)
}

vec3_reflect :: proc(v, n: Vec3) -> Vec3 { 
    return v - 2 * la.vector_dot(v, n) * n
}

vec3_refract :: proc(uv, n: Vec3, etai_over_etat: f64) -> Vec3 { 
    cos_theta := math.min(la.vector_dot(-uv, n), 1.0)
    r_out_perp := etai_over_etat * (uv + cos_theta * n)
    r_out_para := -math.sqrt(math.abs(1.0 - la.length2(r_out_perp))) * n

    return r_out_perp + r_out_para
}

