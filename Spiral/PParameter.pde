// the Programmers Parameter settings

class PParameter {

  int manipulatedParameter = 0;
  ArrayList<PVariable> vars;
  boolean shiftPressed;
  boolean hide;
  
  PParameter() {
    vars = new ArrayList<PVariable>();
  }

  PVariable var(String cnf) {
//    "LambdaZ: z geometric progression [default:1.01] [step:0.1, 0.01] [range:0,2]"
    // why does java regexps taunt me?
    
    int name_sep = cnf.indexOf(':');
    int cnf_sep = cnf.indexOf('[');
    String name = cnf.substring(0, name_sep);

    PVariable pv = lookUp(name);
    if (pv != null)
      return pv;             // this is already parsed, or a duplicate made by mistake
    
    String description = cnf.substring(name_sep + 1, cnf_sep).trim();
    String config = cnf.substring(cnf_sep).trim();

    // println("name: " + name);
    // println("description: " + description);
    // println("config: " + config);

    HashMap<String, String> options = splitConfig(config);
    pv = getVariableFromConfig(options);
    pv.name = name;
    pv.description = description;
    vars.add(pv);
    return pv;
  }

  PVariable lookUp(String name) {
    for (PVariable pv : vars) {
      if (pv.name.equals(name))
        return pv;
    }
    return null;
  }

  HashMap<String, String> splitConfig(String config) {
    HashMap<String, String> res = new HashMap<String, String>();
    for(String s : config.split("\\[")) {
      int sep = s.indexOf(":");
      if (sep < 0) continue;
      String cmd = s.substring(0, sep);
      String arg = s.substring(sep +1, s.indexOf("]"));
      res.put(cmd.toLowerCase(), arg);
    }    
    return res;
  }

  PVariable getVariableFromConfig(HashMap<String, String> config) {
    // use defalt to deduce type
    String val = config.get("default");
    if (isFloatDefaultValue(val))
      return new FloatVariable(config);
    
    return null;
  }

  boolean isFloatDefaultValue(String val) {
    if (null == val) {
      return true;
    }
    return match(val, "\\d*\\.?\\d*") != null;

  }
  
  float readFloat(String name) {
    return ((FloatVariable)lookUp(name)).v;
  }

  void keyPressed() {
    if (key == CODED) {
      if (hide) return;         // do not manipulate what you can not see
      if (SHIFT == keyCode) {
        shiftPressed = true;
      } else if (UP == keyCode) {
        manipulatedParameter--;
        if (manipulatedParameter < 0)
          manipulatedParameter = vars.size() -1;
      } else if (DOWN == keyCode) {
        manipulatedParameter++;
        manipulatedParameter %= vars.size();
      } else if (RIGHT == keyCode) {
        addPressed();
      } else if (LEFT == keyCode) {
        subPressed();
      }
    }
    if ('h' == key ) {
      hide = !hide;
    } else if ('r' == key) {
      reset();
    }
  }

  void keyReleased() {
    if (key == CODED) {
      if (SHIFT == keyCode) {
        shiftPressed = false;
      }
    }
  }

  void reset() {
    for(PVariable pv : vars)
      pv.reset();
  }
  
  void addPressed() {
    if (shiftPressed)
      vars.get(manipulatedParameter).addSmallStep();
    else
      vars.get(manipulatedParameter).addStep();
  }

  void subPressed() {
    if (shiftPressed)
      vars.get(manipulatedParameter).subSmallStep();
    else
      vars.get(manipulatedParameter).subStep();
  }

  void renderHUD() {
    if (hide) return;
    noLights();
    textSize(20);
    int start = manipulatedParameter-2;
    if (start < 0) start += vars.size();
    for (int i = 0; i < 5; i++) {
      int idx = (start + i ) % vars.size();
      int xoffset = 40 - 10 * abs(i-2);
      PVariable pv = vars.get(idx);
      if (idx == manipulatedParameter) {
        fill(#FF0000);
        text(pv.toString() + " - " + pv.description, xoffset , 20 + 30 * i);
      } else {
        fill(#AAAAAA);
        text(pv.toString(), xoffset , 20 + 30 * i);
      }
    }
  }
}

interface Adjustable {
  void addStep();
  void subStep();
  void addSmallStep();
  void subSmallStep();
  void reset();
}

abstract class PVariable implements Adjustable {
  String name, description;

  PVariable() {}
  
  PVariable(String name, String description) {
    this.name = name;
    this.description = description;
  }

  String toString() {
    return "name: " + description;
  }

  float asFloat() {
    return 0.0;
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

  float asFloat() {
    return v;
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


