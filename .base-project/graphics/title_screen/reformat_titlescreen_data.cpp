#include <iostream>
#include <fstream>
#include <vector>

//from stackoverflow
template <typename T, typename U>
bool allequal(const T& t, const U& u) {
    return t == u;
}

template <typename T, typename U, typename... Others>
bool allequal(const T& t, const U& u, Others const &... args) {
    return (t == u) && allequal(u, args...);
}

int main(int argc, char* argv[])
{
    int BAD_TILE = 0x24;
    if (argc > 1) BAD_TILE = atoi(argv[1]);
    std::ifstream inputf("titlescreen_nexxt.nam", std::ios::binary);
    std::vector<unsigned char> buffer(std::istreambuf_iterator<char>(inputf), {});
    if (buffer.size() != 0x400)
    {
        std::cout << "Error. titlescreen.nam is not a valid nametable file.";
        return -1;
    }
    std::vector<bool> processed(0x400);
    for (int x = 0; x < 0x400; x++) processed[x] = false;
    std::ofstream outputf("titlescreen_smb.nam", std::ios::binary);
    std::vector<unsigned char> output;
    for (int c = 0; c < 0x400;)
    {
        //go to allowed tile
        while (buffer[c] == BAD_TILE && c < 0x3c0) c++;

        //set address
        int address = 0x2000 + c;
        unsigned char hiaddr = address >> 8;
        unsigned char loaddr = address & 0x00FF;

        //get data
        unsigned char length = 0;
        std::vector<unsigned char> tiles;
        bool rle = allequal(buffer[c], buffer[c + 1], buffer[c + 2]) && (c < 0x400 - 3);
        if (rle)
        {
            tiles.push_back(buffer[c]);
            do length++;
            while (buffer[c + length] == buffer[c + length + 1] && (c + length) < 0x400 - 2);
            if (c + length == 0x3fe) if (buffer[c + length] == buffer[c + length + 1]) length++;
            length++;
        }
        else
        {
            while ((buffer[c + length] != BAD_TILE || (c + length) >= 0x3c0) && (c + length) < 0x400)
            {
                tiles.push_back(buffer[c + length]);
                length++;
                if ((c + length) < 0x400 - 5)
                {
                    if (allequal(buffer[c + length], buffer[c + length + 1], buffer[c + length + 2], buffer[c + length + 3]))
                        break;
                }
            }
        }
        c += length;

        //transfer to output
        if (rle) length += 0x40;
        output.push_back(hiaddr);
        output.push_back(loaddr);
        output.push_back(length);
        for (auto& tile : tiles) output.push_back(tile);
    }
    std::copy(output.cbegin(), output.cend(), std::ostreambuf_iterator<char>(outputf));
    std::cout << "Conversion complete.";
}
