// the Programmers Parameter settings

class PParameter {

  int manipulatedParameter = 0;

  HashMap<String, PVariable> vars;
  
  PParameter() {
    vars = new HashMap<String, PVariable>();
  }

  void addVariable(String cnf) {
//    "LambdaZ: z geometric progression [default:1.01] [step:0.1, 0.01] [range:0,2]"
    // why does java regexps taunt me?
    
    int name_sep = cnf.indexOf(':');
    int cnf_sep = cnf.indexOf('[');
    String name = cnf.substring(0, name_sep);
    String description = cnf.substring(name_sep + 1, cnf_sep).trim();
    String config = cnf.substring(cnf_sep).trim();

    println("name: " + name);
    println("description: " + description);
    println("config: " + config);

    FloatVariable pv = null;    // XX todo nice generic PVariable

    for(String s : config.split("\\[")) {

      int sep = s.indexOf(":");
      if (sep < 0) continue;
      String cmd = s.substring(0, sep);
      String arg = s.substring(sep +1, s.indexOf("]"));

      if (cmd.equalsIgnoreCase("default")) {
        float v = Float.parseFloat(arg);
        pv = new FloatVariable(v, name, description);
      }

      if (cmd.equalsIgnoreCase("step")) {
        String[] vs = arg.split(",");
        pv.step = Float.parseFloat(vs[0]);
        pv.smallStep = Float.parseFloat(vs[1]);
      }
      
      if (cmd.equalsIgnoreCase("range")) {
        String[] vs = arg.split(",");
        pv.minVal = Float.parseFloat(vs[0]);
        pv.maxVal = Float.parseFloat(vs[1]);
      }
    }
    vars.put(name, pv);
  }

  float readFloat(String name) {
    return ((FloatVariable)vars.get(name)).v;
  }

  
  void keyPressed() {
    // if (key == CODED) {
    //   if (UP == keyCode)
    //     parms[manipulatedParameter] += largeChange;
    //   if (DOWN == keyCode)
    //     parms[manipulatedParameter] -= largeChange;
    //   if (RIGHT == keyCode)
    //     parms[manipulatedParameter] += smallChange;
    //   if (LEFT == keyCode)
    //     parms[manipulatedParameter] -= smallChange;
    //   createMesh();
    // }
    // if (' ' == key) {
    //   manipulatedParameter++;
    //   manipulatedParameter %= parms.length;
    // }

  }

  void renderHUD() {
    noLights();
    textSize(20);
    // for (int i = 0; i < parms.length; i++) {
    //   String prefix = (i == manipulatedParameter) ? "->" : "  ";
    //   text(prefix + names[i] + ": " + parms[i], 10, 20 + 30 * i);
    // }
  }
}

interface Adjustable {
  void addStep();
  void subStep();
  void addSmallStep();
  void subSmallStep();
}

abstract class PVariable implements Adjustable {
  String name, description;
  PVariable(String name, String description) {
    this.name = name;
    this.description = description;
  }
}

class FloatVariable extends PVariable {
  float v = 0.5, defaultValue = .5;
  float step = 0.1, smallStep = .01;
  float minVal = 0, maxVal = 1.0;

  FloatVariable(float defaultValue, String name, String description) {
    super(name, description);
    this.defaultValue = defaultValue;
    reset();
  }

  void reset() {
    v = defaultValue;
  }

  void add(float v) {
    v += step;
    v = constrain(v, minVal, maxVal);
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
}
