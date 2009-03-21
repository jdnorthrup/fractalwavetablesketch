// Generalization of the Cantor Set.  
//
// Uses an array of real-valued coefficients as a "pattern" to recursively
// sub-divide.  
//
class FloatFract {
  ArrayList pattern;
  ArrayList morphPattern;
  ArrayList segments;
  int iteration;

  public FloatFract() {
    pattern = new ArrayList();     
    reset();
  }

  // way to reconstruct a fractal from serialized string as given by toString() method
  public FloatFract(String s) {
    pattern = new ArrayList();     
    reset();
    for(int i = 0; i < s.length()/2; i++) {
      String hex = s.substring(2*i, 2*i+2);
      int intValue = Integer.parseInt(hex, 16);
      double floatValue = (intValue/255.0)*2.0-1.0;
      pattern.add(new Double(floatValue));
    }
  }

  void reset() {
    iteration = 0;
    segments = new ArrayList();
    segments.add(new Double(1.0));
  }

  void setPattern(ArrayList c) { 
    reset(); 
    pattern = c; 
  }  
  
  void setMorphPattern(ArrayList m) {
    morphPattern = m;
  }

  ArrayList pattern() { return this.pattern; }
  
  ArrayList getSegments() { 
    return segments; 
  }

  void iterate() {
    if (morphPattern != null) {
      iterateMorph();
      return;
    }
      
    ArrayList newSegments = new ArrayList();
    for(int i = 0; i < segments.size(); i++) {
      Double oldVal = (Double)segments.get(i);
      for(int j = 0; j < pattern.size(); j++) {
        newSegments.add((Double)pattern.get(j) * oldVal);
      }
    }
    segments = newSegments;    
    iteration++;
  }

  void iterateMorph() {
    ArrayList newSegments = new ArrayList();
    double phase = 0;
    double delta = 1.0/((segments.size())*(pattern.size())-1.0);
    double lerpedWeight = 0.0;
    for(int i = 0; i < segments.size(); i++) {
      Double oldVal = (Double)segments.get(i);
      for(int j = 0; j < pattern.size(); j++) {
        Double patternVal = (Double)pattern.get(j);
        Double morphPatternVal = (Double)morphPattern.get(j);
        lerpedWeight = (1.0-phase)*(patternVal) + (phase)*(morphPatternVal);
        newSegments.add(lerpedWeight * oldVal);
        phase += delta;
      }
    }
    segments = newSegments;    
    iteration++;
  }


  int iteration() { 
    return iteration; 
  }
  
  int sizeAfterNthIteration(int n) {
    return round(pow(pattern.size(), n));
  }
  
  // writes seed out to string.  
  // each element in the pattern is represented as two chars hexidecimal.
  String toString() {
    String name = "";
    String hex = "";
    for(int i = 0; i < pattern.size(); i++) {
      Double v = (Double)pattern.get(i);
      Integer intVal = floor((float)(255*(v+1.0)/2.0));
      hex = Integer.toHexString(intVal);
      if(hex.length() < 2) {
        hex = "0" + hex;
      } else if (hex.length() > 2) {
        hex = "ff";
      }
      name += hex; 
    }
    return name;
  }
}


boolean patternsSame(ArrayList a, ArrayList b) {
   if(a.size() != b.size()) return false;   
   for(int i = 0; i < a.size(); i++) {
     if(((Double)a.get(i)).doubleValue() != ((Double)b.get(i)).doubleValue()) return false;
   }

   return true;
}

