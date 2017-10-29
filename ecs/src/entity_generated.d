module entity_generated;

import std.container.array;

import entity;

import components : PositionComponent;
import components : VelocityComponent;
import components : Color;
import components : FigureComponent;
import components : MoveNode;
import components : RenderNode;

struct PhysicsGroup {
    Array!MoveNode moveNodes;
  
    
}

struct GapiGroup {
    Array!Color colorComponents;
    Array!FigureComponent figureComponents;
    Array!RenderNode renderNodes;
  
    
}

class EntityManagerMixin {
    Array!PositionComponent positionComponents;
    Array!VelocityComponent velocityComponents;
    GapiGroup gapi;
    PhysicsGroup physics;
  
    
}

class EntityMixin {
    
        
    Entity attachComponent(T)(T component) {
        static if (is(T == PositionComponent)) {
            manager.positionComponents.insert(component);
            components[typeid(component)] = manager.positionComponents.length - 1;
            
            // Check node: MoveNode
            {
                PositionComponent* position;
                VelocityComponent* velocity;
                
                int componentsCount = 1;
        
                if (typeid(VelocityComponent) in components) {
                    const index = components[typeid(VelocityComponent)];
                    velocity = &manager.velocityComponents[index];
                    ++componentsCount;
                }
                
                if (componentsCount == 2) {
                    manager.physics.moveNodes.insert(MoveNode(position, velocity));
                }
                
            }
            // Check node: RenderNode
            {
                PositionComponent* position;
                FigureComponent* figure;
                
                int componentsCount = 1;
        
                if (typeid(FigureComponent) in components) {
                    const index = components[typeid(FigureComponent)];
                    figure = &manager.gapi.figureComponents[index];
                    ++componentsCount;
                }
                
                if (componentsCount == 2) {
                    manager.gapi.renderNodes.insert(RenderNode(position, figure));
                }
                
            }
        }
        
        static if (is(T == VelocityComponent)) {
            manager.velocityComponents.insert(component);
            components[typeid(component)] = manager.velocityComponents.length - 1;
            
            // Check node: MoveNode
            {
                PositionComponent* position;
                VelocityComponent* velocity;
                
                int componentsCount = 1;
        
                if (typeid(PositionComponent) in components) {
                    const index = components[typeid(PositionComponent)];
                    position = &manager.positionComponents[index];
                    ++componentsCount;
                }
                
                if (componentsCount == 2) {
                    manager.physics.moveNodes.insert(MoveNode(position, velocity));
                }
                
            }
        }
        
        static if (is(T == Color)) {
            manager.gapi.colorComponents.insert(component);
            components[typeid(component)] = manager.gapi.colorComponents.length - 1;
            
        }
        
        static if (is(T == FigureComponent)) {
            manager.gapi.figureComponents.insert(component);
            components[typeid(component)] = manager.gapi.figureComponents.length - 1;
            
            // Check node: RenderNode
            {
                PositionComponent* position;
                FigureComponent* figure;
                
                int componentsCount = 1;
        
                if (typeid(PositionComponent) in components) {
                    const index = components[typeid(PositionComponent)];
                    position = &manager.positionComponents[index];
                    ++componentsCount;
                }
                
                if (componentsCount == 2) {
                    manager.gapi.renderNodes.insert(RenderNode(position, figure));
                }
                
            }
        }
        
        return this;
    }

}
