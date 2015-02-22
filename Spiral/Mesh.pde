class Mesh {
  ArrayList<PVector> vertices;
  ArrayList<PVector> faces;
  ArrayList<Integer> seam;
  
  Mesh() {
    vertices = new ArrayList<PVector>();
    faces = new ArrayList<PVector>();
    seam = new ArrayList<Integer>();
  }
  void render() {
    // println("Render " + faces.size() + " faces using " + vertices.size() + " vertices");
    beginShape(TRIANGLES);
    for(PVector face : faces) {
      drawTriangle(face);
    }
    endShape();
  }
  void drawTriangle(PVector face) {
    // println(face.y + ", " + face.x + ", " + face.z);
    V(vertices.get((int)face.x));
    V(vertices.get((int)face.y));
    V(vertices.get((int)face.z));
  }
  void V(PVector v) {
    vertex(v.x, v.y, v.z);
  }

  int addVertex(PVector v) {
    int ret = vertices.size();
    vertices.add(v);
    return ret;
  }

  void perturbSeam(float s) {
    for(int i : seam) {
      PVector p = PVector.random3D();
      p.mult(s);
      PVector ps = vertices.get(i);
      ps.add(p);
    }
  }

  void sew(ArrayList<Integer> newSeam) {
    if (seam.size() == 0) {
      seam = newSeam;
      return;
    }

    if (newSeam.size() != seam.size()) {
      print("AAARGH");
    }

    for(int i = 1; i < seam.size(); i++) {
      mesh.faces.add(new PVector(seam.get(i-1), seam.get(i), newSeam.get(i-1)));
      mesh.faces.add(new PVector(newSeam.get(i-1), seam.get(i), newSeam.get(i)));
    }
    mesh.seam = newSeam;
  }

  void addCurve(ArrayList<PVector> newCurve) {
    ArrayList<Integer> newSeam = new ArrayList<Integer>();
    for(PVector p: newCurve) {
      newSeam.add(addVertex(p));
    }
    sew(newSeam);
  }


}



