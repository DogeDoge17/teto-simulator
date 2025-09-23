const std = @import("std");
const rl = @import("raylib");

const Rigidbody = struct{
    position: rl.Vector2,
    velocity: rl.Vector2,
    bounds: rl.Vector2, 

    fn CollideAll(colliders: []rl.Rectangle) bool {
        _ = colliders;
        // if aab b then shove object to the sides of the bounds.
        // if there are 4 collisions, return early for performance* (maybe)
    }
};

