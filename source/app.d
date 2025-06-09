import std.stdio;
import game;

void main()
{
    Cell[10] cells;
    printf("%d\n", cells[2].type);
    printf("%lld\n", Cell.sizeof);
    cells[2].ports = 0x1110;
    printf("%d\n", cells[2].nports);

    auto m = GameMap(5, 3, 1, 3);
}
