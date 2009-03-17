
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
// FloatFract[] fracts = new FloatFract[3];  // left, right, and l->r morph versions
FloatFract fract; // = fracts[0];

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
FWSliderPool patternSliders;
IterationView fractView;

// create and wire the entire GUI...
void setup() {
  Ess.start(this);

  // drag-and-drop handler for file imports
  drop = new SDrop(this);

  size(800, 600);
  colorMode(HSB, 1);
  background(0);

  // the fractal model
  fract = new FloatFract();
  
  // setup UI
  controlP5 = new ControlP5(this);
  
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
  
  // bank of vertical pattern sliders that can work as a "draw" area
  patternSliders = new FWSliderPool(round(stepsSlider.value()), MAX_SLIDERS, LEFT_MARGIN, 50, width-200, 150);
  // set initial values for pattern sliders
  float[] vals = { 1, 0.5, 1 };
  for (int i = 0; i < patternSliders.size(); i++)
    patternSliders.slider(i).setValue(vals[i]);

  // fractal iteration viewer
  fractView = new IterationView(fract.getSegments(), 10, 0, height, width, -230);

  updateFractalSettings();
}

/**
  * controlP5 event callbacks
  */

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
  patternSliders.draw();
  drawPlayhead();
  
  // process any updates
  if(fract.iteration() < targetIteration) {
    fractView.draw();
    fract.iterate();
    fractView.setNextIteration(fract.getSegments());
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
    FloatFract newFract = new FloatFract(fileName);  
    // copy seed onto UI sliders
    stepsSlider.setValue(newFract.pattern().size());
    checkNumSliders();
    checkDuration();
    for(int i = 0; i < patternSliders.size(); i++) {
      patternSliders.slider(i).setValue(((Double)newFract.pattern().get(i)).floatValue());
    }
    updateFractalSettings();
    playAudio();
  }
}

void checkNumSliders() {
  if(patternSliders.size() != round(stepsSlider.value())) {
    stopAudio();    
    patternSliders.setSize((round(stepsSlider.value())));
    Runtime.getRuntime().gc(); 
  }
}  

void checkDuration() {
  if(curDuration != durationSlider.value()) {
    curDuration = durationSlider.value();
    if(targetIteration != calculateIterationBounds())
      waveDirty = true;
  }
}


void updateFractalSettings() {
  ArrayList newPattern = new ArrayList(patternSliders.size());
  for(int i = 0; i < patternSliders.size(); i++) {
    newPattern.add(new Double(patternSliders.slider(i).value()));
  }
  if(waveDirty || (!patternsSame(newPattern, fract.pattern()))) {
    targetIteration = calculateIterationBounds();
    fract.setPattern(newPattern); 
    fractView.reset(this);
    fractView.setNextIteration(newPattern);
    invalidateAudio();
    Runtime.getRuntime().gc(); 
    playAudio();
  }
}

int calculateIterationBounds() { 
  // numSliders^iteration = total samples
  float targetLength = durationSlider.value();
  float numIterations = log(SR*targetLength) / log(patternSliders.size());
  
  int targetIteration = ceil(numIterations); // favor longer clips
  // unless it would be too long
  if (pow(patternSliders.size(), targetIteration) >= SR*targetLength*4)
    targetIteration--;
    
  return targetIteration;
}


