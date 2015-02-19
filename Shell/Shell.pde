import peasy.*;

PeasyCam cam;

Mesh mesh;

ArrayList<Integer> seam;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  mesh = new Mesh();
  seam = createSeamLine(new PVector(0,0,0), new PVector(50, 0, 0), 10);
}

void keyPressed() {
  if ('q' == key)
    exit();
  if ('z' == key)
    grow(new PVector(0,0,10));
  if ('y' == key)
    grow(new PVector(0,10,0));
  if ('x' == key)
    grow(new PVector(10,0,0));
}

void draw() {
  background(0);
  lights();
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(1.3);
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
    seamLine.add(mesh.vertices.size());
    mesh.vertices.add(p);
  }
  return seamLine;
}

void grow(PVector dir) {
  ArrayList<Integer> newSeam = expandSeam(dir);
  sew(newSeam);
  seam = newSeam;
}

ArrayList<Integer> expandSeam(PVector dir) {
  ArrayList<Integer> expando = new ArrayList<Integer>();
  for(int i : seam) {
    expando.add(mesh.vertices.size());
    mesh.vertices.add(PVector.add(mesh.vertices.get(i), dir));
  }
  return expando;
}

void sew(ArrayList<Integer> newSeam) {
  if (newSeam.size() != seam.size()) {
    print("AAARGH");
  }

  for(int i = 1; i < seam.size(); i++) {
    mesh.faces.add(new PVector(seam.get(i-1), seam.get(i), newSeam.get(i-1)));
    mesh.faces.add(new PVector(newSeam.get(i-1), seam.get(i), newSeam.get(i)));
  }

}
