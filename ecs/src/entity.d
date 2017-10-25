module entity;

class Entity {
    size_t id;
    size_t[TypeInfo] components;

    bool haveComponents(T...)() {
        static foreach (component; T) {
            if (typeid(component) !in components) {
                return false;
            }
        }

        return true;
    }
}
