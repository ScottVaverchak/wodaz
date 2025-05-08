package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import la "core:math/linalg"

Camera :: struct { 
    aspect_ratio: f64,
    image_width: i32, 
    image_height: i32, 
    max_depth: i32, 
    samples_per_pixel: i32,
    pixel_samples_scale: f64,
    center: Point3, 
    pixel00_loc: Point3, 
    pixel_delta_u: Vec3, 
    pixel_delta_v: Vec3,
}

camera_init :: proc(camera: ^Camera, aspect_ratio: f64, image_width: i32, samples_per_pixel: i32, max_depth: i32) { 
    camera.aspect_ratio = aspect_ratio
    camera.image_width = image_width
    camera.samples_per_pixel = samples_per_pixel
    camera.max_depth = max_depth

    camera.pixel_samples_scale = 1.0 / f64(camera.samples_per_pixel)
    
    camera.image_height = i32(f64(camera.image_width) / camera.aspect_ratio)
    camera.image_height = 1 if camera.image_height < 1 else camera.image_height

    focal_length := 1.0
    viewport_height := 2.0
    viewport_width := viewport_height * (f64(camera.image_width) / f64(camera.image_height))
    camera.center = Point3 { 0, 0, 0 }

    viewport_u := Vec3 { viewport_width, 0, 0, }
    viewport_v := Vec3 { 0, -viewport_height, 0 }

    camera.pixel_delta_u = viewport_u / f64(camera.image_width)
    camera.pixel_delta_v = viewport_v / f64(camera.image_height)

    viewport_upper_left := camera.center - Vec3 { 0, 0, focal_length } - viewport_u / 2.0 - viewport_v / 2.0
    camera.pixel00_loc = viewport_upper_left + 0.5 * (camera.pixel_delta_u + camera.pixel_delta_v)
}

camera_render :: proc(camera: ^Camera, world: ^HitList) { 
    fmt.printf("P3\n{} {}\n255\n", camera.image_width, camera.image_height) 

    for j in 0..<camera.image_height { 

        // @TODO(svavs): Proper print lining...
        fmt.eprintf("Scanlines remaining: {}\n", (camera.image_height - j))

        for i in 0..<camera.image_width { 
            pixel_color : Vec3

            for sample in 0..<camera.samples_per_pixel { 
                r := get_ray(camera, i, j)
                pixel_color += ray_color(&r,camera.max_depth, world)
            }

            render_color(camera.pixel_samples_scale * pixel_color)

        }
    }
}

@(private="file")
ray_color :: proc(r: ^Ray, depth: i32, world: ^HitList) -> Vec3 { 
    if depth <= 0 do return { 0, 0, 0 }

    hr, ok := hitlist_hit(world, r, interval_create(0.001, math.INF_F64)).?
    if ok {
        direction := vec3_random_on_hemisphere(hr.normal)
        rr := Ray { origin = hr.p, direction = direction }
        return 0.5 * ray_color(&rr, depth - 1, world)
    }

    unit_direction := la.normalize(r.direction)
    a := 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Vec3 { 1.0, 1.0, 1.0 } + a * Vec3 {0.5, 0.7, 1.0 }
}

// @TODO(sjv): This all seems verbose for now reason atm
@(private="file")
INTENSITY :: Interval { min = 0, max = 0.999 }

@(private="file")
render_color :: proc(color: Vec3) { 
    r := i32(256 * interval_clamp(INTENSITY, color.r))
    g := i32(256 * interval_clamp(INTENSITY, color.g))
    b := i32(256 * interval_clamp(INTENSITY, color.b))

    fmt.printf("{} {} {}\n", r, g, b)
}

@(private="file")
get_ray :: proc(camera: ^Camera, i, j: i32) -> Ray { 
    offset := sample_square()
    pixel_sample := camera.pixel00_loc +
                        ((f64(i) + offset.x) * camera.pixel_delta_u) +
                        ((f64(j) + offset.y) * camera.pixel_delta_v)
    ray_origin := camera.center
    ray_direction := pixel_sample - ray_origin

    return Ray { 
        origin = ray_origin, 
        direction = ray_direction 
    }
}

@(private="file")
sample_square :: proc() -> Vec3 { 
    return Vec3 { 
        rand.float64() - 0.5, 
        rand.float64() - 0.5, 
        0
    }
}
