module entity;

import std.container.array;
import std.traits;
import components;

version (notDaptProcessingVersion) {
    import entity_generated;
}

class Entity {
    EntityManager manager;
    size_t id;
    size_t[TypeInfo] components;

    this(EntityManager manager) {
        this.manager = manager;
    }

    bool haveComponents(T...)() {
        static foreach (component; T) {
            if (typeid(component) !in components) {
                return false;
            }
        }

        return true;
    }

    version (notDaptProcessingVersion) {
        mixin EntityMixin;

        Entity attachComponent(T)(T component) {
            debug assert(hasUDA!(component, Component));
            resolveNodes(component);
            return this;
        }
    }
}

class EntityManager {
    Array!Entity entities;

    Entity createEntity() {
        auto entity = new Entity(this);
        entities.insert(entity);
        entity.id = entities.length - 1;
        return entity;
    }

    version (notDaptProcessingVersion) {
        mixin EntityManagerMixin;
    }
}
