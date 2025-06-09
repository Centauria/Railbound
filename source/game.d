import std.stdint;
import core.bitop;

enum Port
{
    L,
    R,
    U,
    D
}

enum CellType
{
    Normal,
    Locked,
    Switch,
    Gate,
    Tunnel,
    Platform
}

struct CarState
{
    uint32_t i, j;
    Port d;
}

struct Cell
{
    CellType type;
    uint16_t ports;

    /** 
     * when nports == 3, connectivity == 0 means the side port connects to lower main port, connectivity == 1 otherwise.
     * e. g. ports == 0x1110 (LRUD: 0111), connectivity == 0 means R <-> U.
     * ports == 0x1011 (LRUD: 1101), connectivity == 0 means D <-> L.
     */
    uint16_t connectivity;

    int nports()
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
    Cell[] cells;
    CarState[] initialCarState;
    size_t nblocks;

    CarState[] carState;

    this(size_t nrows, size_t ncols, size_t ncars, size_t nblocks)
    {
        this.nrows = nrows;
        this.ncols = ncols;
        cells = new Cell[nrows * ncols];
        initialCarState = new CarState[ncars];
        this.nblocks = nblocks;
    }

    void reset()
    {
        foreach (Cell cell; cells)
        {
            if (cell.type == CellType.Normal)
            {
                cell.ports = 0;
            }
        }
        carState = initialCarState.dup;
    }
}

unittest
{
    auto m = GameMap(5, 3, 1, 3);
    assert(m.cells[0].type == CellType.Normal);
    assert(m.initialCarState[0].d == 0);
}
