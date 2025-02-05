const std = @import("std");
const c = @import("c.zig");
const types = @import("types.zig");
const Glyph = @import("Glyph.zig");
const Outline = @import("Outline.zig");
const Bitmap = @import("Bitmap.zig");
const Error = @import("error.zig").Error;
const intToError = @import("error.zig").intToError;

const GlyphSlot = @This();

pub const SubGlyphInfo = struct {
    index: i32,
    flags: u32,
    arg1: i32,
    arg2: i32,
    transform: types.Matrix,
};

handle: c.FT_GlyphSlot,

pub fn init(handle: c.FT_GlyphSlot) GlyphSlot {
    return GlyphSlot{ .handle = handle };
}

pub fn render(self: GlyphSlot, render_mode: types.RenderMode) Error!void {
    return intToError(c.FT_Render_Glyph(self.handle, @enumToInt(render_mode)));
}

pub fn subGlyphInfo(self: GlyphSlot, sub_index: u32) Error!SubGlyphInfo {
    var info = std.mem.zeroes(SubGlyphInfo);
    try intToError(c.FT_Get_SubGlyph_Info(self.handle, sub_index, &info.index, &info.flags, &info.arg1, &info.arg2, @ptrCast(*c.FT_Matrix, &info.transform)));
    return info;
}

pub fn glyph(self: GlyphSlot) Error!Glyph {
    var out = std.mem.zeroes(c.FT_Glyph);
    try intToError(c.FT_Get_Glyph(self.handle, &out));
    return Glyph.init(out);
}

pub fn outline(self: GlyphSlot) ?Outline {
    return if (self.format() == .outline)
        Outline.init(&self.handle.*.outline)
    else
        null;
}

pub fn bitmap(self: GlyphSlot) Bitmap {
    return Bitmap.init(self.handle.*.bitmap);
}

pub fn bitmapLeft(self: GlyphSlot) i32 {
    return self.handle.*.bitmap_left;
}

pub fn bitmapTop(self: GlyphSlot) i32 {
    return self.handle.*.bitmap_top;
}

pub fn linearHoriAdvance(self: GlyphSlot) i64 {
    return self.handle.*.linearHoriAdvance;
}

pub fn linearVertAdvance(self: GlyphSlot) i64 {
    return self.handle.*.linearVertAdvance;
}

pub fn advance(self: GlyphSlot) types.Vector {
    return @ptrCast(*types.Vector, &self.handle.*.advance).*;
}

pub fn format(self: GlyphSlot) Glyph.GlyphFormat {
    return @intToEnum(Glyph.GlyphFormat, self.handle.*.format);
}

pub fn metrics(self: GlyphSlot) Glyph.GlyphMetrics {
    return self.handle.*.metrics;
}
