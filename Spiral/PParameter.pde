// the Programmers Parameter settings

class PParameter {

  float [] parms = { 1.01, 1.01, .1 , 1.01};
  String[] names = { "lambdaR",  "lambdaZ",  "dTheta", "lamdaR_Generating"};
  int manipulatedParameter = 0;
  float smallChange = .001;
  float largeChange = .01;

  void keyPressed() {
    if (key == CODED) {
      if (UP == keyCode)
        parms[manipulatedParameter] += largeChange;
      if (DOWN == keyCode)
        parms[manipulatedParameter] -= largeChange;
      if (RIGHT == keyCode)
        parms[manipulatedParameter] += smallChange;
      if (LEFT == keyCode)
        parms[manipulatedParameter] -= smallChange;
      createMesh();
    }
    if (' ' == key) {
      manipulatedParameter++;
      manipulatedParameter %= parms.length;
    }

  }

  void renderHUD() {
    noLights();
    textSize(20);
    for (int i = 0; i < parms.length; i++) {
      String prefix = (i == manipulatedParameter) ? "->" : "  ";
      text(prefix + names[i] + ": " + parms[i], 10, 20 + 30 * i);
    }

  }
  
}
