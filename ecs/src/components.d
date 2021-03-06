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

@Component()
struct VelocityComponent {
    float dx;
    float dy;
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

@Node("physics")
struct MoveNode {
    PositionComponent* position;
    VelocityComponent* velocity;
}

@Node("gapi")
struct RenderNode {
    PositionComponent* position;
    FigureComponent* figure;
}
