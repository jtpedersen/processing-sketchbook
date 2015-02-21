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
int manipulatedParameter = 0;
float smallChange = .001;
float largeChange = .01;
void keyPressed() {
  if ('q' == key)
    exit();

  if (key == CODED) {
    if (UP == keyCode)
      parms[manipulatedParameter] += largeChange;
    if (DOWN == keyCode)
      parms[manipulatedParameter] -= largeChange;
    if (RIGHT == keyCode)
      parms[manipulatedParameter] += smallChange;
    if (LEFT == keyCode)
      parms[manipulatedParameter] -= smallChange;
  }
  if (' ' == key) {
    manipulatedParameter++;
    manipulatedParameter %= parms.length;
  }
}


void draw() {
  background(0);

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
    String prefix = (i == manipulatedParameter) ? "->" : "  ";
    text(prefix + names[i] + ": " + parms[i], 10, 20 + 30 * i);
  }
  cam.endHUD();
}

