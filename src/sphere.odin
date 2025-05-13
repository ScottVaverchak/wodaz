package main
 
import la "core:math/linalg"

Sphere :: struct { 
    using hittable: Hittable, 

    radius: f64,
    mat: ^Material,

    center: Ray
}

create_static_hittable_sphere :: proc(center: Vec3, radius: f64, mat: ^Material) -> ^Hittable { 
    hittable := new_hittable(Sphere)
    
    switch e in hittable.variant { 
    case ^Sphere:
        e.radius = radius
        e.mat = mat
        e.center = Ray { origin = center, direction = {0, 0, 0}}
    }

    return hittable
}

create_moving_hittable_sphere :: proc(center1: Vec3, center2: Vec3, radius: f64, mat: ^Material) -> ^Hittable { 
    hittable := new_hittable(Sphere)
    
    switch e in hittable.variant { 
    case ^Sphere:
        e.radius = radius
        e.mat = mat
        e.center = Ray { origin = center1, direction = center2 - center1}
    }

    return hittable
}

sphere_hit :: proc(sphere: ^Sphere, r: ^Ray, inter: Interval) -> Maybe(HitRecord) { 
    current_center := ray_at(&sphere.center, r.time)
    oc := current_center - r.origin
    a := la.vector_length2(r.direction)
    h := la.vector_dot(r.direction, oc)
    c := la.vector_length2(oc) - sphere.radius * sphere.radius
    disc := h*h - a*c
    if disc < 0 { 
        return nil
    }

    sqrtd := la.sqrt(disc)
    root := (h - sqrtd) / a;
    
    if !interval_surrounds(inter, root) { 
        root = (h + sqrtd) / a 

        if !interval_surrounds(inter, root) {
            return nil
        }
    }

    record : HitRecord

    record.t = root
    record.p = ray_at(r, record.t)
    outward_normal := (record.p - current_center) / sphere.radius
    hitrecord_set_face_normal(&record, r, outward_normal)
    record.mat = sphere.mat

    return record 
}
