import peasy.*;

PeasyCam cam;
Mesh mesh;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  mesh = new Mesh();
  mesh.seam = createSeamLine(new PVector(0,0,0), new PVector(50, 0, 0), 20);
}

float offset = 2.0;
void keyPressed() {
  if ('q' == key)
    exit();
  if ('z' == key)
    grow(new PVector(0,0,offset));
  if ('y' == key)
    grow(new PVector(0,offset,0));
  if ('x' == key)
    grow(new PVector(offset,0,0));
  if ('s' == key)
    offset *= -1.0;
  mesh.perturbSeam(.05);
}

void draw() {
  background(0);
  lights();
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(.3);
  // noStroke();
  mesh.render();
}

ArrayList<Integer> createSeamLine(PVector start, PVector end, int cnt) {
  PVector dir = PVector.sub(end, start);
  float d = dir.mag();
  dir.normalize();
  float step = d / (float) cnt;
  ArrayList<Integer> seamLine = new ArrayList<Integer>();
  for(int i = 0; i < cnt; i++) {
    PVector p = PVector.mult(dir, i * step);
    p.add(start);
    seamLine.add(mesh.addVertex(p));
  }
  return seamLine;
}

void grow(PVector dir) {
  ArrayList<Integer> newSeam = expandSeam(dir);
  mesh.sew(newSeam);
}

ArrayList<Integer> expandSeam(PVector dir) {
  ArrayList<Integer> expando = new ArrayList<Integer>();
  for(int i : mesh.seam) {
    PVector p = PVector.add(mesh.vertices.get(i), dir);
    expando.add(mesh.addVertex(p));
  }
  return expando;
}



