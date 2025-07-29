const std = @import("std");
const rl = @import("raylib");
const main = @import("main.zig");

pub const Teto = struct {
    height: f32 = 305.0 * 3,
    width: f32 = 120.0 * 3,
    texture: ?rl.Texture = null,
    position: rl.Vector2 = rl.Vector2{ .x = 0.0, .y = 0.0 },
    velocity: rl.Vector2 = rl.Vector2{ .x = 0.0, .y = 0.0 },
    direction: i8 = 1,

    pub fn LoadTexture() !rl.Texture {
        const image: rl.Image = try rl.loadImage("assets/teto/normal.png");
        defer rl.unloadImage(image);
        return try rl.loadTextureFromImage(image);
    }

    pub fn Init() !Teto {
        var teto = Teto{};
        teto.texture = try LoadTexture();
        return teto;
    }

   fn Move(self: *Teto) void {

       const drag: f32 = 200.0;
       const gravity: f32 = 800.0;
       const acceleration = 600.0;
       const jumpForce: f32 = -600.0;
       const maxSpeed: f32 = 350.0;

       self.velocity.x += (if (self.velocity.x > @as(f32, 0.0)) @as(f32, -1.0) else @as(f32, 1.0)) * main.gameDelta * drag;
       self.velocity.y += gravity * main.gameDelta;

       const delta = main.gameDelta * acceleration;

       if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) {
           self.velocity.x += delta;
           self.direction = -1;
       } else if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) {
           self.velocity.x -= delta;
           self.direction = 1;
       }

       if (rl.isKeyPressed(.space)) {
           self.velocity.y = jumpForce;
       } else if (rl.isKeyDown(.down) or rl.isKeyDown(.s)) {
           self.velocity.y += delta * 1.2;
       }

       if (@abs(self.velocity.x) > maxSpeed) {
           self.velocity.x = if (self.velocity.x > 0) maxSpeed else -maxSpeed;
       }

       self.position.x += self.velocity.x * main.gameDelta;
       self.position.y += self.velocity.y * main.gameDelta;

       if (self.position.y > main.baseHeight - self.height) {
           self.position.y = main.baseHeight - self.height;
           self.velocity.y = 0.0;
       } else if (self.position.y < 0.0) {
           self.position.y = 0.0;
           self.velocity.y = 0.0;
       }
   }

    pub fn Update(self: *Teto) void {
        self.Move();
    }

    pub fn Draw(self: *Teto) void {
        if (self.texture) |texture| {
            //std.debug.print("position: ({d}, {d}) dir: {}\n", .{ self.position.x, self.position.y, self.direction });
            rl.drawTexturePro(
                texture,
                rl.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(self.direction * texture.width)), .height = @as(f32, @floatFromInt(texture.height)) },
                rl.Rectangle{ .x = self.position.x * main.renderScale, .y = self.position.y * main.renderScale , .width = self.width * main.renderScale, .height = self.height * main.renderScale },
                rl.Vector2{ .x = 0.0, .y = 0.0 },
                0.0,
                .white);
        } else {
            std.debug.print("Teto texture not loaded.\n", .{});
        }
    }
};
