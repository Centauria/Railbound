import game;
import mir.ndslice;
import mir.stdio;

void main()
{
    Cell[10] cells;
    cells[2].type.writeln;
    Cell.sizeof.writeln;
    cells[2].ports = 0x1110;
    cells[2].nports.writeln;

    auto m = GameMap(5, 3, 1, 3);
    auto x = slice!float(2, 3);
    x[] = 0;
    x.writeln;
}
