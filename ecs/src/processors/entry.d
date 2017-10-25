module processors.entry;

import dapt.processor;

void daptProcess() {
    version (daptProcessingVersion) {
        {
            import processors.ecs : process;
            auto processor = new Processor();
            processor.projectPath = "/home/andrey/projects/dapt-examples/ecs";
            processor.process(&process);
            processor.generateGeneratedFilesTxt(false);
        }
    }
}
