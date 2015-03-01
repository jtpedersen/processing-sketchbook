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
  sm = new SnailMesh();
}

void keyPressed() {
  if ('q' == key)
    exit();
  pp.keyPressed();
  sm.createMesh();
}

void keyReleased() {
  pp.keyReleased();
}

void draw() {
  background(0);

  lights();
  directionalLight(0, 255, 0, 0, -1, 0);
  directionalLight(255, 255, 0, 1, -1, 0);
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(.3);
  noStroke();
//  noFill();

  sm.render();

  cam.beginHUD();
  pp.renderHUD();
  cam.endHUD();
}


