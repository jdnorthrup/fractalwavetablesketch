public class FWAudio {
 
  public AudioChannel[] buffers = new AudioChannel[2];
  public boolean waveDirty = false;
  public boolean audioPlaying = false;
  public boolean looping = true;
 
  public FWAudio() {
  }
  
  public void writeStereoAudio(ArrayList l, ArrayList r) {
    writeAudio(l, 0);
    writeAudio(r, 1);
    buffers[0].pan(Ess.LEFT);
    buffers[1].pan(Ess.RIGHT);
  }
  
  public void writeAudio(ArrayList samples, int bufferNumber) {
    int numSamples = samples.size();

    AudioChannel mySound = buffers[bufferNumber] = new AudioChannel();    
    mySound.initChannel(numSamples);

    Double curVal;
  /*
    // find peak to normalize audio
    double peak = 0.01;
    double dVal;
    for(int i = 0; i < numSamples; i++) {
      curVal = (Double)samples.get(i);
      dVal = curVal.doubleValue();
      if (dVal > peak)
        peak = dVal;
    }    
  */

    // grab sample values from the fractal
    float[] buffer = new float[numSamples];
    for(int i = 0; i < numSamples; i++) {
      curVal = (Double)samples.get(i);
      buffer[i] = curVal.floatValue(); // /(float)peak;
    }

    mySound.samples = buffer;
    mySound.pan(0);
    waveDirty = false;
  }

  public void writeSoundFile(String filename, int bufferNumber) {
     AudioFile myFile = new AudioFile();
     myFile.open(filename, (float)SR, Ess.WRITE);   
     myFile.write(buffers[bufferNumber].samples);
     myFile.close();   
  }

  // sound buffer can be invalid, but the system
  // is still trying to play. this basically says
  // we need to regenerate the audio
  public void invalidateAudio() {
    stopBuffers();
    buffers[0] = buffers[1] = null;
    waveDirty = true;
  }  

  public void stopAudio() {
    stopBuffers();
    audioPlaying = false;
  }

  public void playAudio() {
    audioPlaying = true;
  
    if(waveDirty) return;
  
    for(int i = 0; i < buffers.length; i++) {
      if (buffers[i] != null) {
        buffers[i].stop();
        buffers[i].play(looping ? Ess.FOREVER : 1); 
      }
    }
  }

  public void setLooping(boolean v) {
    if((v && !looping) || (!v && looping)) {
      this.looping = v;
      stopBuffers();
      playAudio();
    }
  }

  public void setMute(boolean v) {
    for(int i = 0; i < buffers.length; i++) {
      if (buffers[i] != null) {
        buffers[i].mute(v);
      }
    }
  }

  public void drawPlayhead() {
    for(int i = 0; i < buffers.length; i++) {
      if (buffers[i] != null) {
        fill(0);
        stroke(0);
        rect(0, height, width, -20);
        float phase = buffers[i].cue * 1.0 / buffers[i].size;
        stroke(0.25, 0.8, 1);
        line(width*phase, height, width*phase, height-19);
      }
    }
  }
  
  private void stopBuffers() {
    for(int i = 0; i < buffers.length; i++) {
      if (buffers[i] != null)
        buffers[i].stop(); 
    }    
  }
  
}