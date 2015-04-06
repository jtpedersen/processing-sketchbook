import peasy.*;

PeasyCam cam;
PParameter pp;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(500);
  pp = new PParameter();
}

void draw() {
  setTheScene();
  ArrayList<PVector> pts = new ArrayList<PVector>();
  
  drawList(pts);
  pp.renderHUD(); 
}

void setTheScene() {
  background(0);
  lights();
  directionalLight(0, 255, 0, 0, -1, 0);
  directionalLight(255, 255, 0, 1, -1, 0);
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(3.3);
//  noStroke();
  noFill();

}

void keyPressed() {
  if ('q' == key)
    exit();
  if (pp.keyPressed())
    return;
}

void keyReleased() {
  pp.keyReleased();
}

