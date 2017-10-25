module processors.ecs;

import std.traits;
import std.path;
import std.string;
import std.uni;
import std.conv;

import dapt.processor;
import dapt.emitter;
import dapt.eclass;
import dapt.func;

import components;

struct Data {
    Processor processor;
    EClass.Builder entityManagerClassBuilder;
    EClass.Builder[string] groupClassBuilders;
}

void processComponent(T)(ref Data data, in string group) {
    const typeName = T.stringof;
    const typeCamelName = typeName.length > 1 ? typeName[0].toLower().to!string ~ typeName[1..$]
                                              : typeName[0].toLower().to!string;

    string arrayName = typeCamelName;

    if (typeCamelName.length > 9 && typeCamelName[$-9..$] == "Component") {
        arrayName ~= "s";
    } else {
        arrayName ~= "Components";
    }

    if (group == "") {
        data.entityManagerClassBuilder
            .addArgument(Argument.create(arrayName, "Array!" ~ typeName));
    } else {
        const groupClassName = capitalize(group) ~ "Group";

        if (group !in data.groupClassBuilders) {
            data.groupClassBuilders[group] = new EClass.Builder(true)
                .setName(groupClassName);

            data.entityManagerClassBuilder
                .addArgument(Argument.create(group, groupClassName));
        }

        data.groupClassBuilders[group]
            .addArgument(Argument.create(arrayName, "Array!" ~ typeName));
    }
}

void process(Processor processor) {
    Data data;

    data.processor = processor;

    const path = buildPath(processor.projectPath, "src", "entity_generated.d");
    processor.openFile(path);

    processor.add(new ModuleEmittable("entity_generated"));
    processor.addln();
    processor.add(new ImportEmittable("std.container.array"));
    processor.addln();

    auto entityManagerClassBuilder = new EClass.Builder()
        .setName("EntityManagerMixin");

    data.entityManagerClassBuilder = entityManagerClassBuilder;

    
    {

        import components : Component;

        static if (hasUDA!(Component, Component)) {
            auto componentUDA = getUDAs!(Component, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : Component"));
            processComponent!(Component)(data, componentGroup);
        }

        static if (hasUDA!(Component, Node)) {
        }
    
    }

    {

        import components : Node;

        static if (hasUDA!(Node, Component)) {
            auto componentUDA = getUDAs!(Node, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : Node"));
            processComponent!(Node)(data, componentGroup);
        }

        static if (hasUDA!(Node, Node)) {
        }
    
    }

    {

        import components : Vector2;

        static if (hasUDA!(Vector2, Component)) {
            auto componentUDA = getUDAs!(Vector2, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : Vector2"));
            processComponent!(Vector2)(data, componentGroup);
        }

        static if (hasUDA!(Vector2, Node)) {
        }
    
    }

    {

        import components : PositionComponent;

        static if (hasUDA!(PositionComponent, Component)) {
            auto componentUDA = getUDAs!(PositionComponent, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : PositionComponent"));
            processComponent!(PositionComponent)(data, componentGroup);
        }

        static if (hasUDA!(PositionComponent, Node)) {
        }
    
    }

    {

        import components : Color;

        static if (hasUDA!(Color, Component)) {
            auto componentUDA = getUDAs!(Color, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : Color"));
            processComponent!(Color)(data, componentGroup);
        }

        static if (hasUDA!(Color, Node)) {
        }
    
    }

    {

        import components : FigureComponent;

        static if (hasUDA!(FigureComponent, Component)) {
            auto componentUDA = getUDAs!(FigureComponent, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : FigureComponent"));
            processComponent!(FigureComponent)(data, componentGroup);
        }

        static if (hasUDA!(FigureComponent, Node)) {
        }
    
    }

    {

        import components : MoveNode;

        static if (hasUDA!(MoveNode, Component)) {
            auto componentUDA = getUDAs!(MoveNode, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : MoveNode"));
            processComponent!(MoveNode)(data, componentGroup);
        }

        static if (hasUDA!(MoveNode, Node)) {
        }
    
    }

    {

        import components : RenderNode;

        static if (hasUDA!(RenderNode, Component)) {
            auto componentUDA = getUDAs!(RenderNode, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("components : RenderNode"));
            processComponent!(RenderNode)(data, componentGroup);
        }

        static if (hasUDA!(RenderNode, Node)) {
        }
    
    }

    {

        import entity : Entity;

        static if (hasUDA!(Entity, Component)) {
            auto componentUDA = getUDAs!(Entity, Component)[0];
            string componentGroup = "";

            static if (isType!componentUDA) {
                componentGroup = "";
            } else {
                componentGroup = componentUDA.group;
            }

            processor.add(new ImportEmittable("entity : Entity"));
            processComponent!(Entity)(data, componentGroup);
        }

        static if (hasUDA!(Entity, Node)) {
        }
    
    }


    processor.addln();

    foreach (key, builder; data.groupClassBuilders) {
        processor.add(builder.build());
    }

    processor.add(entityManagerClassBuilder.build());
    processor.closeFile();
}