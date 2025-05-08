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

    camera : Camera 
    camera_init(&camera, aspect_ratio, image_width, samples_per_pixel, max_depth)

    world := HitList { 
        objects = make([dynamic]Hittable, 0, 16)
    }

    defer delete(world.objects)

    material_ground := create_lambert_material({0.8, 0.8, 0.0}) 
    material_center := create_lambert_material({0.1, 0.2, 0.5}) 
    material_left := create_metal_material({0.8, 0.8, 0.8}) 
    material_right := create_metal_material({0.8, 0.6, 0.2}) 

    ground_sphere := create_hittable_sphere({  0, -100.5, -1.0 }, 100.0, material_ground)
    center_sphere := create_hittable_sphere({  0,0, -1.2 }, 0.5, material_center)
    left_sphere := create_hittable_sphere({ -1.0, 0, -1.0 }, 0.5, material_left)
    right_sphere := create_hittable_sphere({ 1.0, 0, -1.0 }, 0.5, material_right)

    append(&world.objects, ground_sphere^, center_sphere^, left_sphere^, right_sphere^) 

    camera_render(&camera, &world)
    
}


