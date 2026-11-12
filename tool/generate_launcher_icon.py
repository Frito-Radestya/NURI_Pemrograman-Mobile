"""Generate NURI launcher icons and splash mark from the Material spa glyph."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT = Path(r"C:\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf")
OUT = ROOT / "android" / "app" / "src" / "main" / "res"
TEAL_TOP = (13, 112, 96)
TEAL_BOTTOM = (5, 74, 64)
PEACH = (247, 184, 154)
CREAM = (251, 246, 238)


def gradient(size: int) -> Image.Image:
    image = Image.new("RGB", (size, size), TEAL_TOP)
    draw = ImageDraw.Draw(image)
    for y in range(size):
        t = y / max(size - 1, 1)
        color = tuple(round(a + (b - a) * t) for a, b in zip(TEAL_TOP, TEAL_BOTTOM))
        draw.line([(0, y), (size, y)], fill=color)
    return image


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def render_mark(size: int, radius_ratio: float = 0.225, transparent_bg: bool = False) -> Image.Image:
    base = gradient(size)
    mask = rounded_mask(size, round(size * radius_ratio))
    icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    icon.paste(base, (0, 0), mask)
    draw = ImageDraw.Draw(icon)

    font = ImageFont.truetype(str(FONT), round(size * 0.58))
    glyph = "\uf86c"  # local_florist_rounded
    box = draw.textbbox((0, 0), glyph, font=font)
    x = (size - (box[2] - box[0])) / 2 - box[0]
    y = (size - (box[3] - box[1])) / 2 - box[1] - size * 0.012
    draw.text((x, y), glyph, font=font, fill=(255, 255, 255, 255))

    dot_r = size * 0.038
    cx, cy = size * 0.735, size * 0.265
    draw.ellipse((cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r), fill=PEACH + (255,))

    if transparent_bg:
        return icon
    return icon


def main() -> None:
    master = render_mark(1024)
    for density, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        target = OUT / f"mipmap-{density}" / "ic_launcher.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        master.resize((px, px), Image.LANCZOS).save(target, optimize=True)

    # Splash mark: transparent canvas with a smaller rounded teal tile, so the
    # cream Android launch background reads as part of the NURI palette.
    splash = Image.new("RGBA", (320, 320), (0, 0, 0, 0))
    mark = render_mark(220)
    splash.alpha_composite(mark, (50, 50))
    splash_dir = OUT / "drawable-nodpi"
    splash_dir.mkdir(parents=True, exist_ok=True)
    splash.save(splash_dir / "splash_logo.png", optimize=True)

    preview = ROOT / "build" / "nuri_icon_preview.png"
    preview.parent.mkdir(parents=True, exist_ok=True)
    master.resize((512, 512), Image.LANCZOS).save(preview)
    print(f"Wrote launcher icons and {preview}")


if __name__ == "__main__":
    main()
