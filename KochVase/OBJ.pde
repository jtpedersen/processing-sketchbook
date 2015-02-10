class OBJ {
  ArrayList<PVector> vertices;
  ArrayList<PVector> faces;
  OBJ() {
      vertices = new ArrayList<PVector>();
      faces = new ArrayList<PVector>();
  }

  void merge(OBJ other) {
    int cnt = vertices.size();
    vertices.addAll(other.vertices);
    for(PVector f : other.faces) {
      f.x += cnt; f.y += cnt; f.z += cnt;
    }
    faces.addAll(other.faces);
  }

  void save(String filename) {
    PrintWriter out = createWriter(filename);
    for(PVector v: vertices) {
      v.mult(1000.0);
      out.write("v " + v.x + " " + v.y + " " + v.z + "\n");
      v.mult(1.0 / 1000.0);
    }
    for(PVector f: faces) {
      // offset by one
      out.write("f " + (int)(1 + f.x) + " " + (int)(1 + f.y) + " " + (int)(1 + f.z) + "\n");
    }
    out.flush();
    out.close();
  }
  
}
