/*
 * Audio
 */

public void writeAudio() {
  ArrayList segments = fract.getSegments();
  int numSegments = segments.size();

  mySound = new AudioChannel();
  mySound.initChannel(numSegments);

  Double curVal;
/*
  // find peak to normalize audio
  double peak = 0.01;
  double dVal;
  for(int i = 0; i < numSegments; i++) {
    curVal = (Double)segments.get(i);
    dVal = curVal.doubleValue();
    if (dVal > peak)
      peak = dVal;
  }    
*/

  // grab sample values from the fractal
  float[] buffer = new float[numSegments];
  for(int i = 0; i < numSegments; i++) {
    curVal = (Double)segments.get(i);
    buffer[i] = curVal.floatValue(); // /(float)peak;
  }

  mySound.samples = buffer;  
  waveDirty = false;
}

public void writeSoundFile(String filename) {
   AudioFile myFile = new AudioFile();
   myFile.open(filename, (float)SR, Ess.WRITE);   
   myFile.write(mySound.samples);
   myFile.close();   
}

// sound buffer can be invalid, but the system
// is still trying to play. this basically says
// we need to regenerate the audio
public void invalidateAudio() {
  if (mySound != null)
    mySound.stop(); 
  waveDirty = true;
}  

void stopAudio() {
  if (mySound != null)
    mySound.stop();
  audioPlaying = false;
}

public void playAudio() {
  audioPlaying = true;
  
  if(waveDirty) return;
  
  if (mySound == null) {
    mySound = new AudioChannel();
  } 
  else { 
    mySound.stop();
  }

  mySound.play(Ess.FOREVER);
}


void drawPlayhead() {
  if (mySound != null) {
    fill(0);
    stroke(0);
    rect(0, height, width, -20);
    float phase = mySound.cue * 1.0 / mySound.size;
    stroke(0.25, 0.8, 1);
    line(width*phase, height, width*phase, height-19);
  }
}
