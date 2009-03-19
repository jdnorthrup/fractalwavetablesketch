class FWSliderPool {
  protected FWSlider[] sliders;
  protected int size;
  
  boolean lock; // for click tracking
  
  boolean visible;
  
  public int x, y;
  public int w, h;

  public FWSliderPool(int numSliders, int maxSliders, int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    this.visible = true;
    this.lock = false;
    
    // pre-allocate pool of pattern sliders
    sliders = new FWSlider[maxSliders];
    for (int i = 0; i < maxSliders; i++) {
      sliders[i] = new FWSlider(this);
      sliders[i].setRange(-1, 1);
    }
    
    setSize(numSliders);
  }

  public FWSlider slider(int index) {
    return sliders[index];
  }

  public void mousePressed() {
    if(this.mouseOver())
      this.lock = true;
  }
  
  public void mouseReleased() {
    this.lock = false;
  }
  
  public void hide() { this.visible = false; }
  public void show() { this.visible = true; }

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

  public void setHeight(int h) {
    this.h = h;
    for(int i = 0; i < size; i++) {
      sliders[i].h = h;
    }    
  }
  
  public void draw() {
    if(!this.visible)
      return;
      
    fill(0);
    stroke(0);
    rect(x, y, w, h);
    
    for(int i = 0; i < size; i++)
      sliders[i].draw();      
  }
  
  
  public boolean mouseOver() {
    // bounds
    int slop = 3;
    if (mouseX >= this.x && mouseX <= this.x + this.w && mouseY >= this.y - slop && mouseY <= this.y + this.h + slop) {
      return true;
    } else {
      return false;
    }    
  }
  
}

