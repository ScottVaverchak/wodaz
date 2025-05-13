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

    vfov: f64,
    lookfrom, lookat: Vec3,
    vup: Vec3, 
    u, v, w: Vec3,

    defocus_angle: f64, 
    focus_dist: f64,

    defocus_disk_u, defocus_disk_v: Vec3, 
}

camera_init :: proc(camera: ^Camera, aspect_ratio: f64 = 1.0, image_width: i32 = 100, samples_per_pixel: i32 = 10, max_depth: i32 = 10, vfov: f64 = 90, lookfrom: Vec3 = {0, 0, 0}, lookat: Vec3 = {0, 0, -1}, vup: Vec3 = {0, 1, 0}, defocus_angle: f64 = 0, focus_dist: f64 = 10) { 
    camera.aspect_ratio = aspect_ratio
    camera.image_width = image_width
    camera.samples_per_pixel = samples_per_pixel
    camera.max_depth = max_depth
    camera.vfov = vfov
    camera.lookfrom = lookfrom
    camera.lookat = lookat
    camera.vup = vup
    camera.defocus_angle = defocus_angle
    camera.focus_dist = focus_dist

    camera.pixel_samples_scale = 1.0 / f64(camera.samples_per_pixel)
    
    camera.image_height = i32(f64(camera.image_width) / camera.aspect_ratio)
    camera.image_height = 1 if camera.image_height < 1 else camera.image_height

    theta := math.to_radians(camera.vfov)
    h := math.tan(theta / 2)
    viewport_height := 2 * h * camera.focus_dist
    viewport_width := viewport_height * (f64(camera.image_width) / f64(camera.image_height))
    camera.center = camera.lookfrom

    camera.w = la.normalize(camera.lookfrom - camera.lookat)
    camera.u = la.normalize(la.cross(camera.vup, camera.w))
    camera.v = la.cross(camera.w, camera.u)

    viewport_u := viewport_width * camera.u
    viewport_v := viewport_height * -camera.v

    camera.pixel_delta_u = viewport_u / f64(camera.image_width)
    camera.pixel_delta_v = viewport_v / f64(camera.image_height)

    viewport_upper_left := camera.center - (camera.focus_dist * camera.w) - viewport_u / 2 - viewport_v / 2
    camera.pixel00_loc = viewport_upper_left + 0.5 * (camera.pixel_delta_u + camera.pixel_delta_v)

    defocus_radius := camera.focus_dist * math.tan(math.to_radians(camera.defocus_angle / 2))
    camera.defocus_disk_u = camera.u * defocus_radius
    camera.defocus_disk_v = camera.v * defocus_radius
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
        mat_result : MaterialResult
        mat_ok := false

        switch m in hr.mat.variant { 
        case ^Lambertian:
        mat_result, mat_ok = lambertian_scatter(m, r, &hr).?
        case ^Metal:
        mat_result, mat_ok = metal_scatter(m, r, &hr).?
        case ^Dialectric:
        mat_result, mat_ok = dialectric_scatter(m, r, &hr).?
        }

        return mat_result.attenuation * ray_color(&mat_result.scattered, depth -1, world) if mat_ok else { 0, 0, 0 } 

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
    r := linear_to_gamma(color.r)
    b := linear_to_gamma(color.b)
    g := linear_to_gamma(color.g)

    rbyte := i32(256 * interval_clamp(INTENSITY, r))
    gbyte := i32(256 * interval_clamp(INTENSITY, g))
    bbyte := i32(256 * interval_clamp(INTENSITY, b))

    fmt.printf("{} {} {}\n", rbyte, gbyte, bbyte)
}

@(private="file")
get_ray :: proc(camera: ^Camera, i, j: i32) -> Ray { 
    offset := sample_square()
    pixel_sample := camera.pixel00_loc +
                        ((f64(i) + offset.x) * camera.pixel_delta_u) +
                        ((f64(j) + offset.y) * camera.pixel_delta_v)
    ray_origin := camera.center if camera.defocus_angle <= 0 else defocus_disk_sample(camera)
    ray_direction := pixel_sample - ray_origin
    ray_time := rand.float64()

    return Ray { 
        origin = ray_origin, 
        direction = ray_direction,
        time = ray_time,
    }
}

@(private="file")
defocus_disk_sample :: proc(camera: ^Camera) -> Vec3 {
    p := vec3_random_in_unit_disk()

    return camera.center + (p.x * camera.defocus_disk_u) + (p.y * camera.defocus_disk_v)

}

@(private="file")
sample_square :: proc() -> Vec3 { 
    return Vec3 { 
        rand.float64() - 0.5, 
        rand.float64() - 0.5, 
        0
    }
}

@(private="file")
linear_to_gamma :: proc(linear_comp: f64) -> f64 { 
    return math.sqrt(linear_comp) if linear_comp > 0 else 0
}
