package main

import la "core:math/linalg"

Material :: struct { 
    id: i32,

    variant: union { 
        ^Lambertian,
        ^Metal,
    } 
}

new_material:: proc($T: typeid) -> ^T { 
    e := new(T)
    e.variant = e 
    return e
}

Lambertian :: struct { 
    using material: Material,

    albedo: Vec3,
}


create_lambert_material :: proc(albedo: Vec3) -> ^Material { 
    material := new_material(Lambertian)
    
    #partial switch e in material.variant { 
    case ^Lambertian:
    e.albedo = albedo 
    }

    return material 
}

LambertianResult :: struct { 
    attenuation: Vec3, 
    scattered: Ray,
}

lambertian_scatter :: proc(lamb: ^Lambertian, r: ^Ray, rec: ^HitRecord) -> Maybe(LambertianResult) { 
    scatter_direction := rec.normal + vec3_random_unit_vector()
    
    if vec3_near_zero(scatter_direction) do scatter_direction = rec.normal
    
    scattered := Ray { origin = rec.p, direction = scatter_direction }
    attenuation := lamb.albedo

    return LambertianResult { 
        attenuation = attenuation, 
        scattered = scattered 
    }
}

Metal :: struct { 
    using material: Material,

    albedo: Vec3,
    fuzz: f64
}

metal_scatter :: proc(metal: ^Metal, r: ^Ray, rec: ^HitRecord) -> Maybe(LambertianResult) { 
    reflected := vec3_reflect(r.direction, rec.normal)
    reflected = la.normalize(reflected) + (metal.fuzz * vec3_random_unit_vector())
    scattered := Ray { origin = rec.p, direction = reflected }
    attenuation := metal.albedo

    return LambertianResult { 
        attenuation = attenuation,
        scattered = scattered,
    } if la.dot(scattered.direction, rec.normal) > 0 else nil
}

create_metal_material :: proc(albedo: Vec3, fuzz: f64) -> ^Material { 
    material := new_material(Metal)
    
    #partial switch e in material.variant { 
    case ^Metal:
    e.albedo = albedo
    e.fuzz = fuzz
    }

    return material 
}

