import sys, numpy as np
from PIL import Image, ImageDraw
src, outdir = sys.argv[1], sys.argv[2]
rng = np.random.default_rng(7)
Oi = Image.open(src).convert("RGBA"); O = np.array(Oi).astype(np.float32)
H, NW = 250, 3360
L_END, C0, C1 = 240, 244, 1240
CX = 1182
IVY0, ROWCUT = 1170, 141                # banner/ivy of the right pillar (above wall) travels with the right block
cw = C1 - C0
R0X = NW - (1680 - 1257)
SLOT_Y0, SLOT_Y1 = 136, 236
W = O[:, 800:1040]
def mirror_tile(s, width, off=0):
    p = np.concatenate([s, s[:, ::-1]], axis=1); return p[:, (np.arange(width)+off) % p.shape[1]]
strip = O[:, 1045:1055]; mean = strip.mean(axis=1)
sm = np.stack([mean[max(0, y-4):y+5].mean(axis=0) for y in range(H)])
def filler(width, off):
    f = mirror_tile(W, width, off).copy()
    for y in range(SLOT_Y0, SLOT_Y1):
        j = np.repeat(rng.integers(0, strip.shape[1], (width+1)//2), 2)[:width]
        f[y] = sm[y] + (strip[y, j] - mean[y]); f[y, :, 3] = 255
    return f
out = np.zeros((H, NW, 4), np.float32)
out[:, :L_END] = O[:, :L_END]
out[:, L_END:CX] = filler(CX - L_END, 0)
out[:, CX:CX+cw] = O[:, C0:C1]
cend = CX + cw
fx0 = cend - (C1 - IVY0)                            # filler also covers the top rows where ivy used to be
F = filler(R0X - fx0, 120)
out[:ROWCUT, fx0:R0X] = F[:ROWCUT]
out[ROWCUT:, cend:R0X] = F[ROWCUT:, cend-fx0:]
out[:, R0X:] = O[:, 1257:]
img = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA")
# ivy/banner patch (original columns IVY0..C1, rows above ROWCUT) re-attached to the pillar, feathered on its left edge
patch = np.array(Oi.crop((IVY0, 0, 1257, ROWCUT))).astype(np.float32)
ramp = np.minimum(1, np.arange(patch.shape[1]) / 8.0); patch[:, :, 3] *= ramp[None, :]
img.alpha_composite(Image.fromarray(patch.astype(np.uint8), "RGBA"), (R0X - (1257 - IVY0), 0))
img.save(f"{outdir}/mainpanel_bg_3360_full.png")
print("C", CX, cend, "right filler", cend, R0X, "R at", R0X)
