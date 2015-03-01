import peasy.*;

PeasyCam cam;
PParameter pp;

SnailMesh sm;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(500);
  pp = new PParameter();
  //sm = new SnailMesh();
}

void draw() {
  setTheScene();

  beginShape();
  vertex(10, 0, 0);
  vertex(0, 10, 0);
  vertex(0, 0, 0);
  vertex(10, 0, 0);
  endShape();
  
// sm.render();
}

void setTheScene() {
  background(0);
  lights();
  directionalLight(0, 255, 0, 0, -1, 0);
  directionalLight(255, 255, 0, 1, -1, 0);
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(1.3);
//  noStroke();
//  noFill();

}

void keyPressed() {
  if ('q' == key)
    exit();
  pp.keyPressed();
//  sm.createMesh();
}

void keyReleased() {
  pp.keyReleased();
}

