module test_model;

import annotation;
import car_model;

@Builder
struct MyModel {
    int a;
    int b;
    string c;
    CarModel car;
}

@Builder
struct AnotherModel {
    string name;
}
