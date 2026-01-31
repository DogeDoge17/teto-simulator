const rl = @import("raylib");
const main = @import("main.zig");
const rand = @import("random.zig");
const physics = @import("physics.zig");
const std = @import("std");

const BlockTypes = enum {
    grass,
    dirt,
    stone,
    iron,
    coal,
    gold,
    redstone,
    diamond,
    poo,
    air,
};

const blockSource = [_]rl.Rectangle{
    // grass
    .{ .x = 3 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // dirt
    .{ .x = 2 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // stone
    .{ .x = 1 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // iron
    .{ .x = 1 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // coal
    .{ .x = 2 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // gold
    .{ .x = 0 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // redstone
    .{ .x = 3 * 16, .y = 3 * 16, .width = 16, .height = 16 },
    // diamond
    .{ .x = 2 * 16, .y = 3 * 16, .width = 16, .height = 16 },
    // poo
    .{ .x = 2 * 16, .y = 7 * 16, .width = 16, .height = 16 },
    // air
    .{ .x = 1 * 16, .y = 7 * 16, .width = 16, .height = 16 },
};

const FloorColumn =  struct {
    offset: f32,
    blocks: [floorHeight]BlockTypes,
    height: i8,
    colliders: [floorHeight + 1]rl.Rectangle
    
};

var lastHeight: u8 = 2;

var atlas: rl.Texture = undefined;

const floorColumns: usize = 23; // Number of columns in the floor
const floorHeight: usize = 7; // Number of blocks in each column
var floor: [floorColumns]FloorColumn = [_]FloorColumn{
.{ .offset = 0, .height = 0, .blocks = [_]BlockTypes{.air} ** floorHeight,  .colliders = [_]rl.Rectangle{ .{ .x = 0, .y = 0, .width = 0, .height = 0 } } ** (floorHeight + 1)} } ** floorColumns;

var backColumn: usize = 0;
var frontColumn: usize = floorColumns - 1; 

const fullBlock = 6 * 16;

pub fn TryAgainstFloor(rb: *physics.Rigidbody) bool {
    var hitCount: i8 = 0;
    for(floor) |columns|{
        if(rb.CollideAll(&columns.colliders, @as(usize, @intCast(columns.height)))) {
            hitCount += 1;
            if(hitCount >= 4){
                return true;
            }
        }
    }
    return hitCount > 0;
}

pub fn InitTerrain() !void {
    const image: rl.Image = try rl.loadImage("assets/terrain/terrain.png");
    defer rl.unloadImage(image);
    atlas = try rl.loadTextureFromImage(image);

    for (0..floor.len) |i| {
        floor[i].offset = @as(f32, @floatFromInt(i)) * fullBlock; 
        generateColumn(i);
    }

//    for (0..floor.len) |i| {
//        const column = floor[i];
//        for (0..column.blocks.len) |j| {
//           std.debug.print("{s}, ", .{ @tagName(column.blocks[j]) } );
 //       }
//        std.debug.print("\n", .{});
//    }
}

/// x is the target position of which the camera is focused on
pub fn UpdateScroll(x: f32) void {
    const l = floor[backColumn].offset + fullBlock;
    const r = x / main.renderScale - main.baseWidth / 2;
    if(l >= r)
        return;

    floor[backColumn].offset = floor[frontColumn].offset + fullBlock;
    frontColumn = backColumn;
    backColumn = @mod(backColumn + 1, floorColumns);

    generateColumn(frontColumn);

    for(floor) |column| {
        std.debug.print("{d}, ", .{column.offset});
    }
    std.debug.print("\n", .{});
}

fn genOre() BlockTypes {
    const randNum: i32 = rand.rand_range(0, 20);
    return switch (randNum) {
        0 => BlockTypes.iron,
        1 => BlockTypes.coal,
        2 => BlockTypes.gold,
        3 => BlockTypes.redstone,
        4 => BlockTypes.diamond,
        else => BlockTypes.stone,
    };
}

pub fn generateColumn(column: usize) void {
    const nextHeight: i16 = genNextHeight();

    if (column >= floor.len or nextHeight > floor[column].blocks.len) {
        std.debug.print("Invalid column {d} or height {d}\n", .{column, nextHeight});
        return;
    }

    floor[column].blocks = .{ .air } ** floorHeight;

    floor[column].blocks[@max(0, nextHeight - 2)] = BlockTypes.dirt;
    floor[column].blocks[@max(0, nextHeight - 1)] = BlockTypes.grass;

    for (0..@max(0, nextHeight - 2)) |i| 
        floor[column].blocks[i] = genOre();
    
    lastHeight = @as(u8, @intCast(nextHeight));
    floor[column].height = @as(i8, @intCast(nextHeight));

    const prevCol: usize = @as(usize, @intCast(@mod((@as(i64, @intCast(column)) - 1), floorColumns))); 
    _ = prevCol;
    //const colliderCount:i8 = @max(floor[column].height - floor[prevCol].height, 1);
    //for(0..colliderCount) |i| {
    //    _ = i;
    //}

    //for(0..@as(usize, @intCast(@max(floor[column].height - floor[prevCol].height,1)))) |i| {

    floor[column].colliders[0] = .{ 
             .x = floor[column].offset, 
             .y = main.baseHeight - @as(f32, @floatFromInt(lastHeight)) * fullBlock,
             // .y = main.baseHeight - @as(f32, @floatFromInt(@as(usize, @intCast(floor[column].height)) - i)) * fullBlock,
             .width = fullBlock,
             .height = @as(f32, @floatFromInt(lastHeight)) * fullBlock
    };

    // for(0..@as(usize, @intCast(lastHeight))) |i| {
    //     floor[column].colliders[i] = .{ 
    //         .x = floor[column].offset, 
    //         .y = main.baseHeight - @as(f32, @floatFromInt(i+1)) * fullBlock,
    //         // .y = main.baseHeight - @as(f32, @floatFromInt(@as(usize, @intCast(floor[column].height)) - i)) * fullBlock,
    //         .width = fullBlock,
    //         .height = fullBlock
    //     };
    // }
}

pub fn DrawFloor() void {
    for (0..floor.len) |jay| {
//        const j: usize = @mod(jay + zeroth, floor.len);
        const column = floor[jay];
        for (0..column.blocks.len) |i| {
            const blockType = column.blocks[i];
            if (blockType == BlockTypes.air) continue;

            const source: rl.Rectangle = blockSource[@intFromEnum(blockType)];
            const dest: rl.Rectangle = .{
                //.x = ((@as(f32, @floatFromInt(j  * 16))) * upScale * main.renderScale) - @as(f32, @floatFromInt(main.baseWidth)),
                .x = column.offset * main.renderScale, 
                .y = (main.baseHeight - @as(f32, @floatFromInt(((i + 1) * fullBlock))) ) * main.renderScale,
                .width = fullBlock * main.renderScale, 
                .height = fullBlock * main.renderScale,
            };

            rl.drawTexturePro(atlas, source, dest, .{.x = 0, .y = 0 }, 0.0, .white);
       }
    }
}

pub fn genNextHeight() u8 {

    var newHeight: i32 = 0;
    if(rand.rand_range(0, 2) != 0){
        newHeight = lastHeight + rand.rand_range(0, 2);
    } else {
        newHeight = lastHeight - rand.rand_range(0, 2);
    }

    if (newHeight < 1) newHeight = 1 else if (newHeight > floorHeight) newHeight = floorHeight - 2;

    return @intCast(@min(@as(u16, @intCast(newHeight)), floor[lastHeight].blocks.len));
    //return 6;
}
