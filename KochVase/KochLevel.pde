import java.util.*;

KochLevel lastLevel() {
  return levels.get(levels.size()-1);
}

PVector query(float z, float u) {
  // find level
  KochLevel high= lastLevel();
  for(int i = levels.size() - 2; i > 0  ; i--) { // have chosen a start value and we want to be less than equal than the highest
    if ( levels.get(i).getHeight() > z)
      break;
    high = levels.get(i);
  }

  // find u
  PVector highPoint = high.lerp2U(u);
  PVector lowPoint = levels.get(high.level - 1).lerp2U(u);
  float w = (highPoint.z - z) / (highPoint.z - lowPoint.z);
  return lowPoint;
  // return PVector.lerp(lowPoint, highPoint, w);
}

void renderMesh() {
  float ustep = 1.0 / lastLevel().getHeight();
  for (int i = levels.size() - 1; i > 0 ; i-- ) {
    float lowZ = levels.get(i-1).getHeight();
    float highZ = levels.get(i).getHeight();
    beginShape(QUAD_STRIP);
    for (float u = 0; u <= 1.0 ; u += ustep) {
      V(query(lowZ, u));
      V(query(highZ, u));
    }
    endShape();
  }
}


class KochLevel {
  ArrayList<P4> pts;
  int level;
  KochLevel(int level) {
    this.level = level;
    this.pts = new ArrayList<P4>();
  }

  float getHeight() {
    return pts.get(0).z;
  }
  
  void dumpVerticies() {
    for(P4 p : pts) 
      V(p);
    V(pts.get(0));
  }

  PVector lerp2U(float u) {
    int best = 0;
    for(int i = 1; i < pts.size(); i++) {
      if (pts.get(best).u > u)
        break;
      best = i;
    }
    int next = best +1;
    if (next == pts.size())
      next = 0;
    P4 low = pts.get(best);
    P4 high = pts.get(next);
    float w = (high.u - u) / (high.u - low.u);
    // return PVector.lerp(low.asPVector(), high.asPVector(), w);
    return low.asPVector();
  }
  
  void lines() {
    beginShape();
    dumpVerticies();
    endShape();
  }

  void offset(float z) {
    for (P4 p : pts)
      p.z = z;
  }

  void scaleXY(float s) {
    for (P4 p : pts) {
      p.x *= s;
      p.y *= s;
    }
  }
}
