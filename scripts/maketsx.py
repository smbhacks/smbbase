import sys
from pathlib import Path
from PIL import Image as PILImage

class Metatile:
    def __init__(self):
        self.tiles = [0, 0, 0, 0]
        self.pal = 0
        self.name = ""

class ImageWrapper:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.data = PILImage.new("RGBA", (width, height), (0, 0, 0, 0))
        self.m_X = 0
        self.m_Y = 0

        # NES palette
        self.nes_palette = [
            0x62,0x62,0x62,0x00,0x2C,0x7C,0x11,0x15,0x9C,0x36,0x03,0x9C,
            0x55,0x00,0x7C,0x67,0x00,0x44,0x67,0x07,0x03,0x55,0x1C,0x00,
            0x36,0x32,0x00,0x11,0x44,0x00,0x00,0x4E,0x00,0x00,0x4C,0x03,
            0x00,0x40,0x44,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            0xAB,0xAB,0xAB,0x12,0x60,0xCE,0x3D,0x42,0xFA,0x6E,0x29,0xFA,
            0x99,0x1C,0xCE,0xB1,0x1E,0x81,0xB1,0x2F,0x29,0x99,0x4A,0x00,
            0x6E,0x69,0x00,0x3D,0x82,0x00,0x12,0x8F,0x00,0x00,0x8D,0x29,
            0x00,0x7C,0x81,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
            0xFF,0xFF,0xFF,0x60,0xB2,0xFF,0x8D,0x92,0xFF,0xC0,0x78,0xFF,
            0xEC,0x6A,0xFF,0xFF,0x6D,0xD4,0xFF,0x7F,0x79,0xEC,0x9B,0x2A,
            0xC0,0xBA,0x00,0x8D,0xD4,0x00,0x60,0xE2,0x2A,0x47,0xE0,0x79,
            0x47,0xCE,0xD4,0x4E,0x4E,0x4E,0x00,0x00,0x00,0x00,0x00,0x00,
            0xFF,0xFF,0xFF,0xBF,0xE0,0xFF,0xD1,0xD3,0xFF,0xE6,0xC9,0xFF,
            0xF7,0xC3,0xFF,0xFF,0xC4,0xEE,0xFF,0xCB,0xC9,0xF7,0xD7,0xA9,
            0xE6,0xE3,0x97,0xD1,0xEE,0x97,0xBF,0xF3,0xA9,0xB5,0xF2,0xC9,
            0xB5,0xEB,0xEE,0xB8,0xB8,0xB8,0x00,0x00,0x00,0x00,0x00,0x00
        ]

    def write(self, nes_pal_value):
        if nes_pal_value == -1:
            color = (30, 30, 30, 128)
        elif nes_pal_value == -2:
            color = (0, 0, 0, 0)
        else:
            pal = 3 * ((nes_pal_value & 0x0F) + 16 * (nes_pal_value >> 4))
            color = (
                self.nes_palette[pal],
                self.nes_palette[pal+1],
                self.nes_palette[pal+2],
                255
            )
        self.data.putpixel((self.m_X, self.m_Y), color)

    def moveX(self, amount):
        self.m_X += amount
        while self.m_X >= self.width: self.m_X -= self.width
        while self.m_X < 0: self.m_X += self.width

    def moveY(self, amount):
        self.m_Y += amount

def format_arg(s):
    if s.startswith("file:///"):
        s = s[8:]
    return s

def main():
    if len(sys.argv) < 4:
        print("Usage: [CHR file (min.4kb)] [Palette file (32 bytes)] [Metatiles definition assembly file]")
        return

    chr_path = format_arg(sys.argv[1])
    pal_path = format_arg(sys.argv[2])
    metatiles_path = format_arg(sys.argv[3])

    # Read CHR file
    chr_data = Path(chr_path).read_bytes()
    if len(chr_data) < 0x1000:
        print("error: CHR below 4 kB")
        return
    chr_data = chr_data[:0x1000]

    # Read palette file
    palette = Path(pal_path).read_bytes()
    if len(palette) < 0x20:
        print("error: palette file is not 32 bytes")
        return
    palette = palette[:0x20]

    # Read metatiles
    metatiles_text = Path(metatiles_path).read_text()
    metatiles = []
    pos = metatiles_text.find('DefineMTile "')
    while pos != -1 and len(metatiles) < 256:
        start_name = metatiles_text.find('"', pos) + 1
        end_name = metatiles_text.find('"', start_name)
        mt = Metatile()
        mt.name = metatiles_text[start_name:end_name]
        for i in range(4):
            pos = metatiles_text.find("$", pos + 1)
            mt.tiles[i] = int(metatiles_text[pos+1:pos+3], 16)
        pal_pos = metatiles_text.find("pal", pos + 1)
        mt.pal = int(metatiles_text[pal_pos + 3])
        metatiles.append(mt)
        pos = metatiles_text.find('DefineMTile "', pos + 1)

    # Generate image
    img_width = 256
    img_height = 256
    image = ImageWrapper(img_width, img_height)

    for metatile_index, mt in enumerate(metatiles):
        for t, tile_index in enumerate(mt.tiles):
            tile_offset = tile_index * 16
            for y in range(8):
                for x in range(8):
                    tile_value = (chr_data[tile_offset + y] >> (7 - x)) & 1
                    tile_value += ((chr_data[tile_offset + y + 8] >> (7 - x)) << 1) & 0b10
                    if tile_value == 0:
                        if metatile_index == 0:
                            image.write(-2)
                        else:
                            image.write(-1)
                    else:
                        image.write(palette[4 * mt.pal + tile_value])
                    image.moveX(1)
                image.moveX(-8)
                image.moveY(1)
            if t == 1 or t == 3:
                image.moveX(8)
                image.moveY(-16)
        if (metatile_index & 0x0F) == 0x0F:
            image.moveY(16)

    Path("generated/tsx").mkdir(parents=True, exist_ok=True)
    image.data.save("generated/tsx/temp.png", "PNG")

    # Generate TSX file
    tsx_file = Path("generated/tsx/temp.tsx")
    tsx_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
    tsx_content += '<tileset version="1.10" tiledversion="1.10.2" name="tiled" tilewidth="16" tileheight="16" tilecount="256" columns="16">\n'
    tsx_content += ' <image source="temp.png" width="256" height="256"/>'
    for i, mt in enumerate(metatiles):
        tsx_content += f'\n <tile id="{i}" type="{mt.name}"/>'
    tsx_content += "\n</tileset>"
    tsx_file.write_text(tsx_content)

if __name__ == "__main__":
    main()
