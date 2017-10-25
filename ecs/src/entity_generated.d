module entity_generated;

import std.container.array;

import components : PositionComponent;
import components : Color;
import components : FigureComponent;

struct GapiGroup {
    Array!Color colorComponents;
    Array!FigureComponent figureComponents;
  
    
}
class EntityManagerMixin {
    Array!PositionComponent positionComponents;
    GapiGroup gapi;
  
    
}
