package main

import "core:fmt"
import la "core:math/linalg"

Vec3 :: [3]f32
Point3 :: Vec3


HitRecord :: struct { 
    p: Point3,
    normal: Vec3,
    t: f32
}

Hittable :: struct { 
    id: i32,
    pos: Vec3, 

    varient: union { ^Sphere } 
}

new_hittable :: proc($T: typeid) -> ^T { 
    e := new(T)
    e.variant = e 
    return e
}

Sphere :: struct { 
    using hittable: Hittable, 

    radius: f32,
}

sphere_hit :: proc(sphere: ^Sphere, r: ^Ray, ray_tmin: f32, ray_tmax: f32) -> (bool, HitRecord) { 
    res := HitRecord {}

    oc := sphere.pos - r.origin
    a := la.vector_length2(r.direction)
    h := la.vector_dot(r.direction, oc)
    c := la.vector_length2(oc) - sphere.radius * sphere.radius
    disc := h*h - a*c
    if disc < 0 { 
        return false, res 
    }

    sqrtd := la.sqrt(disc)
    root := (h - sqrtd) / a;

    if root <= ray_tmin || ray_tmax <= root { 
        root = (h + sqrtd) / a 

        if root <= ray_tmin || ray_tmax <= root {
            return false, res
        }
    }

    res.t = root
    res.p = ray_at(r, res.t)
    res.normal = (res.p - sphere.pos) / sphere.radius

    return true, res
}


main :: proc() {
    last_id : i32 = 0

    aspect_ratio := f32(16.0 / 9.0)
    image_width := i32(400)

    image_height := i32(f32(image_width) / aspect_ratio)
    image_height = 1 if image_height < 1 else image_height

    focal_length := f32(1.0)
    viewport_height := f32(2.0)
    viewport_width := viewport_height * (f32(image_width) / f32(image_height))
    camera_center := Point3 { 0, 0, 0 }

    viewport_u := Vec3 { viewport_width, 0, 0, }
    viewport_v := Vec3 { 0, -viewport_height, 0 }

    pixel_delta_u := viewport_u / f32(image_width)
    pixel_delta_v := viewport_v / f32(image_height)

    viewport_upper_left := camera_center - Vec3 { 0, 0, focal_length } - viewport_u / 2.0 - viewport_v / 2.0
    pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

    fmt.printf("P3\n{} {}\n255\n", image_width, image_height) 

    for j in 0..<image_height { 

        // @TODO(svavs): Proper print lining...
        fmt.eprintf("Scanlines remaining: {}\n", (image_height - j))

        for i in 0..<image_width { 
            pixel_center := pixel00_loc + (f32(i) * pixel_delta_u) + (f32(j) * pixel_delta_v)
            ray_direction := pixel_center - camera_center
            r := Ray { 
                origin = camera_center, 
                direction = ray_direction
            }

            pixel_color := ray_color(&r)

            print_color(pixel_color)

        }
    }
}

print_color :: proc(color: Vec3) { 
    r := i32(255.999 * color.r)
    g := i32(255.999 * color.g)
    b := i32(255.999 * color.b)

    fmt.printf("{} {} {}\n", r, g, b)
}

ray_color :: proc(r: ^Ray) -> Vec3 { 
    t := hit_sphere(Point3 { 0, 0, -1 }, 0.5, r);

    if t > 0.0 {
        n := la.normalize(ray_at(r, t) - Vec3 { 0, 0, -1 })
        return 0.5 * (n + Vec3 { 1, 1, 1 })
    }

    unit_direction := la.normalize(r.direction)
    a := 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Vec3 { 1.0, 1.0, 1.0 } + a * Vec3 {0.5, 0.7, 1.0 }
}

hit_sphere :: proc(center: Point3, radius: f32, r: ^Ray) -> f32 { 
    oc := center - r.origin
    a := la.vector_length2(r.direction)
    h := la.vector_dot(r.direction, oc)
    c := la.vector_length2(oc) - radius * radius
    disc := h*h - a*c

    return -1.0 if disc < 0 else (h - la.sqrt(disc)) / a
}
