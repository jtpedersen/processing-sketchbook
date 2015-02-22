// the Programmers Parameter settings

class PParameter {

  int manipulatedParameter = 0;
  ArrayList<PVariable> vars;
  boolean shiftPressed;
  boolean hide;
  
  PParameter() {
    vars = new ArrayList<PVariable>();
  }

  void addVariable(String cnf) {
//    "LambdaZ: z geometric progression [default:1.01] [step:0.1, 0.01] [range:0,2]"
    // why does java regexps taunt me?
    
    int name_sep = cnf.indexOf(':');
    int cnf_sep = cnf.indexOf('[');
    String name = cnf.substring(0, name_sep);
    String description = cnf.substring(name_sep + 1, cnf_sep).trim();
    String config = cnf.substring(cnf_sep).trim();

    // println("name: " + name);
    // println("description: " + description);
    // println("config: " + config);

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
    vars.add(pv);
  }

  float readFloat(String name) {
    for (PVariable pv : vars) {
      if (pv.name.equals(name))
        return ((FloatVariable)pv).v;
    }
    return 0.0;
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
    }
  }

  void keyReleased() {
    if (key == CODED) {
      if (SHIFT == keyCode) {
        shiftPressed = false;
      }
    }
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
}

abstract class PVariable implements Adjustable {
  String name, description;
  PVariable(String name, String description) {
    this.name = name;
    this.description = description;
  }

  String toString() {
    return "name: " + description;
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
