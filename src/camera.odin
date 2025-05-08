package main

import "core:fmt"
import "core:math"
import la "core:math/linalg"

Camera :: struct { 
    aspect_ratio: f32,
    image_width: i32, 
    image_height: i32, 
    center: Point3, 
    pixel00_loc: Point3, 
    pixel_delta_u: Vec3, 
    pixel_delta_v: Vec3,
}

camera_init :: proc(camera: ^Camera, aspect_ratio: f32, image_width: i32) { 
    camera.aspect_ratio = aspect_ratio
    camera.image_width = image_width
    
    camera.image_height = i32(f32(camera.image_width) / camera.aspect_ratio)
    camera.image_height = 1 if camera.image_height < 1 else camera.image_height

    focal_length := f32(1.0)
    viewport_height := f32(2.0)
    viewport_width := viewport_height * (f32(camera.image_width) / f32(camera.image_height))
    camera.center = Point3 { 0, 0, 0 }

    viewport_u := Vec3 { viewport_width, 0, 0, }
    viewport_v := Vec3 { 0, -viewport_height, 0 }

    camera.pixel_delta_u = viewport_u / f32(camera.image_width)
    camera.pixel_delta_v = viewport_v / f32(camera.image_height)

    viewport_upper_left := camera.center - Vec3 { 0, 0, focal_length } - viewport_u / 2.0 - viewport_v / 2.0
    camera.pixel00_loc = viewport_upper_left + 0.5 * (camera.pixel_delta_u + camera.pixel_delta_v)
}

camera_render :: proc(camera: ^Camera, world: ^HitList) { 
    fmt.printf("P3\n{} {}\n255\n", camera.image_width, camera.image_height) 

    for j in 0..<camera.image_height { 

        // @TODO(svavs): Proper print lining...
        fmt.eprintf("Scanlines remaining: {}\n", (camera.image_height - j))

        for i in 0..<camera.image_width { 
            pixel_center := camera.pixel00_loc + (f32(i) * camera.pixel_delta_u) + (f32(j) * camera.pixel_delta_v)
            ray_direction := pixel_center - camera.center
            r := Ray { 
                origin = camera.center, 
                direction = ray_direction
            }

            pixel_color := ray_color(&r, world)

            render_color(pixel_color)

        }
    }
}

@(private="file")
ray_color :: proc(r: ^Ray, world: ^HitList) -> Vec3 { 
    hr, ok := hitlist_hit(world, r, interval_create(0, math.INF_F32)).?
    if ok {
        return 0.5 * (hr.normal + Vec3 { 1, 1, 1 })
    }

    unit_direction := la.normalize(r.direction)
    a := 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Vec3 { 1.0, 1.0, 1.0 } + a * Vec3 {0.5, 0.7, 1.0 }
}

@(private="file")
render_color :: proc(color: Vec3) { 
    r := i32(255.999 * color.r)
    g := i32(255.999 * color.g)
    b := i32(255.999 * color.b)

    fmt.printf("{} {} {}\n", r, g, b)
}
