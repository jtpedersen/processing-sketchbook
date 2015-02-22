import peasy.*;

PeasyCam cam;
Mesh mesh;


void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  createMesh();
}

float [] parms = { 1.01, 1.01, .1 , 1.01};
String[] names = { "lambdaR",  "lambdaZ",  "dTheta", "lamdaR_Generating"};
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
    createMesh();
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
  strokeWeight(.3);
  // noStroke();
//  noFill();

  mesh.render();

  cam.beginHUD();
  noLights();
  textSize(20);
  for (int i = 0; i < parms.length; i++) {
    String prefix = (i == manipulatedParameter) ? "->" : "  ";
    text(prefix + names[i] + ": " + parms[i], 10, 20 + 30 * i);
  }
  cam.endHUD();
}


void createMesh() {
  mesh = new Mesh();

  ArrayList<PVector> pts = createSpiral();
  ArrayList<PVector> w = d1(pts);
  ArrayList<PVector> v = d1(w);
  ArrayList<PVector> u = cross(w,v);
  
  float r = 1.0;
  for(int i = 0; i < u.size(); i++) {
    // the coordinate system
    PVector e1 = u.get(i);
    PVector e2 = v.get(i);
    e1.normalize();
    e2.normalize();
    PVector origo = pts.get(i);
    ArrayList<PVector> curve = generateCircle(origo, e1, e2, r);
    mesh.addCurve(curve);
    r *= parms[3];
  }
}

ArrayList<PVector> createSpiral() {
  float theta = 0;
  float r = 1;
  float z = 1;

  ArrayList<PVector> res = new ArrayList<PVector>();
  for(int t = 0; t < 200; t++) {
    res.add(new PVector(r * cos(theta), r*sin(theta), z));
    r *= parms[0];
    z *= parms[1];
    theta += parms[2];
  }
  return res;
}

ArrayList<PVector> d1(ArrayList<PVector> pts) {
  ArrayList<PVector> res = new ArrayList<PVector>();
  for(int i = 0; i < pts.size()-1; i++) {
    PVector delta = PVector.sub(pts.get(i+1), pts.get(i));
    res.add(delta);
  }
  return res;
}

ArrayList<PVector> cross(ArrayList<PVector> pts1, ArrayList<PVector> pts2) {
  int l = min(pts1.size(), pts2.size());
  ArrayList<PVector> res = new ArrayList<PVector>();
  for (int i =0; i < l; i++) {
    PVector c = pts1.get(i).cross(pts2.get(i));
    res.add(c);
  }
  return res;
}


ArrayList<PVector> generateCircle(PVector origo, PVector e1, PVector e2, float r) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  int steps = 12;
  float dTheta = TAU / float(steps-1);
  for (int i = 0; i < steps; i++) {
    float theta = i * dTheta;
    PVector p = PVector.add(PVector.mult(e1, r * cos(theta)), PVector.mult(e2, r * sin(theta)));
    p.add(origo);
    pts.add(p);
  }
  return pts;
}
