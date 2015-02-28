class PPsaver {

  // handles keyboard
  // saves files in default dir, ./saves
  // The filename is the descriptions
  
  PParameter pp;
// processing do not like enums
  static final int IDLE    = 0,
                   READING = 1,
                   SAVING  = 2;
  int mode = IDLE;
  String filename;
  
  PPsaver(PParameter pp) {
    this.pp = pp;
    mode = IDLE;
  }

  void init() {
    mode = READING;
    filename = "";
  }

  boolean handleKey() {
    if (IDLE == mode) {
      if ('s' == key)  {
        init();
        return true;
      }

      return false;
    }



    if ('\b'== key) {
        filename = filename.substring(0, max(filename.length()-1, 0));
    } else if ('\n' == key) {
      saveFile();
    } else {
      filename += key;
    }
    return true;
 }

  void saveFile() {
    mode = SAVING;
    println("Trying to save: " + filename);
    PrintWriter pw = createWriter("saves/" + filename + ".sav");
    for(PVariable pv : pp.vars) {
	    pw.write(pv.saveString() + "\n");
    }
    pw.close();
    mode = IDLE;
  }

  void render() {
    if (IDLE == mode) return;
    textSize(20);
    fill(#AAAAAA);
    rect(20, 200, 300, 150);
    fill(#C0FFEE);
    text("Save file to path:", 60, 250);
    text("./saves/" + filename + ".sav", 60, 300);
  }

}
