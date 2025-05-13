package main

import "core:math"
import la "core:math/linalg"
import "core:math/rand"

Material :: struct { 
    id: i32,

    variant: union { 
        ^Lambertian,
        ^Metal,
        ^Dialectric,
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

MaterialResult :: struct { 
    attenuation: Vec3, 
    scattered: Ray,
}

lambertian_scatter :: proc(lamb: ^Lambertian, r: ^Ray, rec: ^HitRecord) -> Maybe(MaterialResult) { 
    scatter_direction := rec.normal + vec3_random_unit_vector()
    
    if vec3_near_zero(scatter_direction) do scatter_direction = rec.normal
    
    scattered := Ray { origin = rec.p, direction = scatter_direction, time = r.time }
    attenuation := lamb.albedo

    return MaterialResult { 
        attenuation = attenuation, 
        scattered = scattered 
    }
}

Metal :: struct { 
    using material: Material,

    albedo: Vec3,
    fuzz: f64
}

metal_scatter :: proc(metal: ^Metal, r: ^Ray, rec: ^HitRecord) -> Maybe(MaterialResult) { 
    reflected := vec3_reflect(r.direction, rec.normal)
    reflected = la.normalize(reflected) + (metal.fuzz * vec3_random_unit_vector())
    scattered := Ray { origin = rec.p, direction = reflected, time = r.time }
    attenuation := metal.albedo

    return MaterialResult { 
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

Dialectric :: struct { 
    using material: Material,

    refraction_index: f64, 
}

dialectric_scatter :: proc(dia: ^Dialectric, r: ^Ray, rec: ^HitRecord) -> Maybe(MaterialResult) { 
    ri := (1.0 / dia.refraction_index) if rec.front_face else dia.refraction_index

    unit_dir := la.normalize(r.direction)
    
    cos_theta := math.min(la.vector_dot(-unit_dir, rec.normal), 1.0)
    sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)

    cannot_refract := ri * sin_theta > 1.0

    direction : Vec3

    if cannot_refract || dialectric_reflectance(cos_theta, ri) > rand.float64() { 
        direction = vec3_reflect(unit_dir, rec.normal)
    } else { 
        direction = vec3_refract(unit_dir, rec.normal, ri)
    }

    return MaterialResult { 
        attenuation = Vec3 { 1, 1, 1 },
        scattered = Ray { origin = rec.p, direction = direction, time = r.time },
    }
}

dialectric_reflectance :: proc(cosine, refraction_index: f64) -> f64 { 
    r0 := (1 - refraction_index) / (1 + refraction_index)
    r0 = r0 * r0 
    return r0 + (1 - r0) * math.pow((1 - cosine), 5)
}

create_dialectric_material :: proc(refraction_index: f64) -> ^Material { 
    material := new_material(Dialectric)

    #partial switch e in material.variant { 
    case ^Dialectric: 
    e.refraction_index = refraction_index
    }

    return material
}
