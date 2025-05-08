package main

import "core:fmt"
import "core:math"
import la "core:math/linalg"

Vec3 :: [3]f32
Point3 :: Vec3

main :: proc() {
    last_id : i32 = 0

    aspect_ratio := f32(16.0 / 9.0)
    image_width := i32(400)
    samples_per_pixel := i32(100)

    camera : Camera 
    camera_init(&camera, aspect_ratio, image_width, samples_per_pixel)

    world := HitList { 
        objects = make([dynamic]Hittable, 0, 16)
    }

    defer delete(world.objects)

    sphere1 := create_hittable_sphere({0, 0, -1}, 0.5)
    sphere2 := create_hittable_sphere({0, -100.5, -1}, 100)
    append(&world.objects, sphere1^, sphere2^) 

    camera_render(&camera, &world)
    
}


