import sys

args = sys.argv[1:]

templateCfgPath = "scripts/template.cfg"
outputCfgPath = "generatedCfg.cfg"

sizes = ["2000", "4000"]
segmentsToAssign = {size: [] for size in sizes}
freeSpace = {size: [] for size in sizes}

for file in args:
    with open(file, "r", encoding="utf-8") as f:
        print(f"Reading segments from {file}...")
        content = f.read()
        for size in sizes:
            marker = f"<MakeCfg{size}: NewBank>"
            p = -1
            while True:
                p = content.find(marker, p + 1)
                if p == -1:
                    break
                r1 = content.rfind('"', 0, p)
                r2 = content.rfind('"', 0, r1) + 1
                segmentsToAssign[size].append(content[r2:r1])

with open(templateCfgPath, "r", encoding="utf-8") as f:
    templateContent = f.read()
    for size in sizes:
        marker = f"# MakeCfg{size}: free"
        p = -1
        while True:
            p = templateContent.find(marker, p + 1)
            if p == -1:
                break
            e = templateContent.rfind(":", 0, p)
            s = templateContent.rfind(" ", 0, e) + 1
            freeSpace[size].append(templateContent[s:e])

for size in sizes:
    print(f"Segments to assign (0x{size}):", ", ".join(segmentsToAssign[size]))
    print(f"Free space (0x{size}):", ", ".join(freeSpace[size]))

has_enough_space = True
for size in sizes:
    if len(segmentsToAssign[size]) > len(freeSpace[size]):
        print(f"Not enough free 0x{size} banks! Needed: {len(segmentsToAssign[size])}, Available: {len(freeSpace[size])}")
        has_enough_space = False

if has_enough_space:
    makeCfgData = ""
    for size in sizes:
        for seg, bank in zip(segmentsToAssign[size], freeSpace[size]):
            makeCfgData += f"    {seg}:    load = {bank},    type = ro;\n"

    with open(outputCfgPath, "w", encoding="utf-8") as f:
        f.write(templateContent.replace("# MakeCfg: Insert here", makeCfgData))
    print("Config generated successfully!")