import std.stdio;
import std.stdint;

enum Port
{
    L,
    R,
    U,
    D
}

enum CellType{
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
    uint32_t ports;
}

void main()
{
    Cell[10] cells;
    printf("%d\n", cells[2].type);
    printf("%lld\n", Cell.sizeof);
}
