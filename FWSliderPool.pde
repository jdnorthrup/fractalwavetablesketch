class FWSliderPool {
  protected FWSlider[] sliders;
  protected int size;
  
  public int x, y;
  public int w, h;

  public FWSliderPool(int numSliders, int maxSliders, int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    // pre-allocate pool of pattern sliders
    sliders = new FWSlider[maxSliders];
    for (int i = 0; i < maxSliders; i++) {
      sliders[i] = new FWSlider();
      sliders[i].setRange(-1, 1);
    }
    
    setSize(numSliders);
  }

  public FWSlider slider(int index) {
    return sliders[index];
  }

  public int size() { return size; }

  public void setSize(int size) {    
    this.size = size;
    float sliderWidth = w*1.0/size;
    int i;
    for(i = 0; i < size; i++) {
      sliders[i].setSize(x+i*sliderWidth, y, sliderWidth, h);
      sliders[i].setValue(0);
    }
  
    // clear remaining
    for(i = i; i < sliders.length; i++) {
      sliders[i].setValue(0);
    }
  }
  
  public void draw() {
    fill(0);
    stroke(0);
    rect(x, y, w, h);
    
    for(int i = 0; i < size; i++)
      sliders[i].draw();      
  }

}

