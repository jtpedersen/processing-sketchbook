import peasy.*;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
}

float [] parms = { 1.01, 1.01, .1 };
String[] names = { "lambdaR",  "lambdaZ",  "dTheta"};
int manipulatedParaemeter = -1;

void keyPressed() {
  if ('q' == key)
    exit();
  if ('a' == key)
    manipulatedParaemeter = manipulatedParaemeter < 0 ? 0 : -1;
}


void mousePressed() {
  if (manipulatedParaemeter < 0)
    return;
  manipulatedParaemeter++;
  manipulatedParaemeter %= parms.length;
}


void draw() {
  background(0);
  float fine = map(mouseX, 0.0, float(width), 0.0, 0.1);
  float coarse = map(mouseY, 0.0, float(height), 0.0, 2.0);
  if (manipulatedParaemeter >= 0) {
    parms[manipulatedParaemeter] = fine + coarse;
  }

  lights();
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(3);
  // noStroke();
  noFill();

  float theta = 0;
  float r = 10;
  float z = 10;


  beginShape();
  for(int t = 0; t < 200; t++) {
    vertex(r * cos(theta), r*sin(theta), z);
    r *= parms[0];
    z *= parms[1];
    theta += parms[2];
  }
  endShape();
  

  cam.beginHUD();
  noLights();
  textSize(20);
  for (int i = 0; i < parms.length; i++) {
    text(names[i] + ": " + parms[i], 10, 20 + 30 * i);
  }
  cam.endHUD();
}

