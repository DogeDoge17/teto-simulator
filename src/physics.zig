const std = @import("std");
const rl = @import("raylib");

pub const Rigidbody = struct{
    position: rl.Vector2,
    velocity: rl.Vector2,
    bounds: rl.Vector2, 

    pub fn CollideAll(self: *Rigidbody, colliders: []const rl.Rectangle, size: usize) bool {
        var hit: u8 = 0;
        const end: usize = @min(size, colliders.len);
        for(0..end) |i| {
            const collider = colliders[i];
            if (collider.x < self.position.x + self.bounds.x and collider.x + collider.width > self.position.x
            and collider.y < self.position.y + self.bounds.y and collider.y + collider.height > self.position.y) {
                const self_cx: f32 = self.position.x + 0.5 * self.bounds.x;
                const self_cy: f32 = self.position.y + 0.5 * self.bounds.y;
                const other_cx: f32 = collider.x + 0.5 * collider.width;
                const other_cy: f32 = collider.y + 0.5 * collider.height;

                const dx: f32 = self_cx - other_cx;
                const dy: f32 = self_cy - other_cy;

                const px: f32 = (0.5 * self.bounds.x + 0.5 * collider.width) - @abs(dx);
                const py: f32 = (0.5 * self.bounds.y + 0.5 * collider.height) - @abs(dy);

                const slop: f32 = 0.001;
                if (px < py) {
                    const sx: f32 = if (dx < 0) -1 else 1;
                    self.position.x += (px + slop) * sx;
                    self.velocity.x = 0;
                } else {
                    const sy: f32 = if (dy < 0) -1 else 1;
                    self.position.y += (py + slop) * sy;
                    self.velocity.y = 0;
                }
                hit += 1;
                if (hit >= 4) 
                    return true;
            }
        }
        return false;
    }
};
