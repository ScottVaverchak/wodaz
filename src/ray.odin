package main

Ray :: struct { 
    origin: Vec3,
    direction: Point3
}

ray_at :: proc(ray: ^Ray, t: f32) -> Point3 { 
    return ray.origin + t * ray.direction
}
