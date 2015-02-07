import processing.dxf.*;

void setup() {
  size(800, 800, P3D);
  createLevels(5);
}
boolean record;


void keyPressed() {
  // Use a key press so that it doesn't make a million files
  if (key == 'r') {
  	record = true;
  }
}

void draw() {
  background(0);
  lights();

  if (record) {
    beginRaw(DXF, "output.dxf");
  } else {
    translate(width / 2, 3 * height / 4);
    rotateY(map(mouseX, 0, width, 0, PI));
    rotateZ(map(mouseY, 0, height, 0, -PI));
    rotateX(PI/2.0);
    fill(#AAAAAA);
    stroke(255,0,0);
    strokeWeight(.3);
    noStroke();
  }
  
  drawBase();
  for (int i = 0; i < levels.size(); i++) {
    drawLevel(i);
  }
  // Do all your drawing here
  if (record) {
    endRaw();
    record = false;
  }

}

ArrayList<KochLevel> levels = new ArrayList<KochLevel>();
void createLevels(int cnt) {
  levels.add(new KochLevel(0));
  levels.get(0).pts = base(3, 100);
  for (int j = 1; j < cnt; j++) {
    KochLevel kl = new KochLevel(j);
    ArrayList<PVector> base = new ArrayList<PVector>(levels.get(j-1).pts);
    PVector first = base.get(0);
    PVector prev = first;
    for (int i = 1; i < base.size(); i++) {
      PVector cur = base.get(i);
      kl.pts.addAll(Kochify(prev, cur));
      kl.below.addAll(belowKoch(prev, cur));
      prev = cur;
    }
    kl.pts.addAll(Kochify(prev, first));
    kl.below.addAll(belowKoch(prev, first));
    levels.add(kl);
  }
  offsetLayers();
  scaleLayers();
}

void offsetLayers() {
  float last = 0;
  for (int i = 1; i < levels.size(); i++) {
    KochLevel kl = levels.get(i);
    float cur = 107 * pow(2.0 * i, .626);;
    kl.offset(cur, last);
    last = cur;
  }
}

void scaleLayers() {
  float last = 1.0;
  for (int i = 1; i < levels.size(); i++) {
    KochLevel kl = levels.get(i);
    float cur =  .025 * i * i + 1.0 + .2 * i;
    kl.scaleXY(cur, last);
    last = cur;
  }

}

ArrayList<PVector> Kochify(PVector start, PVector end) {
  return Kochify(start, end, 1);
}
ArrayList<PVector> Kochify(PVector start, PVector end, int level) {
  ArrayList<PVector> res = new ArrayList<PVector>();
  if (level == 0) {
    res.add(start.get());
    res.add(end.get());
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

ArrayList<PVector> belowKoch(PVector start, PVector end) {
  //return a list of vertices with out pertubation on the middle point
  PVector dir = PVector.sub(end,start);
  float len = dir.mag();
  dir.normalize();

  PVector p1 = PVector.add(start, PVector.mult(dir, len / 3.0));
  PVector p2 = PVector.add(start, PVector.mult(dir, len / 2.0));
  PVector p3 = PVector.add(start, PVector.mult(dir, 2 * len / 3.0));

  ArrayList<PVector> res = new ArrayList<PVector>();
  res.addAll(Kochify(start, p1, 0));
  res.addAll(Kochify(p1, p2,  0));
  res.addAll(Kochify(p2, p3, 0));
  res.addAll(Kochify(p3, end, 0));
  
  return res;
}



ArrayList<PVector> removeRepeated(ArrayList<PVector> in) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  PVector first = in.get(0);
  PVector prev = first;
  for (int i = 1; i < in.size() - 1; i++) {
    PVector cur = in.get(i);
    if (cur != prev)
      out.add(cur);
    prev = cur;
  }
  prev = in.get(in.size()-1);
  if (prev != first)
    out.add(prev);
  return out;
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
  KochLevel kl = levels.get(i);
  kl.lines();
  kl.quadStrip();
}

void V(PVector v) {
  vertex(v.x, v.y, v.z);
}

class KochLevel {
  ArrayList<PVector> pts;
  ArrayList<PVector> below;
  int level;
  KochLevel(int level) {
    this.level = level;
    this.pts = new ArrayList<PVector>();
    this.below = new ArrayList<PVector>();
  }

  void dumpVerticies() {
    for(PVector p : pts) 
      V(p);
    V(pts.get(0));              
  }

  void lines() {
    beginShape(LINES);
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

  void offset(float z, float belowZ) {
    for (PVector p : pts)
      p.z = z;
    for (PVector p : below)
      p.z = belowZ;
  }

  void scaleXY(float s, float belowS) {
    for (PVector p : pts) {
      p.x *= s;
      p.y *= s;
    }
    for (PVector p : below) {
      p.x *= belowS;
      p.y *= belowS;
    }

  }


  
}
