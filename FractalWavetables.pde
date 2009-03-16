
/**
 * Drag the mouse over the pattern sliders to create sound. 
 * Add or remove sliders via the "steps" control.
 * <br/><br/>Try setting the number of steps to an interesting metrical unit &#8212; say "8" &#8212; 
 * and use the pattern as a fractal step sequencer.
 * <br/><br/>If the UI freezes, try reloading the page. 
 * <br/><br/>If you like the sounds, you can download and run the app locally to save out files. 
 * <p><a href="http://www.raintone.com/code/processing/FractalWavetables/application.macosx.zip">Mac OS X version</a><br />
 * <a href="http://www.raintone.com/code/processing/FractalWavetables/application.windows.zip">Windows version</a><br />
 * <a href="http://www.raintone.com/code/processing/FractalWavetables/application.linux.zip">Linux version</a></p>
 * <a href="http://www.raintone.com/">Back to Raintone.com</a>
 * <br/></br>
 * <br/><br/>Thanks to Terran Olson's work on <a href="http://www.halfcadence.net/audio-fractals/">audio fractals</a> that inspired this sketch.
 * Thanks to Krister Olsson's <a href="http://www.tree-axis.com/Ess/">Ess library</a> for the sound support.
 * <br/><br/>
 */

// Fractal Wavetables
// March 2009
// jdn (at) raintone.com
//
// change history:
// v1 - basic algorithm and mono saving
// v2 - added drag-and-drop import of fw_xxxx.aif files
// v3 - code cleanup
// v4 - 
//
// 

import krister.Ess.*;  // nice simple sound library
import sojamo.drop.*;


/*
 * Model
 */

// Important constants
int SR = 44100;
int maxSliders = 80;
boolean canSave = true;  // set to true to run this locally and write files

// fractal data
FloatFract[] fracts = new FloatFract[3];  // left, right, and l->r morph versions
FloatFract fract = fracts[0];

// pattern size / timing data
int curNumSliders = 0;
float curTargetLength = 0;
int targetIteration = 0;

// audio system
AudioChannel mySound; 
boolean waveDirty = true;
boolean audioPlaying = true;

SDrop drop;  // for dropping saved files back into the program to load as "presets"

/*
 * Control
 */
 
void setup() {
  Ess.start(this);

  size(800, 600);
  colorMode(HSB, 1);
  background(0);
  
  drop = new SDrop(this);
  
  fract = new FloatFract();

  createGUI(); 
  updatePattern();
}


public void stop() {
  Ess.stop();
  super.stop();
}


public void draw() {
  drawGUI();
  
  // process any updates
  if(fract.iteration() < targetIteration) {
    fract.iterate();
  } 
  else if (waveDirty && audioPlaying) {
    stopAudio();
    writeAudio();
    playAudio();
  }  
}


void mousePressed() {
  if(canSave) {
    if(saveButton.pressed()) {
      doSave();
    }
  }
}


void mouseDragged() {
  if(numSlidersSlider.mouseOver()) {
    checkNumSliders();
  } else if (targetLengthSlider.mouseOver()) {
    drawTargetLengthIndicator();
  }
}


void mouseReleased() {
  checkNumSliders();
  checkTargetLength();
  updatePattern();
}


void dropEvent(DropEvent theDropEvent) {
  if(theDropEvent.isFile()) {
    // for further information see
    // http://java.sun.com/j2se/1.4.2/docs/api/java/io/File.html
    File myFile = theDropEvent.file();
    if(myFile.isFile()) {
      // attempt to parse filename
      String fileName = myFile.getName();
      doRestore(fileName);
    }
  }
}


/*
 * Control Helper Functions
 */ 

void doSave() {
  stopAudio();
  String defaultFilename = "fw_"+fract.toString();
  if(defaultFilename.length() > 250) {
    defaultFilename = defaultFilename.substring(0, 250);
  }
  defaultFilename += ".aif";
  
  String path = "" + defaultFilename;
  print("Save path: " + path + "\n");  
  writeSoundFile(path);
  
  playAudio();
}

void doRestore(String fileName) {
  if(fileName.endsWith(".aif") && fileName.startsWith("fw_")) {
    // looks OK-ish
    fileName = fileName.substring(3, fileName.length()-4);  // strip pre- and suffix
    //print("restoring seed:" + fileName);
    stopAudio();
    invalidateAudio();
    clearDisplay();
    FloatFract newFract = new FloatFract(fileName);  
    // copy seed onto UI sliders
    numSlidersSlider.setValue(newFract.pattern().size());
    checkNumSliders();
    checkTargetLength();
    for(int i = 0; i < curNumSliders; i++) {
      sliders[i].setValue(((Double)newFract.pattern().get(i)).floatValue());
    }
    updatePattern();
    drawSlidersIndicator();
    playAudio();
  }
}

void checkNumSliders() {
  if(curNumSliders != desiredNumSliders()) {
    stopAudio();    
    setupSliders(desiredNumSliders());
    Runtime.getRuntime().gc(); 
  }
}  

void checkTargetLength() {
  if(curTargetLength != targetLengthSlider.value()) {
    curTargetLength = targetLengthSlider.value();
    drawTargetLengthIndicator();
    if(targetIteration != calculateIterationBounds())
      waveDirty = true;
  }
}

int desiredNumSliders() {
  return numSlidersSlider.intValue();
}

void updatePattern() {
  ArrayList newPattern = new ArrayList(curNumSliders);
  for(int i = 0; i < curNumSliders; i++) {
    newPattern.add(new Double(sliders[i].value()));
  }
  if(waveDirty || (!patternsSame(newPattern, fract.pattern()))) {
    targetIteration = calculateIterationBounds();
    fract.setPattern(newPattern); 
    invalidateAudio();
    clearDisplay();
    Runtime.getRuntime().gc(); 
    playAudio();
  }
}

int calculateIterationBounds() { 
  // numSliders^iteration = total samples
  float targetLength = targetLengthSlider.value();
  float numIterations = log(SR*targetLength) / log(curNumSliders);
  
  int targetIteration = ceil(numIterations); // favor longer clips
  // unless it would be too long
  if (pow(curNumSliders, targetIteration) >= SR*targetLength*4)
    targetIteration--;
    
  return targetIteration;
}



