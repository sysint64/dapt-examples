module processors.builder;

import std.traits;
import std.string;
import std.container.array;

import dapt.type;
import dapt.func;
import dapt.eclass;
import dapt.processor;
import dapt.emitter;

import annotation;

void process(Processor processor) {
    
    {

        import test_model : MyModel;

        FileOpenMode mode;

        static if (hasUDA!(MyModel, Builder)) {
            mode = processor.openFile("/home/andrey/projects/builder/src/test_model.d"[0..$-2] ~ "_builder.d");

            if (mode == FileOpenMode.write) {
                processor.add(new ModuleEmittable("test_model" ~ "_builder"));
                processor.addln();
                processor.add(new StringEmittable("import test_model;\n"));
            }

            auto classBuilder = new EClass.Builder()
                .setName("MyModel" ~ "Builder");

            Array!StringEmittable buildArguments;

            foreach (member; __traits(allMembers, MyModel)) {
                alias memberType = typeof(mixin("MyModel." ~ member));

                static if (!isBuiltinType!(memberType))
                    processor.add(StringEmittable.create("import $L;\n", moduleName!memberType));

                classBuilder.addArgument(Argument.create(member, memberType.stringof, "private"));
                auto methodBuilder = new Function.Builder()
                    .setName("set" ~ capitalize(member))
                    .addArgument(Argument.create(member, memberType.stringof, "in"))
                    .addStatement("this.$L = $L;", member, member)
                    .setReturnType(Type.createPrimitiveType("void"));

                classBuilder.addFunction(methodBuilder.build());
                buildArguments.insert(new StringEmittable("    this." ~ member));
            }

            auto methodBuilder = new Function.Builder()
                .setName("build")
                .setReturnType(Type.createPrimitiveType("MyModel"));

            if (!buildArguments.empty()) {
                methodBuilder.addStatement("return MyModel(\n$A<,\n>\n);", buildArguments);
            } else {
                methodBuilder.addStatement("return MyModel();");
            }

            classBuilder.addFunction(methodBuilder.build());

            processor.addln();
            processor.add(classBuilder.build());
            processor.closeFile();
        }
    
    }

    {

        import test_model : AnotherModel;

        FileOpenMode mode;

        static if (hasUDA!(AnotherModel, Builder)) {
            mode = processor.openFile("/home/andrey/projects/builder/src/test_model.d"[0..$-2] ~ "_builder.d");

            if (mode == FileOpenMode.write) {
                processor.add(new ModuleEmittable("test_model" ~ "_builder"));
                processor.addln();
                processor.add(new StringEmittable("import test_model;\n"));
            }

            auto classBuilder = new EClass.Builder()
                .setName("AnotherModel" ~ "Builder");

            Array!StringEmittable buildArguments;

            foreach (member; __traits(allMembers, AnotherModel)) {
                alias memberType = typeof(mixin("AnotherModel." ~ member));

                static if (!isBuiltinType!(memberType))
                    processor.add(StringEmittable.create("import $L;\n", moduleName!memberType));

                classBuilder.addArgument(Argument.create(member, memberType.stringof, "private"));
                auto methodBuilder = new Function.Builder()
                    .setName("set" ~ capitalize(member))
                    .addArgument(Argument.create(member, memberType.stringof, "in"))
                    .addStatement("this.$L = $L;", member, member)
                    .setReturnType(Type.createPrimitiveType("void"));

                classBuilder.addFunction(methodBuilder.build());
                buildArguments.insert(new StringEmittable("    this." ~ member));
            }

            auto methodBuilder = new Function.Builder()
                .setName("build")
                .setReturnType(Type.createPrimitiveType("AnotherModel"));

            if (!buildArguments.empty()) {
                methodBuilder.addStatement("return AnotherModel(\n$A<,\n>\n);", buildArguments);
            } else {
                methodBuilder.addStatement("return AnotherModel();");
            }

            classBuilder.addFunction(methodBuilder.build());

            processor.addln();
            processor.add(classBuilder.build());
            processor.closeFile();
        }
    
    }

    {

        import car_model : CarModel;

        FileOpenMode mode;

        static if (hasUDA!(CarModel, Builder)) {
            mode = processor.openFile("/home/andrey/projects/builder/src/car_model.d"[0..$-2] ~ "_builder.d");

            if (mode == FileOpenMode.write) {
                processor.add(new ModuleEmittable("car_model" ~ "_builder"));
                processor.addln();
                processor.add(new StringEmittable("import car_model;\n"));
            }

            auto classBuilder = new EClass.Builder()
                .setName("CarModel" ~ "Builder");

            Array!StringEmittable buildArguments;

            foreach (member; __traits(allMembers, CarModel)) {
                alias memberType = typeof(mixin("CarModel." ~ member));

                static if (!isBuiltinType!(memberType))
                    processor.add(StringEmittable.create("import $L;\n", moduleName!memberType));

                classBuilder.addArgument(Argument.create(member, memberType.stringof, "private"));
                auto methodBuilder = new Function.Builder()
                    .setName("set" ~ capitalize(member))
                    .addArgument(Argument.create(member, memberType.stringof, "in"))
                    .addStatement("this.$L = $L;", member, member)
                    .setReturnType(Type.createPrimitiveType("void"));

                classBuilder.addFunction(methodBuilder.build());
                buildArguments.insert(new StringEmittable("    this." ~ member));
            }

            auto methodBuilder = new Function.Builder()
                .setName("build")
                .setReturnType(Type.createPrimitiveType("CarModel"));

            if (!buildArguments.empty()) {
                methodBuilder.addStatement("return CarModel(\n$A<,\n>\n);", buildArguments);
            } else {
                methodBuilder.addStatement("return CarModel();");
            }

            classBuilder.addFunction(methodBuilder.build());

            processor.addln();
            processor.add(classBuilder.build());
            processor.closeFile();
        }
    
    }

}