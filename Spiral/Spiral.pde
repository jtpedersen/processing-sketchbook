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
  setTheScene(); // sm.render();

  ArrayList<PVector> pts = createSpiral();
  ArrayList<PVector> tangents = d1(pts);
  ArrayList<PVector> rights = d1(tangents);
  ArrayList<PVector> ups = cross(rights, tangents);
  
  // drawList(pts);
  // drawVector(pts, tangents);
  // drawVector(pts, rights);
  // drawVector(pts, ups);
  float cr = 1.0;
  float cTheta = 0;

  float lcr = pp.var("lcr: circle progression [default:1.01] [step:.1,.01]").asFloat();

  for (int i = 0; i<ups.size(); i++){
    PVector p = pts.get(i);
    PVector up = ups.get(i);
    PVector right = rights.get(i);
    up.normalize();
    right.normalize();
    drawCircle(p, up, right, cr);
    cr *= lcr;
  }


  
  pp.renderHUD(); 
}

ArrayList<PVector> createSpiral() {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  float r = 1.0;
  float theta = 0.0;
  float z = 1.0;
  float dTheta = pp.var("dTheta: angular step [default:.1] [step:.1, .01]").asFloat();
  float lR = pp.var("lR: radial progression [default:1.01] [step:.01, .001]").asFloat();
  float steps = pp.var("steps: number of steps [default: 100] [step:10, 1]").asInt();
  float lZ = pp.var("lZ: stepness of helico spiral [default:1.01] [step:.01, .001]").asFloat();

  for (int i = 0; i<steps; i++){
    pts.add(new PVector(r * cos(theta), r * sin(theta), z));
    theta += dTheta;
    r *= lR;
    z *= lZ;
  }
  return pts;
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
  pp.keyPressed();
//  sm.createMesh();
}

void keyReleased() {
  pp.keyReleased();
}

