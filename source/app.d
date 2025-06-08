import std.stdio;
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

struct Cell
{
    CellType type;
    uint16_t ports;

    // when nports == 3, connectivity == 0 means the side port connects to lower main port, connectivity == 1 otherwise.
    // e. g. ports == 0x1110 (LRUD: 0111), connectivity == 0 means R <-> U.
    // ports == 0x1011 (LRUD: 1101), connectivity == 0 means D <-> L.
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

void main()
{
    Cell[10] cells;
    printf("%d\n", cells[2].type);
    printf("%lld\n", Cell.sizeof);
    cells[2].ports = 0x1110;
    printf("%d\n", cells[2].nports);
}
