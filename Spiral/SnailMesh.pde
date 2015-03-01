class SnailMesh {
  Mesh mesh;

  SnailMesh() {
    createMesh();
  }

  void render() {
    mesh.render();
  }
  
  void createMesh() {
    mesh = new Mesh();

    ArrayList<PVector> pts = createSpiral();
    ArrayList<PVector> w = d1(pts);
    ArrayList<PVector> v = d1(w);
    ArrayList<PVector> u = cross(w,v);
  
    float r = 1.0;
    float phase = 0;
    float lRc = pp.var("lRc: generating curve radius geometric progression [default:1.01] [step:0.01, 0.001] [range:0,2]").asFloat();
    float dPhi = pp.var("dPhi: rotation of coordinate frame [default:0.0] ").asFloat();
    float tRFreg = pp.var("tRfreq: frequency of radius defomation along time axis [default:10]").asFloat();
    float tAmplitude = pp.var("tAmplitude: amplitude of time based radius deformaion [default: .1]").asFloat();
  
    for(int i = 0; i < u.size(); i++) {
      // the coordinate system
      PVector e1 = u.get(i);
      PVector e2 = v.get(i);
      e1.normalize();
      e2.normalize();
      float modifiedR = r  + r * tAmplitude * cos(tRFreg * i);
      PVector origo = pts.get(i);
      ArrayList<PVector> curve = generateCircle(origo, e1, e2, modifiedR, phase);

      mesh.addCurve(curve);
      r *= lRc;
      phase += dPhi;
    }
  }

  ArrayList<PVector> createSpiral() {
    float theta = 0;
    float r = 1;
    float z = 1;

    float dTheta = pp.var("dTheta: theta step [default:.1] [step:.01,0.001]").asFloat();
    float lR = pp.var("lR: radius geometric progression [default:1.01] [step:0.01, 0.001] [range:0,2]").asFloat();
    float lZ = pp.var("lZ: z geometric progression [default:1.01] [step:0.001, 0.0001] [range:0,2]").asFloat();

    ArrayList<PVector> res = new ArrayList<PVector>();
    float tSteps = pp.var("tSteps: number of iterations [default:200.0] [step:10, 1]").asFloat(); //todo use asInt or better yet those newfangled generics
    for(int t = 0; t < tSteps; t++) {
      res.add(new PVector(r * cos(theta), r*sin(theta), z));
      r *= lR;
      z *= lZ;
      theta += dTheta;
    }
    return res;
  }
  ArrayList<PVector> generateCircle(PVector origo, PVector e1, PVector e2, float r, float phase) {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    int steps = pp.var("circleSteps: granularity of generating circle [default:12.0] [range:3, 1000000] [step:1.0, 10]]").asInt();
    float amplitude = pp.var("amplitude: cosine defomation of circle [default:0.1] ").asFloat();
    int freq = pp.var("frequency: cosine defomation of circle [default:1.0] [step:1,10]").asInt();
    float dTheta = TAU / (steps);
    for (int i = 0; i <= steps; i++) {
      float theta = i * dTheta;
      float dr = r + r * amplitude * cos(theta * freq);
      PVector p = PVector.add(PVector.mult(e1, dr * cos(phase + theta)), PVector.mult(e2, dr * sin(phase + theta)));
      p.add(origo);
      pts.add(p);
    }
    return pts;
  }
}
