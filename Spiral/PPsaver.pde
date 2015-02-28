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

  void keyPressed() {
    if (IDLE == mode) return;

    if ('\b'== key){
        filename = filename.substring(0, max(filename.length()-1, 0));
    } else if ('\n' == key) {
      saveFile();
    } else {
      filename += key;
    }
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
}
