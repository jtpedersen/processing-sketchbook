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
  ArrayList<PVector> d1 = d1(pts);
  ArrayList<PVector> d2 = d1(d1);
  ArrayList<PVector> up = cross(d2, d1);

  
  // drawVector(pts, d1);
  // drawVector(pts, d2);
  // drawVector(pts, up);
  
  drawList(pts);

  float cr = pp.var("cr: circle radius progression [default:1.0] [step:.1, 0.01]").asFloat();
  float r = 1.0;
  for(int i = 0; i < up.size(); i++) {
    PVector e1 = up.get(i);
    PVector e2 = d2.get(i);
    e1.normalize(); e2.normalize();

    drawCircle(pts.get(i), e1, e2, r);
    r *= cr;
  }

  pp.renderHUD(); 
}

ArrayList<PVector> createSpiral() {
  ArrayList<PVector> pts = new ArrayList<PVector>();

  float dTheta = pp.var("dTheta: delta angle [default:0.2] [step:0.1,0.01]").asFloat();;
  float lambdaR = pp.var("lambdaR: change of radius [default:1.05] [step:0.1,0.01]").asFloat();
  float lambdaZ = pp.var("lambdaZ: change of height [default:1.05] [step:0.1,0.01]").asFloat();

  float theta = 0;
  float r = 1.0;
  float z = 1.0;
  
  for(int i = 0; i < 100; i++) {
    pts.add(new PVector(r * cos(theta),r * sin(theta), z));
    theta  += dTheta;
    r *= lambdaR;
    z *= lambdaZ;
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

