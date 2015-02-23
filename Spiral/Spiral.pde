import peasy.*;

PeasyCam cam;
Mesh mesh;
PParameter pp;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  pp = new PParameter();

  pp.var("lR: radius geometric progression [default:1.01] [step:0.01, 0.001] [range:0,2]");
  pp.var("lRc: generating curve radius geometric progression [default:1.01] [step:0.01, 0.001] [range:0,2]");
  pp.var("dTheta: theta step [default:.1] [step:.01,0.001]");
  createMesh();
}

void keyPressed() {
  if ('q' == key)
    exit();
  pp.keyPressed();
  createMesh();
}

void keyReleased() {
  pp.keyReleased();
}


void draw() {
  background(0);

  lights();
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(.3);
  noStroke();
//  noFill();

  mesh.render();

  cam.beginHUD();
  pp.renderHUD();
  cam.endHUD();
}


void createMesh() {
  mesh = new Mesh();

  ArrayList<PVector> pts = createSpiral();
  ArrayList<PVector> w = d1(pts);
  ArrayList<PVector> v = d1(w);
  ArrayList<PVector> u = cross(w,v);
  
  float r = 1.0;
  float lRc = pp.readFloat("lRc");
  for(int i = 0; i < u.size(); i++) {
    // the coordinate system
    PVector e1 = u.get(i);
    PVector e2 = v.get(i);
    e1.normalize();
    e2.normalize();
    PVector origo = pts.get(i);
    ArrayList<PVector> curve = generateCircle(origo, e1, e2, r);
    mesh.addCurve(curve);
    r *= lRc;
  }
}

ArrayList<PVector> createSpiral() {
  float theta = 0;
  float r = 1;
  float z = 1;
  float lR = pp.readFloat("lR");
  float lZ = pp.var("lZ: z geometric progression [default:1.01] [step:0.001, 0.0001] [range:0,2]").asFloat();
  float dTheta = pp.readFloat("dTheta");

  ArrayList<PVector> res = new ArrayList<PVector>();
  float tSteps = pp.var("tSteps: number of iterations [default:200.0] [step:10, 1]").asFloat(); //todo use asInt or better yet those newfangled generics
  for(int t = 0; t < tSteps; t++) {
    res.add(new PVector(r * cos(theta), r*sin(theta), z));
    r *= lR;
    z *= lZ;
    theta += dTheta;
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
  float steps = pp.var("circleSteps: granularity of generating circle [default:12.0] [range:3, 1000000] [step:1.0, 10]]").asFloat();
  float dTheta = TAU / (steps);
  for (int i = 0; i <= steps; i++) {
    float theta = i * dTheta;
    PVector p = PVector.add(PVector.mult(e1, r * cos(theta)), PVector.mult(e2, r * sin(theta)));
    p.add(origo);
    pts.add(p);
  }
  return pts;
}
