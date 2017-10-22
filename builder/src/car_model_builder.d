module car_model_builder;

import car_model;

class CarModelBuilder {
    private float gas;
    private bool isNew;
    private string yearOfIssue;
  
        
    void setGas(in float gas) {
        this.gas = gas;
    }
    
    void setIsnew(in bool isNew) {
        this.isNew = isNew;
    }
    
    void setYearofissue(in string yearOfIssue) {
        this.yearOfIssue = yearOfIssue;
    }
    
    CarModel build() {
        return CarModel(
            this.gas,
            this.isNew,
            this.yearOfIssue
        );
    }

}
