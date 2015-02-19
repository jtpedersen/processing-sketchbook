class Mesh {
  ArrayList<PVector> vertices;
  ArrayList<PVector> faces;
  Mesh() {
    vertices = new ArrayList<PVector>();
    faces = new ArrayList<PVector>();
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

}



