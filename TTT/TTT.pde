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
  ArrayList<PVector> pts = createSpiral();
  ArrayList<PVector> fwd = d1(pts);
  ArrayList<PVector> right = d1(fwd);
  ArrayList<PVector> up = cross(right, fwd);

  // drawVector(pts, fwd);
  // drawVector(pts, right);
  // drawVector(pts, up);

  float lcr = pp.var("lcr: growth rate circle [default:1.03] [step:0.01, 0.001]").asFloat();
  float r = 1.0;
  for(int i = 0; i < up.size(); i++) {
    PVector e1 = up.get(i); e1.normalize();
    PVector e2 = right.get(i); e2.normalize();
    drawCircle(pts.get(i), e1, e2, r);
    r *= lcr;

  }
  drawList(pts);
  pp.renderHUD(); 
}

ArrayList<PVector> createSpiral() {
  ArrayList<PVector> pts = new ArrayList<PVector>();

  float dTheta = pp.var("dThetha: angle growth [default:.3] [step:.1,0.01]").asFloat();
  float lamdaR = pp.var("lamdaR: radial growth rate [default:1.02] [step:.01,0.001]").asFloat();
  float lamdaZ = pp.var("lamdaZ: height growth rate [default:1.02] [step:.01,0.001]").asFloat();
  
  float theta = 0;
  float r = 1.0;
  float z = 1.0;
  for(int i =0; i < 100; i++) {
    pts.add(new PVector(r * cos(theta), r * sin(theta), z));
    theta += dTheta;
    r *= lamdaR;
    z *= lamdaZ;
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
  if (pp.keyPressed())
    return;
}

void keyReleased() {
  pp.keyReleased();
}

