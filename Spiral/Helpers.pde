

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
