import peasy.*;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(400);
  strange_init();
}

void draw() {
  setTheScene();

  beginShape();
  for(int i = 0; i < 1000; i++) {
    vertex(100.0 * pos.x, 100.0 * pos.y, 100.0 * pos.z);
    // print(pos);
    step();
  }
  endShape();
}

PVector pos;
float[] x_coeffs = new float[10];
float[] y_coeffs = new float[10];
float[] z_coeffs = new float[10];

void strange_init() {

  restart();
  // out of bounds
  float bbox = 2;
  for(int i =0; i< 100; i++) {
    step();
    if (pos.x > bbox || pos.y > bbox || pos.z > bbox ||
      pos.x < -bbox || pos.y < -bbox || pos.z < -bbox) {
      println("far out" + pos);
      restart();
      i = 0;
    }

  }

  // fixpoint
  PVector tmp = pos.get();
  step();

  if (tmp.dist(pos) < .01) {
    println("fixpoint");
    strange_init();
  }
  
  
  
}

void restart() {
  pos = new PVector(random(-1,1), random(-1,1), random(-1,1));
  for(int i = 0; i < 10; i++) {
    x_coeffs[i] = random(-1.2, 1.2);
    y_coeffs[i] = random(-1.2, 1.2);
    z_coeffs[i] = random(-1.2, 1.2);
  }
  // printArray(x_coeffs);
  // printArray(y_coeffs);
  // printArray(z_coeffs);
}

void step() {
  PVector next = new PVector();
  next.x = quad_iterate(pos, x_coeffs);
  next.y = quad_iterate(pos, y_coeffs);
  next.z = quad_iterate(pos, z_coeffs);
  pos = next;
}

float quad_iterate(PVector p, float[] a) {
  float res = 0;
  res += a[0];

  res += a[1]*p.x;
  res += a[2]*p.y;
  res += a[3]*p.z;

  res += a[4]*p.x*p.x;
  res += a[5]*p.y*p.y;
  res += a[6]*p.z*p.z;

  res += a[7]*p.x*p.y;
  res += a[8]*p.x*p.z;
  res += a[9]*p.y*p.z;

  return res;
}


void setTheScene() {
  background(0);
  lights();
  fill(#AAAAAA);
  stroke(255,0,39);
  strokeWeight(0.3);
  // noStroke();
  noFill();

}

void keyPressed() {
  if ('q' == key)
    exit();
  if ('r' == key)
    strange_init();
}


