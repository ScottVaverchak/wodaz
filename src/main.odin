package main

import "core:fmt"
import "core:math"
import la "core:math/linalg"


main :: proc() {
    last_id : i32 = 0

    aspect_ratio := 16.0 / 9.0
    image_width := i32(400)
    samples_per_pixel := i32(100)
    max_depth := i32(50)
    vfov := 90.0

    camera : Camera 
    camera_init(&camera, aspect_ratio, image_width, samples_per_pixel, max_depth, vfov)

    world := HitList { 
        objects = make([dynamic]Hittable, 0, 16)
    }

    defer delete(world.objects)

    R := math.cos(f64(math.PI / 4.0))

    material_left := create_lambert_material({0, 0, 1}) 
    material_right := create_lambert_material({1, 0, 0 }) 

    left_sphere := create_hittable_sphere({ -R, 0, -1.0 }, R, material_left)
    right_sphere := create_hittable_sphere({ R, 0, -1.0 }, R, material_right)

    append(&world.objects, left_sphere^, right_sphere^ ) 

    camera_render(&camera, &world)
    
}


