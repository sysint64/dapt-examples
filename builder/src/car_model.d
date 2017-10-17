module car_model;

import annotation;

@Builder
struct CarModel {
    float gas;
    bool isNew;
    string yearOfIssue;
}
