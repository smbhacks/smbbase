import glob
import os
import sys
import subprocess

modules_dir = "modules"
ids_file = "ids.asm"
segments_file = "segments.asm"
lut_file = "lut.asm"
pathToHere = "music/famitone"
BANKSIZE = 0x2000

curBankSize = 0
bank = 0
newBank = True

def includeInFile(file, size, filename, label, format="incbin"):
    global curBankSize, newBank, bank

    curBankSize += size
    if curBankSize > BANKSIZE:
        curBankSize = 0
        bank += 1
        newBank = True
    if newBank:
        file.write(f'.segment "MUSIC{bank}" ;<MakeCfg2000: NewBank>\n')
        newBank = False
    file.write(f'{label}: .{format} "{pathToHere}/{modules_dir}/{filename}"\n')

with open(ids_file, "w", encoding="utf-8") as ids_f, \
     open(lut_file, "w", encoding="utf-8") as lut_f, \
     open(segments_file, "w", encoding="utf-8") as segments_f:

    id_counter = 1
    ids_f.write(";This file is generated, no need to modify manually!\n")
    segments_f.write(";This file is generated, no need to modify manually!\n")
    lut_f.write(";This file is generated, no need to modify manually!\n")
    lut_f.write("SongBankLut:\n")
    
    module_files = glob.glob(os.path.join(modules_dir, "*.txt"))
    
    for file in module_files:
        try:
            text2vol5_result = subprocess.run(
                ["text2vol5", file, "-ca65", "-ntsc"],
                capture_output=True,
                text=True,
                check=True
            )
        except subprocess.CalledProcessError as e:
            if e.stderr:
                print(f"Error output:\n{e.stderr.strip()}", file=sys.stderr)
            if e.stdout:
                print(f"Standard output:\n{e.stdout.strip()}", file=sys.stderr)
            
            sys.exit(1)

        data_size = 0
        for line in text2vol5_result.stdout.splitlines():
            if "Total data size:" in line:
                data_size = int(line.split(":")[1].strip().split()[0])
                break

        print(f"Processing file: {file}, size: {data_size} bytes")
        base_name = os.path.splitext(os.path.basename(file))[0]
        
        includeInFile(segments_f, data_size, f"{base_name}.s", f"{base_name}_data", "include")
        ids_f.write(f"{base_name}_id = {id_counter}\n")
        lut_f.write(f".byte <.bank({base_name}_data)\n")
        id_counter += 1

    lut_f.write("\nSongAddressLoLut:\n")
    for file in module_files:
        base_name = os.path.splitext(os.path.basename(file))[0]
        lut_f.write(f".lobytes {base_name}_data\n")

    lut_f.write("\nSongAddressHiLut:\n")
    for file in module_files:
        base_name = os.path.splitext(os.path.basename(file))[0]
        lut_f.write(f".hibytes {base_name}_data\n")