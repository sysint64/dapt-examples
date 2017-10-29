import std.stdio;

import entity;
import components;

version (notDaptProcessingVersion)
void ecsProcess() {
    import entity;

    auto entityManager = new EntityManager();
    entityManager.createEntity()
        .attachComponent(PositionComponent(100, 100))
        .attachComponent(VelocityComponent(0.03, 0.01));

    entityManager.createEntity()
        .attachComponent(PositionComponent(100, 100))
        .attachComponent(VelocityComponent(0.03, 0.01));

    entityManager.createEntity()
        .attachComponent(VelocityComponent(0.03, 0.01));

    writeln(entityManager.entities);
    writeln(entityManager.positionComponents.length);
    writeln(entityManager.velocityComponents.length);
    writeln(entityManager.physics.moveNodes.length);
}

void main() {
    version (daptProcessingVersion) {
        import processors.entry;
        daptProcess();
    }

    version (notDaptProcessingVersion) {
        ecsProcess();
    }
}
