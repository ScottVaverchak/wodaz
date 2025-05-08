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


    world := HitList { 
        objects = make([dynamic]Hittable, 0, 16)
    }

    defer delete(world.objects)

    sphere1 := create_hittable_sphere({0, 0, -1}, 0.5)
    sphere2 := create_hittable_sphere({0, -100.5, -1}, 100)
    append(&world.objects, sphere1^, sphere2^) 

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

            pixel_color := ray_color(&r, &world)

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

