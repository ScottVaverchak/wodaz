package main
 
import la "core:math/linalg"

Sphere :: struct { 
    using hittable: Hittable, 

    radius: f64,
}

create_hittable_sphere :: proc(pos: Vec3, radius: f64) -> ^Hittable { 
    hittable := new_hittable(Sphere)
    
    switch e in hittable.variant { 
    case ^Sphere:
        e.pos = pos
        e.radius = radius
    }

    return hittable
}

sphere_hit :: proc(sphere: ^Sphere, r: ^Ray, inter: Interval) -> Maybe(HitRecord) { 
    oc := sphere.pos - r.origin
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
    outward_normal := (record.p - sphere.pos) / sphere.radius
    hitrecord_set_face_normal(&record, r, outward_normal)

    return record 
}
