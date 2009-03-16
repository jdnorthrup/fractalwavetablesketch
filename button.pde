class Button
{
  int x, y, w, h;
  color basecolor, highlightcolor;
  color currentcolor;
  boolean over = false;
  boolean pressed = false;   
  String label;

  void update() 
  {
    if(over()) {
      currentcolor = highlightcolor;
    } 
    else {
      currentcolor = basecolor;
    }
  }

  boolean pressed() 
  {
    if(over()) {
      return true;
    } 
    else {
      return false;
    }    
  }

  boolean over() 
  { 
     if (mouseX >= x && mouseX <= x+w && 
       mouseY >= y && mouseY <= y+h) {
       return true;
     } 
     else {
       return false;
     }
  }
  
  void draw() 
   {
     stroke(0.25);
     fill(currentcolor);
     rect(x, y, w, h);
     fill(0);
     text(label, x+8, y+h-5);     
   }

}
