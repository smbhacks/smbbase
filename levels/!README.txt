To convert levels, you have two options: use the !MAKE_LEVELS.bat (recommended) file or the command line.

If you choose the !MAKE_LEVELS.bat file:
Make sure your ROM is named "levels".

If you prefer using the command line:
Usage: LevelExtractor -v [input ROM] [type] -l -h -p -o
        [input ROM]: The SMB1 file you want to extract levels from
        [type]: The type of the ROM. -a to check automatically, -v for vanilla (41kb), -g for GreatEd (256kb)
        -v: Check the extractor version
        -l: Enable local labels
                -e: Exclude WorldAddrOffsets and AreaAddrOffsets from local labels
        -h: Include halfway pages
        -p: Add padding
                0~65536: Set padding value (default: 41216, which is 0xA100)
        -o filename: Set output filename