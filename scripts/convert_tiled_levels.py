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

mtiles_tsx_path = "../tiled_assets/tsx/mtiles.tsx"
entity_tsx_path = "../tiled_assets/tsx/entity.tsx"
exit_tsx_path = "../tiled_assets/tsx/exit_types.tsx"

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

def getLabelBase(name):
    return f'_{name.replace("-", "_")}'

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
    def __init__(self, x, y, id, props = None):
        self.x = x
        self.y = y
        self.id = id
        self.props = props or {}

pipe_exit_cache = {}
def get_firstgid(root, tsx_path):
    for ts in root.findall("tileset"):
        if ts.get("source") == tsx_path:
            return int(ts.get("firstgid"))
    return None

def load_pipe_exits_from_tmx(tmx_path):
    tree = ET.parse(tmx_path)
    root = tree.getroot()

    exit_firstgid = get_firstgid(root, exit_tsx_path)
    if exit_firstgid is None:
        raise ValueError(f"Exit TSX not found in {tmx_path}")

    exits = {}

    obj_group = root.find("objectgroup")
    if obj_group is None:
        return exits

    for obj in obj_group.findall("object"):
        gid = obj.get("gid")
        if gid is None:
            continue

        gid = int(gid)
        exit_local_id = gid - exit_firstgid
        if exit_local_id < 0:
            continue  # not an exit tile

        props_node = obj.find("properties")
        if props_node is None:
            continue

        props = {}
        for prop in props_node.findall("property"):
            props[prop.get("name")] = prop.get("value")

        if "exitId" not in props:
            continue

        exits[props["exitId"]] = {
            "id": exit_local_id,
            "x": int(obj.get("x")),
            "y": int(obj.get("y"))
        }

    return exits

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
        
        labelBase = getLabelBase(filename)
        levels.append(Level(labelBase, width, height, props["areaType"], props["timer"], props["playerX"], props["playerY"]))

        mtiles_firstgid = enemies_firstgid = exit_types_firstgid = 0
                
        for tileset in root.findall("tileset"):
            if tileset.get("source") == mtiles_tsx_path:
                mtiles_firstgid = int(tileset.get("firstgid"))
            if tileset.get("source") == entity_tsx_path:
                enemies_firstgid = int(tileset.get("firstgid"))
            if tileset.get("source") == exit_tsx_path:
                exit_types_firstgid = int(tileset.get("firstgid"))

        # handle entities
        # entity format:
        # %xxxxyyyy position within current page (16x16 grid)
        # %00001111 = first byte -> means page skip! (special row $0f)
        # %00001110 = first byte -> pipe pointer! (special row $0e)
        # (rows $00-$0d):
            # %PxxxyyyI x and y: fine offset, P: page flag, I: msb of id
            # %iiiiiiii i: id 
        # (special row $0e)
            # %Piiiiiii i: area id, P: page flag
            # %ttpppppp t: exit type (0: regular, 1: exit from vert. pipe) p: page number 
            # %xxxxyyyy x: x and y coarse pos within page
        # (special row $0f, page skip)
            # %00pppppp page where the next enemy lies
        entitiesFilename = f"{filename}_entities.asm"
        with open(os.path.join(asmFilesPath, generatedFolder, entitiesFilename), "w") as entityFile:
            obj_group = root.find("objectgroup")
            size = 0
            entityData = []
            for obj in obj_group.findall("object"):
                if enemies_firstgid <= int(obj.get("gid")) < enemies_firstgid + len(entityTypes):
                    props = {}
                    props_node = obj.find("properties")
                    if props_node is not None:
                        for prop in props_node.findall("property"):
                            value = prop.get("value")
                            props[prop.get("name")] = value
                    entityData.append(Enemy(int(obj.get("x")), int(obj.get("y")), int(obj.get("gid")) - enemies_firstgid, props))
            entityData.sort(key=lambda e: e.x)
            prevXpage = 0
            for entity in entityData:
                entityType = entityTypes[entity.id]
                size += entitySizeInBytes[entity.id]
                xPage = entity.x // 256
                xPos = (entity.x % 256) // 16
                yPos = entity.y // 16
                xFine = (entity.x % 16) // 2
                yFine = (entity.y % 16) // 2

                # handle page skip
                if prevXpage < xPage-1:
                    pageSkipData = f"$0f, {xPage}"
                    entityFile.write(f".byte {pageSkipData}\n")
                    size += 2

                # the actual entity data
                if entityType == "EN_PIPE_POINTER":
                    exitId = entity.props.get("exitId", 0)
                    targetArea = entity.props.get("targetArea")               
                    if exitId is None or targetArea is None:
                        raise ValueError("PIPE POINTER missing exitId or targetArea")
                    targetTmxPath = os.path.join(levelFilesPath, f"{targetArea}.tmx")
                    if targetArea not in pipe_exit_cache:
                        pipe_exit_cache[targetArea] = load_pipe_exits_from_tmx(targetTmxPath)
                    exits = pipe_exit_cache[targetArea]
                    if exitId not in exits:
                        raise ValueError(f"PIPE EXIT exitId={exitId} not found in {targetArea}.tmx")
                    target = exits[exitId]
                    txId = target["id"]
                    txPage = target["x"] // 256
                    txPos  = (target["x"] % 256) // 16
                    tyPos  = target["y"] // 16
                    thisData = f"({xPos}<<4)+$0e, {getLabelBase(targetArea)}_id"
                    if prevXpage == xPage-1:
                        thisData += "+$80"
                    thisData += f", ({txId}<<6)+{txPage}, ({txPos}<<4)+{tyPos}"
                else:
                    thisData = f"({xPos}<<4)+{yPos}, ({xFine}<<4)+({yFine}<<1)+(>{entityType})"
                    if prevXpage == xPage-1:
                        thisData += "+$80"
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
    # ID enum
    i = 0
    for level in levels:
        lutsFile.write(f"{getattr(level, 'name')}_id = {i}\n")
        i += 1