void drawList(ArrayList<PVector> pts) {
  beginShape();
  for(PVector p : pts)
    vertex(p.x, p.y, p.z);
  endShape();
}

void drawVector(ArrayList<PVector> pts, ArrayList<PVector> vs) {
  beginShape(LINES);
  stroke(#C0FFEE);
  for (int i = 0; i< vs.size(); i+=5){
    PVector p = pts.get(i);
    PVector v = vs.get(i);
//    v.normalize();
    v.mult(5.0);
    vertex(p.x, p.y, p.z);
    vertex(p.x + v.x, p.y + v.y, p.z + v.z);
  }
  endShape();
}

void drawCircle(PVector O,PVector e1, PVector e2, float r) {
  int cs = 5; //pp.var("cs: steps in circle [default:10] [step:10, 1] [range:3,10000]").asInt();
  float dTheta = TAU / (cs);
  beginShape();
  for (int i = 0; i <= cs; i++) {
    float theta = i * dTheta;
    PVector u = PVector.mult(e1, r * cos(theta));
    PVector v = PVector.mult(e2, r * sin(theta));
    PVector p = PVector.add(u,v);
    vertex(O.x + p.x, O.y + p.y, O.z + p.z);
  }
  endShape();
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
