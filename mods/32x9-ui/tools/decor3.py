import sys, numpy as np
from PIL import Image, ImageDraw
full_path, orig_path, outdir = sys.argv[1:4]
rng = np.random.default_rng(11)
full = Image.open(full_path).convert("RGBA"); orig = Image.open(orig_path).convert("RGBA")
H, S = 250, 4
FILL = [(240, 1182), (2178, 2937)]
IVY = [(240, 1182), (2178, 2840)]
GOLD_D, GOLD_M, GOLD_L, OUT = (120, 84, 30), (207, 170, 70), (249, 226, 130), (14, 7, 0)
layer = Image.new("RGBA", (full.width*S, H*S), (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
CY = 187
def diamond(cx, w=5, h=8):
    d.polygon([(cx*S,(CY-h-1)*S),((cx+w+1)*S,CY*S),(cx*S,(CY+h+1)*S),((cx-w-1)*S,CY*S)], fill=OUT)
    d.polygon([(cx*S,(CY-h)*S),((cx+w)*S,CY*S),(cx*S,(CY+h)*S),((cx-w)*S,CY*S)], fill=GOLD_M)
    d.polygon([(cx*S,(CY-h+3)*S),((cx+w-2.5)*S,CY*S),(cx*S,(CY+h-3)*S),((cx-w+2.5)*S,CY*S)], fill=GOLD_L)
for a, b in FILL:
    x0, x1 = a+40, b-40
    for th, col in ((4, OUT), (2, GOLD_D), (1, GOLD_M)):
        d.rectangle([x0*S, (CY-th/2)*S, x1*S, (CY+th/2)*S], fill=col)
    n = max(2, round((x1-x0)/150)); step = (x1-x0)/n
    for i in range(n+1): diamond(x0+step*i)
    for i in range(n):
        cx = x0+step*(i+0.5); d.ellipse([(cx-2.5)*S,(CY-2.5)*S,(cx+2.5)*S,(CY+2.5)*S], fill=GOLD_L)
layer = layer.resize((full.width, H), Image.LANCZOS)
canvas = full.copy(); band = Image.new("RGBA", canvas.size, (0,0,0,0)); band.paste(layer.crop((0,142,full.width,232)), (0,142)); canvas.alpha_composite(band)
patch = np.array(orig.crop((600, 86, 742, 134))).astype(np.float32); pw = patch.shape[1]
patch[:, :, 3] *= np.minimum(1, np.minimum(np.arange(pw), np.arange(pw)[::-1])/12.0)[None, :]
for a, b in IVY:
    n = max(2, round((b-a)/260)); step = (b-a-2*pw)/max(1, n-1)
    for i in range(n):
        x = a + pw*0.5 + step*i + rng.integers(-25, 25)
        p = patch[:, ::-1] if i % 2 else patch
        canvas.alpha_composite(Image.fromarray(np.clip(p,0,255).astype(np.uint8),"RGBA"), (int(max(a+6, min(b-pw-6, x))), 86))
canvas.save(f"{outdir}/mainpanel_bg_3360_full.png")
canvas.crop((0,0,1682,H)).save(f"{outdir}/mainpanel_bg_3360_a.png"); canvas.crop((1680,0,3360,H)).save(f"{outdir}/mainpanel_bg_3360_b.png")
bg = Image.new("RGBA", canvas.size, (255,0,255,255)); bg.alpha_composite(canvas)
bg.convert("RGB").resize((1680,125)).save("work/dec3_full.png"); bg.convert("RGB").crop((1950,60,3360,250)).save("work/dec3_right.png")
