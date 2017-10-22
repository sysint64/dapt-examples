module processors.entry;

import dapt.processor;

void daptProcess() {
    version (daptProcessingVersion) {
        {
            import processors.builder : process;
            auto processor = new Processor();
            processor.projectPath = "/home/andrey/projects/builder";
            processor.process(&process);
            processor.generateGeneratedFilesTxt(false);
        }
    }
}
