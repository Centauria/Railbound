import std.stdint;
import core.bitop;
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

enum CellType : int16_t
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
        cells.each!((ref cell) { cell = Cell(); });
        initialCarState = new CarState[ncars];
        this.nblocks = nblocks;
    }

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
