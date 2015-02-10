import peasy.*;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 800);
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(1500);
  createLevels(6);
}

void keyPressed() {
  // Use a key press so that it doesn't make a million files

  if (key == 'o') {
    OBJ obj = new OBJ();
    for(KochLevel kl: levels)
      obj.merge(kl.obj());
    obj.save("hest.obj");
  }
}

void draw() {
  background(0);
  lights();
  translate(0,200, 0);
  rotateX(PI/2);

  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(1.3);
  // noStroke();
  
  drawBase();
  for (int i = 0; i < levels.size(); i++) {
    drawLevel(i);
  }

}

ArrayList<KochLevel> levels = new ArrayList<KochLevel>();
void createLevels(int cnt) {
  levels.add(new KochLevel(0));
  levels.get(0).pts = base(3, 100);
  for (int j = 1; j < cnt; j++) {
    KochLevel kl = new KochLevel(j);
    ArrayList<P4> base = new ArrayList<P4>(levels.get(j-1).pts);
    for (int i = 1; i < base.size(); i++) {
      P4 cur = base.get(i);
      kl.pts.addAll(Kochify(base.get(i-1), cur));
    }
    kl.pts.addAll(Kochify(base.get(base.size()-1), base.get(0)));
    levels.add(kl);
  }
  offsetLayers();
  scaleLayers();
}

void offsetLayers() {
  float last = 0;
  for (int i = 1; i < levels.size(); i++) {
    KochLevel kl = levels.get(i);
    float cur = 50 * pow(2.0 * i, .8626);;
    kl.offset(cur, last);
    last = cur;
  }
}

void scaleLayers() {
  float last = 1.0;
  for (int i = 1; i < levels.size(); i++) {
    KochLevel kl = levels.get(i);
    float cur =  .0125 * i * i + 1.0 + .2 * i;
    kl.scaleXY(cur, last);
    last = cur;
  }

}

ArrayList<P4> Kochify(P4 start, P4 end) {
  ArrayList<P4> res = new ArrayList<P4>();
  PVector dir = P4.sub(end,start);
  PVector up = new PVector(0.0,0.0,1.0);
  PVector right = dir.cross(up);
  float len = dir.mag();
  right.normalize();
  dir.normalize();

  PVector pstart = start.asPVector();
  PVector p1 = P4.add(pstart, PVector.mult(dir, len / 3.0));
  PVector p2 = P4.add(pstart, PVector.mult(dir, len / 2.0));
  PVector p3 = P4.add(pstart, PVector.mult(dir, 2 * len / 3.0));
  float h = sqrt((len/3.0)*(len/3.0) - (len/6.0)*(len/6.0));
  p2.add(P4.mult(right, h));

  float startU = start.u;
  float stepU = (start.u - end.u) / 4;
  res.add(start.get());
  res.add(new P4(p1, startU + stepU * 1.0));
  res.add(new P4(p2, startU + stepU * 2.0));
  res.add(new P4(p3, startU + stepU * 3.0));
  res.add(end.get());
   
  return res;
}


ArrayList<P4> removeRepeated(ArrayList<P4> in) {
  ArrayList<P4> out = new ArrayList<P4>();
  P4 first = in.get(0);
  P4 prev = first;
  for (int i = 1; i < in.size() - 1; i++) {
    P4 cur = in.get(i);
    if (cur != prev)
      out.add(cur);
    prev = cur;
  }
  prev = in.get(in.size()-1);
  if (prev != first)
    out.add(prev);
  return out;
}

ArrayList<P4> base(int cnt, float radius) {
  ArrayList<P4> corners = new ArrayList<P4>();
  for(int i = 0; i < cnt; i++) {
    float u = float(i) / float(cnt);
    float angle = (2 * PI * u);
    P4 p = new P4(cos(angle), sin(angle), 0.0, u);
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

// void V(P4 v) {
//   vertex(v.x, v.y, v.z, v.u);
// }


class P4 extends PVector {
  
  public float u;

  P4(float x, float y, float z, float u) {
    super(x,y,z);
    this.u = u;
  }
  
  P4(PVector pv, float u) {
    super(pv.x, pv.y, pv.z);
    this.u = u;
  }
  
  PVector asPVector() {
    return new PVector(x,y,z);
  }

  P4 get() {
    return new P4(x,y,z,u);
  }
}
