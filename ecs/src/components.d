module components;

import std.container.array;

// Attributes --------------------------------------------------------------------------------------

struct Component {
    string group = "";
}

struct Node {
    string group = "";
}

// Data --------------------------------------------------------------------------------------------

struct Vector2 {
    float x;
    float y;
}

@Component()
struct PositionComponent {
    float x;
    float y;
}

@Component("gapi")
struct Color {
    float r;
    float g;
    float b;
    float a;
}

@Component("gapi")
struct FigureComponent {
    Color color;
    Array!Vector2 points;
}

@Node
struct MoveNode {
    PositionComponent* position;
    PositionComponent* velocity;
}

@Node("gapi")
struct RenderNode {
    PositionComponent* position;
    FigureComponent* figure;
}
