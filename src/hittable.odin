package main 

import la "core:math/linalg"

HitRecord :: struct { 
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
}

hitrecord_set_face_normal :: proc(rec: ^HitRecord, r: ^Ray, outward_normal: Vec3) { 
    rec.front_face = la.vector_dot(r.direction, outward_normal) < 0
    rec.normal = outward_normal if rec.front_face else -outward_normal
}

Hittable :: struct { 
    id: i32,
    pos: Vec3, 

    variant: union { ^Sphere } 
}

HitList :: struct {
    objects: [dynamic]Hittable,
}

// @TODO(sjv): This is a bad name
hitlist_hit :: proc(hl: ^HitList, r: ^Ray, inter: Interval) -> Maybe(HitRecord) {
    record : Maybe(HitRecord)

    closest_so_far := inter.max

    for obj in hl.objects { 
        switch e in obj.variant { 
        case ^Sphere:
            inter2 := interval_create(inter.min, closest_so_far)
            hr, ok := sphere_hit(e, r, inter2).?
            if ok { 
                closest_so_far = hr.t
                record = hr
            }
        }
    }

    return record
}

new_hittable :: proc($T: typeid) -> ^T { 
    e := new(T)
    e.variant = e 
    return e
}
