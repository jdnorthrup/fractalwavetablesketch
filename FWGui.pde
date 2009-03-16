/*
 * GUI / Redraw
 */

// a bit ugly because we allocate a static pool of sliders
// and recycle these to avoid memory issues
Slider[] sliders;

HSlider numSlidersSlider;
HSlider targetLengthSlider;

Button saveButton;
PFont myFont;


float leftOffset = 100;

  
void createGUI() {
  myFont = loadFont("Verdana-12.vlw");
  textFont(myFont);  

  numSlidersSlider = new HSlider();
  numSlidersSlider.setSize(leftOffset, 245, width-200, 10);
  numSlidersSlider.setRange(2, maxSliders);
  numSlidersSlider.setValue(3);

  // pre-allocate pool of pattern sliders
  sliders = new Slider[maxSliders];
  for (int i = 0; i < maxSliders; i++) {
    sliders[i] = new Slider();
    sliders[i].setRange(-1, 1);
  }

  targetLengthSlider = new HSlider();
  targetLengthSlider.setSize(leftOffset, 275, width-200, 10);
  targetLengthSlider.setRange(0.25, 30);
  targetLengthSlider.setValue(4.0);
  curTargetLength = 4.0;
  drawTargetLengthIndicator();

  setupSliders(desiredNumSliders());

  // set initial values for pattern
  float[] vals = { 1, 0.5, 1 };
  for (int i = 0; i < curNumSliders; i++)
    sliders[i].setValue(vals[i]);

  if(canSave) {
    // save button
    saveButton = new Button();
    saveButton.x = width-93;
    saveButton.w = 80;
    saveButton.y = 309;
    saveButton.h = 20;
    saveButton.basecolor = color(0.5);
    saveButton.highlightcolor = color(0.75);
    saveButton.label = "Save Audio";
    saveButton.draw();
  }
  drawLabels();  
}


void setupSliders(int numSliders) {    
  float sliderWidth = (width-200.0)/numSliders;
  int i;
  for(i = 0; i < numSliders; i++) {
    sliders[i].setSize(leftOffset+i*sliderWidth, 50, sliderWidth, 150);
    sliders[i].setValue(0);
  }
  
  // clear remaining
  for(i = i; i < sliders.length; i++) {
    sliders[i].setValue(0);
  }

  curNumSliders = numSliders;
  drawSlidersIndicator();  
}

void drawLabels() {
  fill(1);
  text("steps", leftOffset-47, 255);
  text("duration", leftOffset-63, 285);
  text("pattern", leftOffset-57, 129);
  text("1", (leftOffset + width-200)+10, 60);
  text("0", (leftOffset + width-200)+10, 129);
  text("-1", (leftOffset + width-200)+8, 200);
}


// obviously need to write/use a UI framework :)
void drawSlidersIndicator() {
  fill(0);
  stroke(0);
  rect((leftOffset +width-200)+5, 255, 25, -25);
  fill(1);
  text(curNumSliders, (leftOffset +width-200)+10, 255);
}

void drawTargetLengthIndicator() {
  fill(0);
  stroke(0);
  rect((leftOffset +width-200)+5, 285, 200, -25);
  fill(1);
  String targetLengthSeconds = "" + targetLengthSlider.value();
  if (targetLengthSeconds.length() > 4)
    targetLengthSeconds = targetLengthSeconds.substring(0,4);
  text("" + targetLengthSeconds + " seconds", (leftOffset +width-200)+10, 285);  
}


int yStep = 23;
int maxIterationsShown = 10;

void drawGUI() {
  // allow UI elements to draw
  if (canSave) {
    saveButton.update();
    saveButton.draw();
  }
  targetLengthSlider.draw();
  numSlidersSlider.draw();
  for(int i = 0; i < curNumSliders; i++)
    sliders[i].draw();  

  // draw fractal visualization
  int iteration = fract.iteration();  
  if (fract.getSegments().size() < 32*width && iteration < maxIterationsShown) {
    ArrayList segments = fract.getSegments();
    int numSegments = segments.size();
    for(int i = 0; i < numSegments; i++) {
      Double curVal = (Double)segments.get(i);
      float curValIntensity = abs(curVal.floatValue());
      float belowZero = (curVal < 0.0 ? 1.0 : 0.0);
      color c = color(0.0, belowZero, curValIntensity);
      stroke(c);
      fill(c);
      rect(width*i/numSegments, height - 21 - iteration*yStep, width/numSegments, -(yStep-2));
    }  
  }

  // draw "playhead"
  if (mySound != null) {
    fill(0);
    stroke(0);
    rect(0, height, width, -20);
    float phase = mySound.cue * 1.0 / mySound.size;
    stroke(0.25, 0.8, 1);
    line(width*phase, height, width*phase, height-19);
  }

}

void clearDisplay() {
  fill(0);
  stroke(0);
  rect(0, height - 21, width, -yStep*maxIterationsShown);
}

