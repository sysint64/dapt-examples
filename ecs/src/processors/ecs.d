module processors.ecs;

import std.traits;
import std.path;
import std.string;
import std.uni;
import std.conv;
import std.container.array;

import dapt.processor;
import dapt.emitter;
import dapt.eclass;
import dapt.func;
import dapt.type;

import components;

struct Data {
    Processor processor;
    EClass.Builder entityManagerClassBuilder;
    EClass.Builder entityClassBuilder;
    EClass.Builder[string] groupClassBuilders;
    Function.Builder attachComponentBuilder;
}

string getTypeCamelName(T)() {
    const typeName = T.stringof;

    if (typeName.length > 1) {
        return typeName[0].toLower().to!string ~ typeName[1..$];
    } else {
        return typeName[0].toLower().to!string;
    }
}

string getArrayName(T)(in string name) {
    const typeCamelName = getTypeCamelName!(T);
    string arrayName = typeCamelName;

    if (typeCamelName.length > name.length && typeCamelName[$-name.length..$] == name) {
        arrayName ~= "s";
    } else {
        arrayName ~= name ~ "s";
    }

    return arrayName;
}

string getGroupFromAttribute(alias uda)() {
    static if (isType!uda) {
        return "";
    } else {
        return uda.group;
    }
}

string getAccessor(T, U)(in string name) {
    string accessor = getArrayName!(T)(name);
    enum uda = getUDAs!(T, U)[0];
    const group = getGroupFromAttribute!(uda);

    if (group != "") {
        accessor = group ~ "." ~ accessor;
    }

    return accessor;
}

void placingArrays(T)(ref Data data, in string name, in string group) {
    const typeName = T.stringof;
    const typeCamelName = getTypeCamelName!(T);
    const arrayName = getArrayName!(T)(name);

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

void resolveNodes(T)(ref Data data) {
    
    {

        import components : Component;

        static if (hasUDA!(Component, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, Component)) {
                mixin("alias type = typeof(Component." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: Component");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, Component);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Component." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Component." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(Component, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(Component($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : Node;

        static if (hasUDA!(Node, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, Node)) {
                mixin("alias type = typeof(Node." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: Node");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, Node);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Node." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Node." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(Node, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(Node($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : Vector2;

        static if (hasUDA!(Vector2, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, Vector2)) {
                mixin("alias type = typeof(Vector2." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: Vector2");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, Vector2);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Vector2." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Vector2." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(Vector2, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(Vector2($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : PositionComponent;

        static if (hasUDA!(PositionComponent, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, PositionComponent)) {
                mixin("alias type = typeof(PositionComponent." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: PositionComponent");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, PositionComponent);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(PositionComponent." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(PositionComponent." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(PositionComponent, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(PositionComponent($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : VelocityComponent;

        static if (hasUDA!(VelocityComponent, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, VelocityComponent)) {
                mixin("alias type = typeof(VelocityComponent." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: VelocityComponent");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, VelocityComponent);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(VelocityComponent." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(VelocityComponent." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(VelocityComponent, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(VelocityComponent($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : Color;

        static if (hasUDA!(Color, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, Color)) {
                mixin("alias type = typeof(Color." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: Color");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, Color);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Color." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Color." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(Color, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(Color($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : FigureComponent;

        static if (hasUDA!(FigureComponent, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, FigureComponent)) {
                mixin("alias type = typeof(FigureComponent." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: FigureComponent");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, FigureComponent);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(FigureComponent." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(FigureComponent." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(FigureComponent, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(FigureComponent($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : MoveNode;

        static if (hasUDA!(MoveNode, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, MoveNode)) {
                mixin("alias type = typeof(MoveNode." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: MoveNode");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, MoveNode);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(MoveNode." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(MoveNode." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(MoveNode, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(MoveNode($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import components : RenderNode;

        static if (hasUDA!(RenderNode, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, RenderNode)) {
                mixin("alias type = typeof(RenderNode." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: RenderNode");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, RenderNode);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(RenderNode." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(RenderNode." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(RenderNode, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(RenderNode($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
    }

    {

        import entity : Entity;

        static if (hasUDA!(Entity, Node)) {
            bool checkNode = false;

            foreach (immutable member; __traits(allMembers, Entity)) {
                mixin("alias type = typeof(Entity." ~ member ~ ");");

                if (is(type == T*) || is(type == T)) {
                    data.attachComponentBuilder
                        .addStatement("// Check node: Entity");

                    checkNode = true;
                }
            }

            if (checkNode) {
                data.attachComponentBuilder.openScope();

                enum members = __traits(allMembers, Entity);
                Array!StringEmittable nodeMembers;

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Entity." ~ member ~ ");");

                    data.attachComponentBuilder
                        .addStatement("$L $L;", type.stringof, member);

                    nodeMembers.insert(new StringEmittable(member));
                }

                data.attachComponentBuilder
                    .addStatement("");

                foreach (immutable member; members) {
                    mixin("alias type = typeof(Entity." ~ member ~ ");");

                    static if (!is(type == T*) && !is(type == T)) {
                        static if (isPointer!(type)) {
                            const typeName = type.stringof[0..$-1];
                        } else {
                            const typeName = type.stringof;
                        }

                        mixin("alias derefType = " ~ typeName ~ ";");
                        const componentsAccessor = getAccessor!(derefType, Component)("Component");

                        data.attachComponentBuilder
                            .addStatement("int componentsCount = 1;\n")
                            .openScope("if (typeid($L) in components)", typeName)
                            .addStatement("const index = components[typeid($L)];", typeName)
                            .addStatement("$L = &manager.$L[index];", member, componentsAccessor)
                            .addStatement("++componentsCount;")
                            .closeScope()
                            .addStatement("");
                    }
                }

                const nodesAccessor = getAccessor!(Entity, Node)("Node");

                data.attachComponentBuilder
                    .openScope("if (componentsCount == $L)", members.length)
                    .addStatement("manager.$L.insert(Entity($A<,>));", nodesAccessor, nodeMembers)
                    .closeScope()
                    .addStatement("");

                data.attachComponentBuilder.closeScope();
            }
        }
    
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
    processor.add(new ImportEmittable("entity"));
    processor.addln();

    data.attachComponentBuilder = new Function.Builder()
        .setName("attachComponent(T)")
        .addArgument(Argument.create("component", "T"))
        .setReturnType(Type.createPrimitiveType("Entity"));

    data.entityManagerClassBuilder = new EClass.Builder().setName("EntityManagerMixin");
    data.entityClassBuilder = new EClass.Builder()
        .setName("EntityMixin");

    
    {

        import components : Component;

        static if (hasUDA!(Component, Component)) {
            enum componentUDA = getUDAs!(Component, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : Component"));
            placingArrays!(Component)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(Component, Node)) {
            enum nodeUDA = getUDAs!(Component, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : Component"));
            placingArrays!(Component)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : Node;

        static if (hasUDA!(Node, Component)) {
            enum componentUDA = getUDAs!(Node, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : Node"));
            placingArrays!(Node)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(Node, Node)) {
            enum nodeUDA = getUDAs!(Node, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : Node"));
            placingArrays!(Node)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : Vector2;

        static if (hasUDA!(Vector2, Component)) {
            enum componentUDA = getUDAs!(Vector2, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : Vector2"));
            placingArrays!(Vector2)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(Vector2, Node)) {
            enum nodeUDA = getUDAs!(Vector2, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : Vector2"));
            placingArrays!(Vector2)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : PositionComponent;

        static if (hasUDA!(PositionComponent, Component)) {
            enum componentUDA = getUDAs!(PositionComponent, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : PositionComponent"));
            placingArrays!(PositionComponent)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(PositionComponent, Node)) {
            enum nodeUDA = getUDAs!(PositionComponent, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : PositionComponent"));
            placingArrays!(PositionComponent)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : VelocityComponent;

        static if (hasUDA!(VelocityComponent, Component)) {
            enum componentUDA = getUDAs!(VelocityComponent, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : VelocityComponent"));
            placingArrays!(VelocityComponent)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(VelocityComponent, Node)) {
            enum nodeUDA = getUDAs!(VelocityComponent, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : VelocityComponent"));
            placingArrays!(VelocityComponent)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : Color;

        static if (hasUDA!(Color, Component)) {
            enum componentUDA = getUDAs!(Color, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : Color"));
            placingArrays!(Color)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(Color, Node)) {
            enum nodeUDA = getUDAs!(Color, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : Color"));
            placingArrays!(Color)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : FigureComponent;

        static if (hasUDA!(FigureComponent, Component)) {
            enum componentUDA = getUDAs!(FigureComponent, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : FigureComponent"));
            placingArrays!(FigureComponent)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(FigureComponent, Node)) {
            enum nodeUDA = getUDAs!(FigureComponent, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : FigureComponent"));
            placingArrays!(FigureComponent)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : MoveNode;

        static if (hasUDA!(MoveNode, Component)) {
            enum componentUDA = getUDAs!(MoveNode, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : MoveNode"));
            placingArrays!(MoveNode)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(MoveNode, Node)) {
            enum nodeUDA = getUDAs!(MoveNode, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : MoveNode"));
            placingArrays!(MoveNode)(data, "Node", nodeGroup);
        }
    
    }

    {

        import components : RenderNode;

        static if (hasUDA!(RenderNode, Component)) {
            enum componentUDA = getUDAs!(RenderNode, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("components : RenderNode"));
            placingArrays!(RenderNode)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(RenderNode, Node)) {
            enum nodeUDA = getUDAs!(RenderNode, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("components : RenderNode"));
            placingArrays!(RenderNode)(data, "Node", nodeGroup);
        }
    
    }

    {

        import entity : Entity;

        static if (hasUDA!(Entity, Component)) {
            enum componentUDA = getUDAs!(Entity, Component)[0];
            const componentGroup = getGroupFromAttribute!(componentUDA);

            processor.add(new ImportEmittable("entity : Entity"));
            placingArrays!(Entity)(data, "Component", componentGroup);
        } else

        static if (hasUDA!(Entity, Node)) {
            enum nodeUDA = getUDAs!(Entity, Node)[0];
            const nodeGroup = getGroupFromAttribute!(nodeUDA);

            processor.add(new ImportEmittable("entity : Entity"));
            placingArrays!(Entity)(data, "Node", nodeGroup);
        }
    
    }


    // handle attachComponent method

    
    {

        import components : Component;

        static if (hasUDA!(Component, Component)) {
            const accessor = getAccessor!(Component, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == Component))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(Component)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : Node;

        static if (hasUDA!(Node, Component)) {
            const accessor = getAccessor!(Node, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == Node))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(Node)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : Vector2;

        static if (hasUDA!(Vector2, Component)) {
            const accessor = getAccessor!(Vector2, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == Vector2))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(Vector2)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : PositionComponent;

        static if (hasUDA!(PositionComponent, Component)) {
            const accessor = getAccessor!(PositionComponent, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == PositionComponent))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(PositionComponent)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : VelocityComponent;

        static if (hasUDA!(VelocityComponent, Component)) {
            const accessor = getAccessor!(VelocityComponent, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == VelocityComponent))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(VelocityComponent)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : Color;

        static if (hasUDA!(Color, Component)) {
            const accessor = getAccessor!(Color, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == Color))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(Color)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : FigureComponent;

        static if (hasUDA!(FigureComponent, Component)) {
            const accessor = getAccessor!(FigureComponent, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == FigureComponent))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(FigureComponent)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : MoveNode;

        static if (hasUDA!(MoveNode, Component)) {
            const accessor = getAccessor!(MoveNode, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == MoveNode))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(MoveNode)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import components : RenderNode;

        static if (hasUDA!(RenderNode, Component)) {
            const accessor = getAccessor!(RenderNode, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == RenderNode))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(RenderNode)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }

    {

        import entity : Entity;

        static if (hasUDA!(Entity, Component)) {
            const accessor = getAccessor!(Entity, Component)("Component");

            data.attachComponentBuilder
                .openScope("static if (is(T == Entity))")
                .addStatement("manager.$L.insert(component);", accessor)
                .addStatement("components[typeid(component)] = manager.$L.length - 1;", accessor)
                .addStatement("");

            resolveNodes!(Entity)(data);

            data.attachComponentBuilder
                .closeScope()
                .addStatement("");
        }
    
    }


    processor.addln();

    foreach (key, builder; data.groupClassBuilders) {
        processor.add(builder.build());
        processor.addln();
    }

    processor.add(data.entityManagerClassBuilder.build());
    processor.addln();

    data.attachComponentBuilder.addStatement("return this;");
    data.entityClassBuilder.addFunction(data.attachComponentBuilder.build());

    processor.add(data.entityClassBuilder.build());
    processor.closeFile();
}