module test_model_builder;

import test_model;
import car_model;

class MyModelBuilder {
    private int a;
    private int b;
    private string c;
    private CarModel car;
  
        
    void setA(in int a) {
        this.a = a;
    }
    
    void setB(in int b) {
        this.b = b;
    }
    
    void setC(in string c) {
        this.c = c;
    }
    
    void setCar(in CarModel car) {
        this.car = car;
    }
    
    MyModel build() {
        return MyModel(
            this.a,
            this.b,
            this.c,
            this.car
        );
    }

}

class AnotherModelBuilder {
    private string name;
  
        
    void setName(in string name) {
        this.name = name;
    }
    
    AnotherModel build() {
        return AnotherModel(
            this.name
        );
    }

}
