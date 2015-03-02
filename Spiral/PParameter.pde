// the Programmers Parameter settings

class PParameter {

  int manipulatedParameter = 0;
  ArrayList<PVariable> vars;
  boolean shiftPressed;
  boolean hide;
  PPsaver ppsaver;
  PPloader pploader;
  
  PParameter() {
    vars = new ArrayList<PVariable>();
    ppsaver = new PPsaver(this);
    pploader = new PPloader(this);
  }

  PVariable var(String cnf) {
//    "LambdaZ: z geometric progression [default:1.01] [step:0.1, 0.01] [range:0,2]"
    // why does java regexps taunt me?
    
    int name_sep = cnf.indexOf(':');
    String name = cnf;
    if (name_sep > 0) {
      name = cnf.substring(0, name_sep);
    } 

    PVariable pv = lookUp(name);
    if (pv != null)
      return pv;             // this is already parsed, or a duplicate made by mistake

    int cnf_sep = cnf.indexOf('[');
    String description = cnf.substring(name_sep + 1, cnf_sep).trim();
    String config = cnf.substring(cnf_sep).trim();

    HashMap<String, String> options = splitConfig(config);
    pv = getVariableFromConfig(options);
    pv.name = name;
    pv.description = description;
    pv.cnf = cnf;
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
  
  boolean keyPressed() {
    if (ppsaver.handleKey()) return true;
    if (pploader.handleKey()) return true;

    if (key == CODED) {
      if (hide) return false;         // do not manipulate what you can not see
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
      } else {
        return false;
      } 
    }
    if ('h' == key ) {
      hide = !hide;
    } else if ('r' == key) {
      reset();
    } else {
      return false;
    }
    return true;
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
    cam.beginHUD();
    noLights();
    textSize(20);
    int start = manipulatedParameter-2;
    if (start < 0) start += vars.size();

    for (int i = 0; i < min(5, vars.size()); i++) {

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
    ppsaver.render();
    pploader.render();
    cam.endHUD();
  }
}



