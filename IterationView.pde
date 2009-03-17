class IterationView {
  public int x, y, w, h;
  public int maxIterationsShown;
  public int curIteration;
  
  private static final int OVERSAMPLE = 32;

  public ArrayList segments;
  
  public IterationView(ArrayList initialSegments, int maxIterationsShown, int x, int y, int w, int h) {
    segments = initialSegments;
    curIteration = 0;
    this.maxIterationsShown = maxIterationsShown;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  public void setNextIteration(ArrayList segments) { 
    this.segments = segments; 
    this.curIteration++; 
  }
  
  public void draw() {
    if (segments == null) return;
    
    float yStep = h / maxIterationsShown;
    
    if (segments.size() < OVERSAMPLE*w && curIteration < maxIterationsShown) {
      int numSegments = segments.size();
      for(int i = 0; i < numSegments; i++) {
        Double curVal = (Double)segments.get(i);
        float curValIntensity = abs(curVal.floatValue());
        float belowZero = (curVal < 0.0 ? 1.0 : 0.0);
        color c = color(0.0, belowZero, curValIntensity);
        stroke(c);
        fill(c);
        rect(x+w*i/numSegments, y+curIteration*yStep, w/numSegments, (yStep*0.9));
      }  
    }
  }

  public void reset(PApplet theApplet) {
    curIteration = 0;
    segments = null;
    
    fill(0);
    stroke(0);
    rect(x, y, w, h);
  }
}