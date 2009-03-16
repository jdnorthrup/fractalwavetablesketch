class HSlider extends Slider {
  public HSlider() {
  }
  
  void setValue(float v) { this.value = v; } 
  float value() { return this.value; }
  int intValue() { return floor(this.value+0.5); }

  void draw() {
      if(mousePressed) {
        this.updatePosition();
      }
      
      float curValIntensity = this.percentValue();
      float belowZero = (this.value < 0.0 ? 1.0 : 0.0);
      color c = color(0.0, belowZero, max(0.1, curValIntensity));
      stroke(0.35); // dark outline
      fill(0.5);
      rect(this.x-1, this.y-1, this.w+2, this.h+2);  // border
      
      stroke(0.5, 0.8, 0.65);
      fill(0.5, 0.8, 0.65);
      rect(this.x + (this.w*this.percentValue()), this.y, 1.0, this.h); // tick mark
  }
  
  float percentValue() {
    return (this.value - this.minVal)/(this.maxVal - this.minVal);
  }
  
  void updatePosition() {
    // bounds
    int slop = 3;    
    if (mouseX >= this.x - slop && mouseX <= this.x + slop + this.w && mouseY >= this.y && mouseY <= this.y + this.h) {
      this.value = (mouseX - this.x)/this.w;
      this.value = min(1, max(0, this.value)); // limit
      this.value *= this.range;
      this.value += this.minVal;
    }
  }
}
