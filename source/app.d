import game;
import mir.ndslice;
import mir.stdio;

void main()
{
    Cell.sizeof.writeln;

    auto m = GameMap(5, 3, 1, 3);
    m.cells.writeln;
    m.cells.shape.writeln;
    m.cells.sizeof.writeln;
    m.sizeof.writeln;
    m.cells[0, 0].type.writeln;
}
