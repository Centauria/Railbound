import game;
import mir.ndslice;
import mir.stdio;

void main()
{
    auto m = GameMap("maps/3-4.csv");

    m.writeln;
    m.reset;
    m.writeln;
}
