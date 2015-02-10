class KochLevel {
  ArrayList<P4> pts;
  ArrayList<P4> below;
  int level;
  KochLevel(int level) {
    this.level = level;
    this.pts = new ArrayList<P4>();
    this.below = new ArrayList<P4>();
  }

  void dumpVerticies() {
    for(P4 p : pts) 
      V(p);
    V(pts.get(0));
  }

  void lines() {
    beginShape();
    dumpVerticies();
    endShape();
  }
  void quadStrip() {
    if (below.isEmpty())
      return;
    beginShape(QUAD_STRIP);
    for(int i = 0; i < below.size(); i++) {
      V(pts.get(i));
      V(below.get(i));
    }
    V(pts.get(0));
    V(below.get(0));

    endShape();
  }

  OBJ obj() {
    OBJ obj = new OBJ();
    if (below.isEmpty())
      return obj;
    
    obj.vertices.addAll(pts);
    obj.vertices.addAll(below);
    
    int cnt = pts.size();
    if (cnt != below.size()) println("AAAAAAAArgh");

    for(int i = 0; i < cnt; i++) {
      if (i < cnt -1) {
        // bottom
        //    |\
        //    |_\
        obj.faces.add(new PVector(i, cnt + i, cnt + i + 1));
        // top
        //    \-|
        //     \|
        obj.faces.add(new PVector(i, cnt + i + 1, i + 1));
      }
    }
    return obj;
  }

  void offset(float z, float belowZ) {
    for (P4 p : pts)
      p.z = z;
    for (P4 p : below)
      p.z = belowZ;
  }

  void scaleXY(float s, float belowS) {
    for (P4 p : pts) {
      p.x *= s;
      p.y *= s;
    }
    for (P4 p : below) {
      p.x *= belowS;
      p.y *= belowS;
    }

  }
}
