import std.stdint;
import std.array : split, array, join;
import std.file : readText;
import std.csv;
import std.string : lineSplitter, strip, toUpper, empty;
import std.conv : to, ConvException;

import core.bitop;
import mir.algorithm.iteration : each;
import mir.ndslice;
import mir.ndslice.slice : Slice;
import mir.stdio;

enum Port : int8_t
{
    L,
    R,
    U,
    D
}

enum PortBits : uint8_t
{
    None = 0x00,
    L = 0x01,
    R = 0x02,
    U = 0x04,
    D = 0x08,
}

alias Direction = Port;

enum CellType : int16_t
{
    Normal,
    Locked,
    Block,
    Switch,
    Gate,
    Tunnel,
    Platform,
    Target
}

struct CarState
{
    size_t i, j;
    Direction d;
}

uint8_t parsePortsBitmask(string ports)
{
    uint8_t result = 0;

    static immutable uint8_t[char] portMap = [
        'L': PortBits.L,
        'R': PortBits.R,
        'U': PortBits.U,
        'D': PortBits.D
    ];

    foreach (char c; ports.toUpper())
    {
        if (auto bit = c in portMap)
            result |= *bit;
    }
    return result;
}

string bitmaskToPorts(uint8_t bitmask)
{
    string result = "";
    if (bitmask & PortBits.L)
        result ~= "L";
    if (bitmask & PortBits.R)
        result ~= "R";
    if (bitmask & PortBits.U)
        result ~= "U";
    if (bitmask & PortBits.D)
        result ~= "D";
    return result;
}

struct Cell
{
    CellType type;
    uint8_t ports;

    /** 
     * when nports == 3, connectivity == 0 means the side port connects to lower main port, connectivity == 1 otherwise.
     * e. g. ports == 0b1110 (LRUD: 0111), connectivity == 0 means R <-> U.
     * ports == 0b1011 (LRUD: 1101), connectivity == 0 means D <-> L.
     */
    uint8_t connectivity;

    int nports() const
    {
        return popcnt(ports);
    }

    bool isOpen(Port p)
    {
        return (ports & (1 << p)) > 0;
    }
}

struct GameMap
{
    size_t nrows, ncols;
    Slice!(Cell*, 2) cells;
    CarState[] initialCarState;
    size_t nblocks;

    CarState[] carState;

    this(size_t nrows, size_t ncols, size_t ncars, size_t nblocks)
    {
        this.nrows = nrows;
        this.ncols = ncols;
        cells = slice!Cell(nrows, ncols);
        // cells.each!((ref cell) { cell = Cell(); });
        initialCarState = new CarState[ncars];
        this.nblocks = nblocks;
    }

    this(string mapconfig)
    {
        string content = readText(mapconfig);
        auto lines = content.lineSplitter.array;
        assert(lines[2] == "", "format error");
        foreach (item; csvReader!(size_t[string])(lines[0 .. 2].join("\n"), null))
        {
            nrows = item["height"];
            ncols = item["width"];
            cells = slice!Cell(nrows, ncols);
            nblocks = item["blocks"];
        }
        CarState[size_t] cars;
        foreach (item; csvReader!(string[string])(lines[3 .. $].join("\n"), null))
        {
            auto i = item["i"].to!size_t;
            auto j = item["j"].to!size_t;
            CellType type;
            try
            {
                type = item["type"].strip.to!CellType;
            }
            catch (ConvException e)
            {
                writeln("Warning: Unknown type '", item["type"], "', using Normal");
                type = CellType.Normal;
            }
            cells[i, j].type = type;
            if (type == CellType.Locked)
            {
                if (!item["id"].empty)
                {
                    cars[item["id"].to!size_t] = CarState(i, j, item["direction"].to!Direction);
                }
            }
            cells[i, j].ports = parsePortsBitmask(item["ports"]);
        }
        initialCarState = new CarState[cars.length];
        foreach (size_t i; 0 .. cars.length)
        {
            initialCarState[i] = cars[i];
        }
    }

    /** 
     * Reset map with initial cells.
     */
    void reset()
    {
        cells.each!((ref cell) {
            if (cell.type == CellType.Normal)
            {
                cell.ports = 0;
            }
        });
        carState = initialCarState.dup;
    }
}

unittest
{
    auto m = GameMap(5, 3, 1, 3);
    assert(m.cells.shape == [5, 3]);
    assert(m.cells[0, 0].type == CellType.Normal);
    assert(m.cells[4, 2].ports == 0);
    assert(m.cells[4, 2].nports == 0);
    m.cells[4, 2].ports = 0b0100;
    assert(m.cells[4, 2].nports == 1);
    m.cells[4, 2].ports = 0b0110;
    assert(m.cells[4, 2].nports == 2);
    m.cells[4, 2].ports = 0b1101;
    assert(m.cells[4, 2].nports == 3);
    assert(m.initialCarState[0].d == 0);
}
