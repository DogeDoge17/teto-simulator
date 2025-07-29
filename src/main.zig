const rl = @import("raylib");
const game = @import("game.zig");
const std = @import("std");

//pub const targetWidth = 2560;
//pub const targetHeight = 1440;
pub const targetWidth = 7680;
pub const targetHeight = 4320;
//pub const targetWidth = 1920;
//pub const targetHeight = 1080;
//pub const targetWidth = 1280;
//pub const targetHeight = 720;

pub const baseWidth = 1920;
pub const baseHeight = 1080;

pub var renderScale: f32 = @as(f32, @floatFromInt(targetWidth)) / @as(f32, @floatFromInt(baseWidth));

pub var gameDelta:f32 = 0.0;

pub fn main() anyerror!void {
    rl.setConfigFlags(.{ .window_resizable = true, .window_highdpi = false, .vsync_hint = true, .msaa_4x_hint = true });
    rl.initWindow(1280, 720, "TETO SIMULATOR 90 BILION");
    defer rl.closeWindow();
    rl.setTargetFPS(144);


    std.debug.print("high dpi scaling {d}, {d}: {}\n", .{rl.getWindowScaleDPI().x, rl.getWindowScaleDPI().y, rl.getWindowScaleDPI()});

    const target: rl.RenderTexture2D = try rl.loadRenderTexture(targetWidth, targetHeight);

    try game.Start();
    while (!rl.windowShouldClose()) {
        gameDelta = rl.getFrameTime();

        game.Update() catch |err| {
            std.debug.print("Error during game update: {}\n", .{err});
            break;
        };

        {
            rl.beginTextureMode(target);
            defer rl.endTextureMode();
            rl.clearBackground(rl.Color.init(100, 149, 237, 255));
            game.Draw();
        }
        {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(.black);

            const screenWidth: i32 = rl.getScreenWidth();
            const screenHeight: i32 = rl.getScreenHeight();
            const scale: f32 = @min(@as(f32, @floatFromInt(screenWidth)) / @as(f32, @floatFromInt(targetWidth)), @as(f32, @floatFromInt(screenHeight)) / @as(f32, @floatFromInt(targetHeight)));
            const scaledWidth: i32 = @as(i32, @intFromFloat(@as(f32, @floatFromInt(targetWidth)) * scale));
            const scaledHeight: i32 = @as(i32, @intFromFloat(@as(f32, @floatFromInt(targetHeight)) * scale));
            const offsetX: i32 = @divTrunc((screenWidth - scaledWidth), 2);
            const offsetY: i32 = @divTrunc((screenHeight - scaledHeight), 2);

            rl.drawTexturePro(target.texture, rl.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(targetWidth)), .height = @as(f32, @floatFromInt(-targetHeight)) }, rl.Rectangle{ .x = @as(f32, @floatFromInt(offsetX)), .y = @as(f32, @floatFromInt(offsetY)), .width = @as(f32, @floatFromInt(scaledWidth)), .height = @as(f32, @floatFromInt(scaledHeight)) }, rl.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, .white);
            rl.drawFPS(5, screenHeight - 20);
        }
    }
}
