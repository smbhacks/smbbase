import xml.etree.ElementTree as ET
import struct
import os
import glob
import subprocess

levelFilesPath = "code/levels/tiled_engine/level_files"
asmFilesPath = "code/levels/tiled_engine/asm_files"
generatedFolder = "generated"
segmentsFilePath = os.path.join(asmFilesPath, generatedFolder, "segments.asm")
lutsFilePath = os.path.join(asmFilesPath, generatedFolder, "luts.asm")
BANKSIZE = 0x4000 # 16kb

bank = 0
curBankSize = 0
newBank = True

class Level:
    def __init__(self, name, width, height, areaType, timer):
        self.name = name
        self.width = width
        self.height = height
        self.areaType = areaType
        self.timer = timer

levels = []
print("Converting Tiled files to Studsbase compatible files")
with open(segmentsFilePath, "w") as segmentsFile:
    for tmxFile in glob.glob(os.path.join(levelFilesPath, "*.tmx")):
        tree = ET.parse(tmxFile)
        root = tree.getroot()
        filename = os.path.splitext(os.path.basename(tmxFile))[0]

        width = root.get("width")
        height = root.get("height")
        props = {prop.get("name"): prop.get("value") for prop in root.find("properties").findall("property")}
        
        labelBase = f'_{filename.replace("-", "_")}' 
        levels.append(Level(labelBase, width, height, props["areaType"], props["timer"]))

        for layer in root.findall("layer"):
            name = layer.get("name")

            data = layer.find("data").text.strip()

            # split csv values and convert to integers
            values = [int(x) for x in data.replace("\n", "").split(",") if x.strip() != ""]

            tmpFile = f"{filename}_{name}.tmp"
            with open(tmpFile, "wb") as f:
                for v in values:
                    f.write(struct.pack("<B", v))

            finalFile = f"{filename}_{name}.lvl"
            finalFilePath = os.path.join(asmFilesPath, generatedFolder, finalFile)
            subprocess.run(["scripts/huffmunch.exe", "-B", tmpFile, finalFilePath])
            finalSize = os.path.getsize(finalFilePath)
            os.remove(tmpFile)

            curBankSize += finalSize
            if curBankSize > BANKSIZE:
                curBankSize = 0
                bank += 1
                newBank = True

            if newBank:
                segmentsFile.write(f'.segment "LEVEL{bank}" ;<MakeCfg: NewBank>\n')
                newBank = False

            segmentsFile.write(f'{labelBase}_{name}: .incbin "{asmFilesPath}/{generatedFolder}/{finalFile}"\n')

def writeToLutsFile(file, label, valueformat, levels, val, extra = ''):
    file.write(f'{label}:\n')
    for level in levels:
        file.write(f"    .{valueformat} {getattr(level, val)}{extra}\n")

with open(lutsFilePath, "w") as lutsFile:
    writeToLutsFile(lutsFile, "LevelWidthsLo", "lobytes", levels, "width")
    writeToLutsFile(lutsFile, "LevelWidthsHi", "hibytes", levels, "width")
    writeToLutsFile(lutsFile, "LevelAreaTypes", "byte", levels, "areaType")
    writeToLutsFile(lutsFile, "LevelTimersLo", "lobytes", levels, "timer")
    writeToLutsFile(lutsFile, "LevelTimersHi", "hibytes", levels, "timer")
    writeToLutsFile(lutsFile, "LevelFgPtrsLo", "lobytes", levels, "name", "_foreground")
    writeToLutsFile(lutsFile, "LevelFgPtrsHi", "hibytes", levels, "name", "_foreground")
    writeToLutsFile(lutsFile, "LevelBgPtrsLo", "lobytes", levels, "name", "_background")
    writeToLutsFile(lutsFile, "LevelBgPtrsHi", "hibytes", levels, "name", "_background")
