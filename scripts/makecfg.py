import sys

args = ["code/levels/tiled_engine/level_files/generated/segments.asm"]
templateCfgPath = "scripts/template.cfg"
outputCfgPath = "generatedCfg.cfg"

segmentsToAssign = []
for file in args:
    with open(file, "r", encoding="utf-8") as f:
        content = f.read()
        p = 0
        while True:
            p = content.find("<MakeCfg: NewBank>", p+1)
            if p == -1:
                break
            r1 = r2 = p
            r1 = content.rfind('"', 0, p)
            r2 = content.rfind('"', 0, r1)+1
            segmentsToAssign.append(content[r2:r1])

freeSpace = []
with open(templateCfgPath, "r", encoding="utf-8") as f:
    templateContent = f.read()
    p = 0
    while True:
        p = templateContent.find("# MakeCfg: free", p+1)
        if p == -1:
            break
        e = templateContent.rfind(":", 0, p)
        s = templateContent.rfind(" ", 0, e)+1
        freeSpace.append(templateContent[s:e])

print("Segments to assign: ", ", ".join(segmentsToAssign))
print("Free space: ", ", ".join(freeSpace))
if len(segmentsToAssign) > len(freeSpace):
    print("Not enough free banks!")
else:
    with open(outputCfgPath, "w", encoding="utf-8") as f:
        makeCfgData = ""
        index = 0
        for segment in segmentsToAssign:
            makeCfgData += "    " + segment + ":    load = " + freeSpace[index] + ",    type = ro;\n"
            index += 1
        f.write(templateContent.replace("# MakeCfg: Insert here", makeCfgData))