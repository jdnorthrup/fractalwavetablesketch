class FWSlider {
  float x, y;
  float w, h;
  float value;
  float minVal;
  float maxVal;
  
  float range;
  
  boolean logarithmic;
  
  FWSliderPool parent;
  
  public FWSlider(FWSliderPool parent) {
    this.parent = parent;
  }
  
  void setRange(float minVal, float maxVal) {
    this.minVal = minVal;
    this.maxVal = maxVal;
    this.range = maxVal - minVal;
  }
  
  void setSize(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void setValue(float v) { this.value = v; } 
  float value() { return this.value; }
  
  // not implemented
  void setLogarithmic() { this.logarithmic = true; }
  
  void draw() {
      if(parent.lock && mousePressed) {
        this.updatePosition();
      }
      
      float curValIntensity = abs(this.value);
      float belowZero = (this.value < 0.0 ? 1.0 : 0.0);
      color c = color(0.0, belowZero, curValIntensity);
      stroke(0.35); // dark outline
      fill(c);
      rect(this.x-1, this.y-1, this.w+2, this.h+2);  // border
      
      stroke(0.25);
      line(this.x, this.y+this.h/2.0, this.x+this.w, this.y+this.h/2.0); // middle detent
      
      stroke(0.5, 0.8, 0.65);
      fill(0.5, 0.8, 0.65);
      rect(this.x, this.y + (this.h*(this.maxVal - this.value)/(this.maxVal - this.minVal)), this.w, 1.0); // tick mark
  }
  
  boolean mouseOver() {
    // bounds
    int slop = 3;
    if (mouseX >= this.x && mouseX <= this.x + this.w && mouseY >= this.y - slop && mouseY <= this.y + this.h + slop) {
      return true;
    } else {
      return false;
    }    
  }
  
  void updatePosition() {
    // bounds
    int slop = 3;
    if (this.mouseOver()) {
      this.value = ((this.y + this.h) - mouseY)/this.h;
      this.value = min(1, max(0, this.value)); // limit
      this.value *= this.range;
      this.value += this.minVal;
    }
  }
}
