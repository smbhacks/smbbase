import xml.etree.ElementTree as ET
import struct
import os
import glob
import subprocess

levelFilesPath = "code/levels/tiled_engine/level_files"
asmFilesPath = "code/levels/tiled_engine/asm_files"
tiledAssetsPath = "code/levels/tiled_engine/tiled_assets"
generatedFolder = "generated"
segmentsFilePath = os.path.join(asmFilesPath, generatedFolder, "segments.asm")
lutsFilePath = os.path.join(asmFilesPath, generatedFolder, "luts.asm")
entityTsxPath = os.path.join(tiledAssetsPath, "tsx", "entity.tsx")
entityConstantsPath = os.path.join(asmFilesPath, generatedFolder, "entity_constants.asm")
BANKSIZE = 0x4000 # 16kb

bank = 0
curBankSize = 0
newBank = True

def includeInFile(file, size, filename, label, format = "incbin"):
    global curBankSize, newBank, bank

    curBankSize += size
    if curBankSize > BANKSIZE:
        curBankSize = 0
        bank += 1
        newBank = True
    if newBank:
        file.write(f'.segment "LEVEL{bank}" ;<MakeCfg: NewBank>\n')
        newBank = False
    file.write(f'{label}: .{format} "{asmFilesPath}/{generatedFolder}/{filename}"\n')

class Level:
    def __init__(self, name, width, height, areaType, timer, playerX, playerY):
        self.name = name
        self.width = width
        self.height = height
        self.areaType = areaType
        self.timer = timer
        self.playerX = playerX
        self.playerY = playerY

class Enemy:
    def __init__(self, x, y, id):
        self.x = x
        self.y = y
        self.id = id

levels = []
print("Converting Tiled files to Studsbase compatible files")

# load entities from entity.tsx
tree = ET.parse(entityTsxPath)    
root = tree.getroot()
entityTypes = []
entitySizeInBytes = []
with open(entityConstantsPath, "w") as entityConstantFile:
    for entity in root.findall("tile"):
        props = {prop.get("name"): prop.get("value") for prop in entity.find("properties").findall("property")}
        entityTypes.append(entity.get("type"))
        entitySizeInBytes.append(int(props["sizeInBytes"]))
        entityConstantFile.write(f'{entity.get("type")} = {entity.get("id")}\n')

# handle level data itself
with open(segmentsFilePath, "w") as segmentsFile:
    for tmxFile in glob.glob(os.path.join(levelFilesPath, "*.tmx")):
        tree = ET.parse(tmxFile)
        root = tree.getroot()
        filename = os.path.splitext(os.path.basename(tmxFile))[0]

        width = root.get("width")
        height = root.get("height")
        props = {prop.get("name"): prop.get("value") for prop in root.find("properties").findall("property")}
        
        labelBase = f'_{filename.replace("-", "_")}' 
        levels.append(Level(labelBase, width, height, props["areaType"], props["timer"], props["playerX"], props["playerY"]))

        mtiles_firstgid = enemies_firstgid = 0
        for tileset in root.findall("tileset"):
            if tileset.get("source") == "../tiled_assets/tsx/mtiles.tsx":
                mtiles_firstgid = int(tileset.get("firstgid"))
            if tileset.get("source") == "../tiled_assets/tsx/entity.tsx":
                enemies_firstgid = int(tileset.get("firstgid"))

        # handle entities
        # entity format:
        # %xxxxyyyy position within current page (16x16 grid)
        # %00001111 = first byte -> means page skip! (special row $0f)
        # %00001110 = first byte -> pipe pointer!
        # (rows $00-$0d):
            # %xxxyyyPI x and y: fine offset, P: page flag, I: msb of id
            # %iiiiiiii i: id 
        # (special row $0f, page skip)
            # %00pppppp page where the next enemy lies
        entitiesFilename = f"{filename}_entities.asm"
        with open(os.path.join(asmFilesPath, generatedFolder, entitiesFilename), "w") as entityFile:
            obj_group = root.find("objectgroup")
            size = 0
            entityData = []
            for obj in obj_group.findall("object"):
                entityData.append(Enemy(int(obj.get("x")), int(obj.get("y")), int(obj.get("gid")) - enemies_firstgid))
            entityData.sort(key=lambda e: e.x)
            prevXpage = 0
            for entity in entityData:
                entityType = entityTypes[entity.id]
                size += entitySizeInBytes[entity.id]
                xPage = entity.x // 256
                xPos = (entity.x % 256) // 16
                yPos = (entity.y - 16) // 16
                xFine = (entity.x % 16) // 2
                yFine = (entity.y % 16) // 2
                if prevXpage < xPage-1:
                    pageSkipData = f"$0f, {xPage}"
                    entityFile.write(f".byte {pageSkipData}\n")
                thisData = f"({xPos}<<4)+{yPos}, ({xFine}<<5)+({yFine}<<2)+(>{entityType})"
                if prevXpage == xPage-1:
                    # add next page flag
                    thisData += "+$02"
                thisData += f", <{entityType}"
                prevXpage = xPage
                entityFile.write(f".byte {thisData}\n")
            entityFile.write(f".byte $ff\n")
            includeInFile(segmentsFile, size, entitiesFilename, f"{labelBase}_entities", format="include")

        # handle foreground and background layers
        for layer in root.findall("layer"):
            name = layer.get("name")
            data = layer.find("data").text.strip()
            # split csv values and convert to integers
            values = [int(x) for x in data.replace("\n", "").split(",") if x.strip() != ""]
            orderedValues = []
            for column in range(0, int(width)):
                for row in range(0, int(height)):
                    value = values[column + row*int(width)]
                    if value != 0:
                        value -= mtiles_firstgid
                    orderedValues.append(value)
            tmpFile = f"{filename}_{name}.tmp"
            with open(tmpFile, "wb") as f:
                for v in orderedValues:
                    f.write(struct.pack("<B", v))
            finalFile = f"{filename}_{name}.lvl"
            finalFilePath = os.path.join(asmFilesPath, generatedFolder, finalFile)
            subprocess.run(["scripts/huffmunch.exe", "-B", tmpFile, finalFilePath])
            finalSize = os.path.getsize(finalFilePath)
            os.remove(tmpFile)
            includeInFile(segmentsFile, finalSize, finalFile, f"{labelBase}_{name}")

def writeToLutsFile(file, label, valueformat, levels, val, prefix = '', suffix = ''):
    file.write(f'{label}:\n')
    for level in levels:
        file.write(f"    .{valueformat} {prefix}{getattr(level, val)}{suffix}\n")

with open(lutsFilePath, "w") as lutsFile:
    #writeToLutsFile(lutsFile, "LevelWidthsLo", "lobytes", levels, "width")
    #writeToLutsFile(lutsFile, "LevelWidthsHi", "hibytes", levels, "width")
    writeToLutsFile(lutsFile, "LevelAreaTypes", "byte", levels, "areaType")
    writeToLutsFile(lutsFile, "LevelTimersLo", "lobytes", levels, "timer")
    writeToLutsFile(lutsFile, "LevelTimersHi", "hibytes", levels, "timer")
    writeToLutsFile(lutsFile, "LevelPlayerXs", "byte", levels, "playerX")
    writeToLutsFile(lutsFile, "LevelPlayerYs", "byte", levels, "playerY")
    writeToLutsFile(lutsFile, "LevelFgPtrsLo", "lobytes", levels, "name", suffix="_foreground")
    writeToLutsFile(lutsFile, "LevelFgPtrsHi", "hibytes", levels, "name", suffix="_foreground")
    writeToLutsFile(lutsFile, "LevelBgPtrsLo", "lobytes", levels, "name", suffix="_background")
    writeToLutsFile(lutsFile, "LevelBgPtrsHi", "hibytes", levels, "name", suffix="_background")
    writeToLutsFile(lutsFile, "LevelEntityPtrsLo", "lobytes", levels, "name", suffix="_entities")
    writeToLutsFile(lutsFile, "LevelEntityPtrsHi", "hibytes", levels, "name", suffix="_entities")
    writeToLutsFile(lutsFile, "LevelFgBanks", "byte", levels, "name", prefix="<.bank(", suffix="_foreground)")
    writeToLutsFile(lutsFile, "LevelBgBanks", "byte", levels, "name", prefix="<.bank(", suffix="_background)")
    writeToLutsFile(lutsFile, "LevelEntityBanks", "byte", levels, "name", prefix="<.bank(", suffix="_entities)")

