class PPloader {
  PParameter pp;
  ArrayList<String> saves;

  int mode;
  static final int IDLE = 0,
    LISTING = 1;
  PPloader(PParameter pp) {
    this.pp = pp;
    mode = IDLE;
  }

  void init() {
    loadList();
  }

  void loadList() {
    mode = LISTING;
    File saveFolder = new File("saves");
    saves = new ArrayList<String>();
    for (File f : saveFolder.listFiles()) {
      saves.add(f.getName());
    }
  }

  boolean handleKey() {
    if (IDLE == mode) {
      if ('l' == key)  {
        init();
        return true;
      }
      return false;
    }
    int idx = key - 'a';
    // println("Got key: " +  key  + " and idx " + idx);
    if (idx >= 0 && idx < saves.size())
      loadFile(saves.get(idx));
    
    return true;
  }

  void loadFile(String filename) {
    println("loading: " + filename);
    pp.vars.clear();
    for(String cnf: loadStrings("./saves/" + filename)) {
      pp.var(cnf);
    }
    mode = IDLE;
  }


  void render() {
    if (IDLE == mode) return;
    textSize(20);
    fill(color(120, 200, 200, 200));
    rect(20, 200, width-40, height = 400);
    fill(#C0FFEE);
    int lineHeight = 20;
    int offset = 220;
    text("Available saves(press letter to load):", 20, 220);
    char letter = 'a';
    for(String f: saves) {
      offset += lineHeight;
      text(letter + ":\t" + f, 20, offset);
      letter++;
    }
  }


}
