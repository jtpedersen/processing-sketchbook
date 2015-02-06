void setup() {
  size(800, 800, P3D);
  createLevels(6);
}

void draw() {
  background(0);
 
  lights();
  translate(width / 2, height / 2);
  rotateY(map(mouseX, 0, width, 0, PI));
  rotateZ(map(mouseY, 0, height, 0, -PI));
  fill(#AAAAAA);
  stroke(255,0,0);
  strokeWeight(3);
  translate(0, -40, 0);
  drawBase();
  for (int i = 1; i < levels.size(); i++) {
    drawLevel(i);
  }
}

ArrayList<KochLevel> levels = new ArrayList<KochLevel>();
void createLevels(int cnt) {
  ArrayList<PVector> corners = base(3, 100);
  levels.add(new KochLevel(0, corners));
  for (int j = 1; j < cnt; j++) {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    ArrayList<PVector> base = new ArrayList<PVector>(levels.get(j-1).pts);
    PVector first = base.get(0);
    PVector prev = first;
    for (int i = 1; i < base.size(); i++) {
      PVector cur = base.get(i);
      pts.addAll(Kochify(prev, cur, 1));
      prev = cur;
    }
    pts.addAll(Kochify(prev, first, 1));
    levels.add(new KochLevel(j, pts));
  }
}

ArrayList<PVector> Kochify(PVector start, PVector end, int level) {
  ArrayList<PVector> res = new ArrayList<PVector>();
  if (level == 0) {
    res.add(start);
    res.add(end);
    return res;
  }
  PVector dir = PVector.sub(end,start);
  PVector up = new PVector(0,0,1);
  PVector right = dir.cross(up);
  float len = dir.mag();
  right.normalize();
  dir.normalize();

  PVector p1 = PVector.add(start, PVector.mult(dir, len / 3.0));
  PVector p2 = PVector.add(start, PVector.mult(dir, len / 2.0));
  PVector p3 = PVector.add(start, PVector.mult(dir, 2 * len / 3.0));
  float h = sqrt((len/3.0)*(len/3.0) - (len/6.0)*(len/6.0));
  p2.add(PVector.mult(right, h));

  res.addAll(Kochify(start, p1, level-1));
  res.addAll(Kochify(p1, p2, level-1));
  res.addAll(Kochify(p2, p3, level-1));
  res.addAll(Kochify(p3, end, level-1));
  
  return res;
}

ArrayList<PVector> base(int cnt, float radius) {
  ArrayList<PVector> corners = new ArrayList<PVector>();
  for(int i = 0; i < cnt; i++) {
    float angle = (2 * PI * i) / float(cnt);
    PVector p = new PVector(cos(angle), sin(angle), 0.0);
    p.mult(radius);
    corners.add(p);
  }
  return corners;
}

void drawBase() {
  beginShape(TRIANGLE_FAN);
  V(new PVector(0,0,0));
  levels.get(0).dumpVerticies();
  endShape();
}

void drawLevel(int i) {
  pushMatrix();
  translate(0,0,i*50);
  beginShape(LINES);
  levels.get(i).dumpVerticies();
  endShape();
  popMatrix();

}

void V(PVector v) {
  vertex(v.x, v.y, v.z);
}

class KochLevel {
  ArrayList<PVector> pts;
  int level;
  KochLevel(int level, ArrayList<PVector> pts) {
    this.level = level;
    this.pts = pts;
  }

  void dumpVerticies() {
    for(PVector p : pts) 
      V(p);
    V(pts.get(0));
  }


}
