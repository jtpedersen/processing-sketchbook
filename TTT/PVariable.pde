interface Adjustable {
  void addStep();
  void subStep();
  void addSmallStep();
  void subSmallStep();
  void reset();
}

abstract class PVariable implements Adjustable {
  String name, description, cnf;

  PVariable() {}
  
  PVariable(String name, String description) {
    this.name = name;
    this.description = description;
  }

  String saveString() {
    return cnf;
  }

  String toString() {
    return "name: " + description;
  }

  float asFloat() {
    return 0.0;
  }

  int asInt() {
    return 0;
  }
}

class FloatVariable extends PVariable {
  float v = 0.5, defaultValue = .5;
  float step = 0.1, smallStep = .01;
  float minVal = -4242.0, maxVal = 4242.0; // large arbitrary numbers

  FloatVariable(HashMap<String, String> cnf) {
    if (cnf.containsKey("default")) {
      defaultValue = v = Float.parseFloat(cnf.get("default"));
    }

    if (cnf.containsKey("step")) {
      String[] vs = cnf.get("step").split(",");
      step = Float.parseFloat(vs[0]);
      smallStep = Float.parseFloat(vs[1]);
    }
      
    if (cnf.containsKey("range")) {
      String[] vs = cnf.get("range").split(",");
      minVal = Float.parseFloat(vs[0]);
      maxVal = Float.parseFloat(vs[1]);
    }
  }
  
  FloatVariable(float defaultValue, String name, String description) {
    super(name, description);
    this.defaultValue = defaultValue;
    reset();
  }

  String saveString() {
    return name + ": " + description + "[default:" + v + "]" 
      + "[step:" + step + ", " + smallStep + "]" 
      + "[range:" + minVal + "," + maxVal + "]";
  }

  
  float asFloat() {
    return v;
  }

  int  asInt() {
    return (int)v;
  }
  
  void reset() {
    v = defaultValue;
  }

  void add(float inc) {
    v = constrain(v + inc, minVal, maxVal);
  }
  
  void addStep() {
    add(step);
  }
  void subStep() {
    add(-step);
  }
  void addSmallStep() {
    add(smallStep);
  }
  void subSmallStep() {
    add(-smallStep);
  }

  String toString() {
    return nf(v, 3,3) + ": " +name;
  }
  
  String full() {
    return  "v: " + v + ", defaultValue: " + defaultValue + ", step: " + step +  ", smallStep: " + smallStep +  ". minVal: " + minVal + ", maxVal: " + maxVal;
  }
}
