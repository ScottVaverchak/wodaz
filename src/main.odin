package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import la "core:math/linalg"


main :: proc() {
    last_id : i32 = 0

    aspect_ratio := 16.0 / 9.0
    image_width := i32(400)
    samples_per_pixel := i32(100)
    max_depth := i32(50)
    vfov := 20.0
    lookfrom := Vec3 { 13, 2, 3 }
    lookat := Vec3 { 0, 0, 0 }
    vup := Vec3 { 0, 1, 0 }

    defocus_angle := 0.6
    focus_dist := 10.0

    // @TODO(sjv): cam code is wierd and broken - redo it
    // @TODO(sjv): Create a camera_default() that uses basic settings (just pass pos and lookat, v-up assumed)
    camera : Camera 
    camera_init(&camera, aspect_ratio, image_width, samples_per_pixel, max_depth, vfov, lookfrom, lookat, vup, defocus_angle, focus_dist)

    world := HitList { 
        objects = make([dynamic]Hittable, 0, 16)
    }

    defer delete(world.objects)

    ground_material := create_lambert_material({0.5, 0.5, 0.5})
    ground_sphere := create_static_hittable_sphere({ 0, -1000, 0}, 1000, ground_material);

    append(&world.objects, ground_sphere^)

    for a in -11..<11 { 
        for b in -11..<11 { 
            choose_mat := rand.float64()
            center := Vec3 { 
                f64(a) + 0.9 * rand.float64(),
                0.2,
                f64(b) + 0.9 * rand.float64()
            }

            if la.length(center - { 4, 0.2, 0}) > 0.9 {
                if choose_mat < 0.8 { 
                    albedo := vec3_random() * vec3_random()
                    mat := create_lambert_material(albedo)
                    center2 := center + Vec3 { 0, rand.float64_range(0, 0.5), 0}
                    sphere := create_moving_hittable_sphere(center, center2, 0.2, mat)
                    append(&world.objects, sphere^)
                } else if choose_mat < 0.95 { 
                    albedo := vec3_random_range(0, 0.5)
                    fuzz := rand.float64_range(0, 0.5)
                    mat := create_metal_material(albedo, fuzz)
                    sphere := create_static_hittable_sphere(center, 0.2, mat)
                    append(&world.objects, sphere^)
                } else { 
                    mat := create_dialectric_material(1.5)
                    sphere := create_static_hittable_sphere(center, 0.2, mat)
                    append(&world.objects, sphere^)
                }

            }
        }
    }

    material1 := create_dialectric_material(1.5)
    material2 := create_lambert_material({0.4, 0.2, 0.1})
    material3 := create_metal_material({ 0.7, 0.6, 0.5}, 0.0)

    sphere1 := create_static_hittable_sphere({ 0, 1, 0}, 1.0,  material1)
    sphere2 := create_static_hittable_sphere({ -4, 1, 0}, 1.0, material2)
    sphere3 := create_static_hittable_sphere({ 4, 1, 0}, 1.0, material3)

    append(&world.objects, sphere1^, sphere2^, sphere3^)

    camera_render(&camera, &world)
    
}


