#!/usr/bin/env python3
"""
kb_texture_upscale.py - конвейер апскейла текстур King's Bounty (Legend) нейросетью.

Что делает для каждой выбранной текстуры:
  1. достаёт .dds из textures.kfs (zip);          2. texconv: DDS -> PNG;
  3. нейросеть увеличивает RGB (альфа - отдельно, Lanczos);
  4. texconv: PNG -> DDS в том же формате (DXT1/DXT3/DXT5) с полной цепочкой mip-уровней;
  5. кладёт результат в <work>/mod/ (плоская папка), игра НЕ меняется.

Нужно поставить (Windows):
  - Python 3 + Pillow:                 pip install pillow
  - texconv.exe (Microsoft DirectXTex): https://github.com/microsoft/DirectXTex/releases
  - апскейлер с командной строкой, по умолчанию realesrgan-ncnn-vulkan.exe (Real-ESRGAN, любая видеокарта с Vulkan)
    https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan/releases ; другая программа - через --upscaler-cmd

Примеры:
  # 0) проверка, подхватывает ли игра подменённые текстуры (красим одну в красный, без нейросети)
  python tools/kb_texture_upscale.py run --game "D:\\Games\\KB\\KB The Legend EE" --work kbtex --texconv C:\\tools\\texconv.exe --probe castle_wall_diff.dds
  # 1) пробный апскейл 20 текстур (x2)
  python tools/kb_texture_upscale.py run --game "..." --work kbtex --texconv ... --upscaler C:\\tools\\realesrgan\\realesrgan-ncnn-vulkan.exe --scale 2 --limit 20
  # 2) только здания и замки, по шаблону имени
  python tools/kb_texture_upscale.py run ... --include "^(castle|building|window|gate)"
  # 3) показать команды и ничего не запускать
  python tools/kb_texture_upscale.py run ... --dry-run

По умолчанию берутся diffuse/other текстуры со стороной <= 1024; пропускаются спецэффекты, небо, воду, кубы,
spec/mask/bump. Уже сделанные файлы пропускаются (можно прерывать и продолжать).
Шаблон для своего апскейлера: --upscaler-cmd "mytool.exe -i {in} -o {out} -s {scale}".
"""
import argparse, csv, os, re, shlex, subprocess, sys, zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kb_texture_inventory import classify, parse_dds   # noqa: E402

BC = {"DXT1": "BC1_UNORM", "DXT3": "BC2_UNORM", "DXT5": "BC3_UNORM"}
DEFAULT_EXCLUDE = r"^(fx|fxm)|sky|water|cube|checkboard|^dxt"

def select(game, include, exclude, max_side, limit):
    kfs = os.path.join(game, "data", "textures.kfs")
    if not os.path.isfile(kfs):
        sys.exit(f"Не найден {kfs}")
    z = zipfile.ZipFile(kfs); out = []
    inc = re.compile(include, re.I) if include else None
    exc = re.compile(exclude, re.I) if exclude else None
    for zi in z.infolist():
        n = os.path.basename(zi.filename)
        if zi.is_dir() or not n.lower().endswith(".dds"):
            continue
        if classify("data/textures.kfs!/" + n) not in ("diffuse", "other"):
            continue
        if exc and exc.search(n) or (inc and not inc.search(n)):
            continue
        with z.open(zi) as f:
            info = parse_dds(f.read(200))
        if not info or max(info["w"], info["h"]) > max_side or info["fmt"] not in BC:
            continue
        out.append((zi, n, info))
        if limit and len(out) >= limit:
            break
    return z, out

def run(cmd, dry):
    print("  >", " ".join(shlex.quote(c) if " " in c else c for c in cmd))
    if dry:
        return
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(f"код {r.returncode}: {r.stdout[-300:]} {r.stderr[-300:]}")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["run"])
    ap.add_argument("--game", required=True, help="папка игры (где data\\textures.kfs)")
    ap.add_argument("--work", default="kbtex")
    ap.add_argument("--texconv", required=True)
    ap.add_argument("--upscaler", default="realesrgan-ncnn-vulkan.exe")
    ap.add_argument("--upscaler-cmd", default="", help='шаблон: "tool -i {in} -o {out} -s {scale}"')
    ap.add_argument("--model", default="realesrgan-x4plus")
    ap.add_argument("--scale", type=int, default=2, choices=[2, 3, 4])
    ap.add_argument("--include", default=""); ap.add_argument("--exclude", default=DEFAULT_EXCLUDE)
    ap.add_argument("--max-side", type=int, default=1024)
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--probe", default="", help="имя dds: покрасить в красный без нейросети (проверка подмены)")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    from PIL import Image

    d = {k: os.path.join(a.work, k) for k in ("src", "png", "rgb", "up", "hd", "mod")}
    for p in d.values():
        os.makedirs(p, exist_ok=True)
    if a.probe:
        a.include = "^" + re.escape(a.probe) + "$"; a.exclude = ""; a.max_side = 99999; a.limit = 1
    z, items = select(os.path.abspath(a.game), a.include, a.exclude, a.max_side, a.limit)
    print(f"К обработке: {len(items)} текстур, режим: {'ПРОБА (красим)' if a.probe else f'x{a.scale}'}")
    log = open(os.path.join(a.work, "log.csv"), "a", newline="", encoding="utf-8"); lw = csv.writer(log)
    ok = fail = skip = 0
    for zi, n, info in items:
        stem = os.path.splitext(n)[0]
        outp = os.path.join(d["mod"], n)
        if os.path.exists(outp):
            skip += 1; continue
        print(f"{n}  {info['w']}x{info['h']} {info['fmt']}")
        try:
            srcp = os.path.join(d["src"], n)
            if not a.dry_run:
                open(srcp, "wb").write(z.read(zi))
            run([a.texconv, "-ft", "png", "-f", "R8G8B8A8_UNORM", "-y", "-o", d["png"], srcp], a.dry_run)
            pngp = os.path.join(d["png"], stem + ".png"); hdp = os.path.join(d["hd"], stem + ".png")
            if a.probe:
                if not a.dry_run:
                    im = Image.open(pngp).convert("RGBA"); r, g, b, al = im.split()
                    Image.merge("RGBA", (r.point(lambda v: min(255, v + 120)), g.point(lambda v: v // 3), b.point(lambda v: v // 3), al)).save(hdp)
            else:
                rgbp = os.path.join(d["rgb"], stem + ".png"); upp = os.path.join(d["up"], stem + ".png")
                if not a.dry_run:
                    im = Image.open(pngp).convert("RGBA"); im.convert("RGB").save(rgbp)
                if a.upscaler_cmd:
                    cmd = shlex.split(a.upscaler_cmd.format(**{"in": rgbp, "out": upp, "scale": a.scale}))
                else:
                    cmd = [a.upscaler, "-i", rgbp, "-o", upp, "-n", a.model, "-s", str(a.scale), "-f", "png"]
                run(cmd, a.dry_run)
                if not a.dry_run:
                    up = Image.open(upp).convert("RGB")
                    alpha = im.getchannel("A").resize(up.size, Image.LANCZOS)
                    res = up.convert("RGBA"); res.putalpha(alpha) if info["alpha"] else None
                    res.save(hdp)
            run([a.texconv, "-f", BC[info["fmt"]], "-m", "0", "-y", "-o", d["mod"], hdp], a.dry_run)
            ok += 1; lw.writerow([n, info["w"], info["h"], info["fmt"], "ok"])
        except Exception as e:
            fail += 1; print("  ОШИБКА:", e); lw.writerow([n, info["w"], info["h"], info["fmt"], "fail: " + str(e)[:200]])
    print(f"Готово: {ok} ок, {skip} пропущено (уже есть), {fail} ошибок. Результат: {d['mod']}")
    print("Дальше: скопируйте папку mod в data\\mods\\<имя> тестовой КОПИИ игры (см. docs/TEXTURES_UPSCALE.md).")

if __name__ == "__main__":
    main()
