
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
// v4 - switched to controlP5 library for most of GUI.
//      refactored code -- FWAudio could become class
//
// 

import krister.Ess.*;  // nice simple sound library
import sojamo.drop.*;
import controlP5.*;  // holy shit this library rocks


/*
 * Model
 */

// Important constants
final int SR = 44100;
final int MAX_SLIDERS = 80;
final int LEFT_MARGIN = 100;

// fractal data
final int NUM_PATTERNS = 2;
FloatFract[] fract = new FloatFract[NUM_PATTERNS];  // to support stereo or morphing
int numPatternsActive = 1;


// pattern size / timing data
float curDuration = 0;
int targetIteration = 0;

// audio system
AudioChannel mySound; 
boolean waveDirty = true;
boolean audioPlaying = true;

/*
 * Control
 */

SDrop drop;  // for dropping saved files back into the program to load as "presets"
  
public ControlP5 controlP5;
Slider stepsSlider;
Slider durationSlider;
FWSliderPool[] patternSliders = new FWSliderPool[2];
IterationView[] fractView = new IterationView[2];

// create and wire the entire GUI...
void setup() {
  Ess.start(this);

  // drag-and-drop handler for file imports
  drop = new SDrop(this);

  size(800, 600);
  colorMode(HSB, 1);
  background(0);
  
  // setup UI controller
  controlP5 = new ControlP5(this);
  
  // mode buttons
  int buttonWidth = 80;
  int buttonHeight = 20;
  int buttonY = 14;
  controlP5.addButton("mono",1,LEFT_MARGIN,buttonY,buttonWidth,buttonHeight);
  controlP5.addButton("stereo",1,LEFT_MARGIN+buttonWidth+10,buttonY,buttonWidth,buttonHeight);
  controlP5.addButton("morph",1,LEFT_MARGIN+2*(buttonWidth+10),buttonY,buttonWidth,buttonHeight);
  controlP5.addButton("swap",1,LEFT_MARGIN+3*(buttonWidth+10),buttonY,buttonWidth,buttonHeight);
  
  
  // horizontal sliders
  stepsSlider = controlP5.addSlider("steps",2,MAX_SLIDERS,3,LEFT_MARGIN,245,width-200,10);
  stepsSlider.setLabel("");
  durationSlider = controlP5.addSlider("duration",0.25,30,4.0,LEFT_MARGIN,275,width-200,10); 
  durationSlider.setLabel("seconds");
  durationSlider.setDecimalPrecision(2);  
  
  // labels
  controlP5.addTextlabel("patternLabel", "pattern", LEFT_MARGIN-43, 121);
  controlP5.addTextlabel("stepsLabel", "steps", LEFT_MARGIN-33, 246);
  controlP5.addTextlabel("durationLabel", "duration", LEFT_MARGIN-47, 276);
  
  controlP5.addTextlabel("1", "1", (LEFT_MARGIN + width-200)+10, 50);
  controlP5.addTextlabel("0", "0", (LEFT_MARGIN + width-200)+10, 123);
  controlP5.addTextlabel("-1", "-1", (LEFT_MARGIN + width-200)+8, 193);

  // save button -- only if we're running as an application
  if(!online) {
    controlP5.Button saveButton = controlP5.addButton("save",1,width-99,309,80,20);
    saveButton.setLabel("Save Audio");
  }

  // loop through to create the pattern-specific bits of the system
  // since for stereo and morphs we need multiples of all of this
  for(int i=0; i < NUM_PATTERNS; i++) {
    // the fractal model
    fract[i] = new FloatFract();

    // bank of vertical pattern sliders that can work as a "draw" area
    patternSliders[i] = new FWSliderPool(round(stepsSlider.value()), MAX_SLIDERS, LEFT_MARGIN, 50+(i*150/NUM_PATTERNS), width-200, 150/NUM_PATTERNS);
    // set initial values for pattern sliders
    float[] vals = { 1, 0.5, 1 };
    for (int j = 0; j < patternSliders[i].size(); j++)
      patternSliders[i].slider(j).setValue(vals[j]);

    // fractal iteration viewer
    fractView[i] = new IterationView(fract[i].getSegments(), 10, 0, height-(i*230/NUM_PATTERNS), width, -230/NUM_PATTERNS);
  }
  updateFractalSettings();
}

/**
  * controlP5 event callbacks
  */

public void mono(float val) {
  numPatternsActive = 1;
}

public void stereo(float val) {
  numPatternsActive = 2;
}

public void morph(float val) {
  numPatternsActive = 2;
}

public void swap(float val) {
}


public void steps(float val) {
  stepsSlider.setValueLabel(""+round(val));
  checkNumSliders();
}

public void duration(float val) {
  // this will get polled in mouseReleased()
}

public void save(float val) {
  doSave();
}


/**
  * applet events
  */

public void stop() {
  Ess.stop();
  super.stop();
}


public void draw() {
  for(int p = 0; p < numPatternsActive; p++)
    patternSliders[p].draw();

  drawPlayhead();
  
  // process any updates
  if(fract[0].iteration() < targetIteration) {
    for(int p = 0; p < numPatternsActive; p++) {
      fractView[p].draw();
      fract[p].iterate();
      fractView[p].setNextIteration(fract[p].getSegments());
    }
  } 
  else if (waveDirty && audioPlaying) {
    stopAudio();
    writeAudio();
    playAudio();
  }  
}


void mouseReleased() {
  checkNumSliders();
  checkDuration();
  updateFractalSettings();
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
 * Control Functions
 */ 

void doSave() {
  stopAudio();
  //XXX need stereo saving scheme
  String defaultFilename = "fw_"+fract[0].toString();
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
    FloatFract[] newFract = new FloatFract[2];
    for(int p = 0; p < numPatternsActive; p++) {
      newFract[p] = new FloatFract(fileName); //XXX fix this
      // copy seed onto UI sliders
      stepsSlider.setValue(newFract[p].pattern().size());
    }
    checkNumSliders();
    checkDuration();
    for(int p = 0; p < numPatternsActive; p++) {
      for(int i = 0; i < patternSliders[p].size(); i++) {
        patternSliders[p].slider(i).setValue(((Double)newFract[p].pattern().get(i)).floatValue());
      }
    }
    updateFractalSettings();
    playAudio();
  }
}

void checkNumSliders() {
  if(patternSliders[0].size() != round(stepsSlider.value())) {
    stopAudio();    
    for(int p = 0; p < numPatternsActive; p++)
      patternSliders[p].setSize((round(stepsSlider.value())));
    Runtime.getRuntime().gc(); 
  }
}  

void checkDuration() {
  if(curDuration != durationSlider.value()) {
    curDuration = durationSlider.value();
    if(targetIteration != calculateIterationBounds(0))
      waveDirty = true;
  }
}


void updateFractalSettings() {
  boolean updated = false;
  for(int p = 0; p < numPatternsActive; p++) {
    ArrayList newPattern = new ArrayList(patternSliders[p].size());
    for(int i = 0; i < patternSliders[p].size(); i++) {
      newPattern.add(new Double(patternSliders[p].slider(i).value()));
    }
    if(waveDirty || (!patternsSame(newPattern, fract[p].pattern()))) {
      targetIteration = calculateIterationBounds(p);
      fract[p].setPattern(newPattern); 
      fractView[p].reset(this);
      fractView[p].setNextIteration(newPattern);
    }
  }
  
  if(updated) {
    invalidateAudio();
    Runtime.getRuntime().gc(); 
    playAudio();    
  }
}

int calculateIterationBounds(int p) { 
  // numSliders^iteration = total samples
  float targetLength = durationSlider.value();
  float numIterations = log(SR*targetLength) / log(patternSliders[p].size());
  
  int targetIteration = ceil(numIterations); // favor longer clips
  // unless it would be too long
  if (pow(patternSliders[p].size(), targetIteration) >= SR*targetLength*4)
    targetIteration--;
    
  return targetIteration;
}


