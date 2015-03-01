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
