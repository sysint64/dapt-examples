import std.stdio;

void main() {
    version (daptProcessingVersion) {
        import processors.entry;
        daptProcess();
    }

    writeln("Edit source/app.d to start your project.");
}
