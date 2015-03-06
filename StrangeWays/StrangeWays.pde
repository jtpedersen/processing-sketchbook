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
  for(int i = 0; i < 10000; i++) {
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
  
  boolean gotOne = false;
  while (!gotOne) {
    restart();
    warmup(1000);
    determine_bb();
    if (hasNAN(pos)) {
      println("w00000000000000t");
    }

    float vol = volume();
    float md = maxDim();
    println("Candidate volume: " + vol + " with a maxdDim of " + md);
    if (vol > 10.0 || vol < 1.0) {
      println("wrong size: " + vol);
      continue;
    } else {
      gotOne = true;
      println("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    }
    // if (10e10 * md < 1.0) {
    //   println("wrong md: " + md);
    //   continue;
    // } else {
    //   gotOne = true;
    //   println("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    // }
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

void warmup(int n) {
  PVector tmp = new PVector();
  for(int i =0; i < n; i++) {
    step();
    if (hasNAN(pos)) {
      println("restart because of NAN");
      restart();
      i = 0;
    }
  }
}
boolean hasNAN(PVector p) {
  return Float.isNaN(p.x) || Float.isNaN(p.y) || Float.isNaN(p.z);
}


PVector bbmin = new PVector();
PVector bbmax = new PVector();
void determine_bb() {
  bbmin = pos.get();
  bbmax = pos.get();
  for(int i =0; i< 1000; i++) {
    step();
    bbmin.x = min(pos.x, bbmin.x);
    bbmin.y = min(pos.y, bbmin.y);
    bbmin.z = min(pos.z, bbmin.z);
    bbmax.x = max(pos.x, bbmax.x);
    bbmax.y = max(pos.y, bbmax.y);
    bbmax.z = max(pos.z, bbmax.z);
  }
  //println(bbmin + " -> " + bbmax + ": Volume" + volume());
}

float volume() {
  return (bbmax.x - bbmin.x) * (bbmax.y - bbmin.y) * (bbmax.z - bbmin.z);
}

float maxDim() {
  return max( (bbmax.x - bbmin.x), max( (bbmax.y - bbmin.y),  (bbmax.z - bbmin.z)));
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
  stroke(120, 255,0,39);
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


