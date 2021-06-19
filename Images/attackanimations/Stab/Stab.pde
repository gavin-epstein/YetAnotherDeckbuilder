PGraphics image1;
float t=0;
int frame=0;
void setup(){
  size(1000,1000);

  image1 = createGraphics(width, height);
  
}
void draw(){
   background(0);
   image1.beginDraw();
   image1.clear();

   
   arrows(image1);
   image1.endDraw();
   image(image1,0,0,width, height);
   if (t<1){
      //image1.save(String.format("frame%03d.png",frame));
    }else{
      //t=0;
      exit();
    }
   
   t+=.05;
   frame++;
}

void arrows(PGraphics img){
  float gap =.04;
  for(float step = 0; step < 1; step+=(gap*2)){
    float x1 = width*(.3*t+.6*step*t+.05);
    float y1 = height*(.3*t+.6*step*t+.05); 
    float x2 = width*(.3*t+.6*(step+gap)*t+.05);
    float y2 = height*(.3*t+.6*(step+gap)*t+.05);
    img.fill(255,255,255,255);
    img.fill(255,255*(1-step),0,255*pow(sin(PI*t),.1));
    img.stroke(0,0,0,0);
    img.beginShape();
    img.vertex(x1,y1);
    img.vertex(x1-outline(step), y1);
    img.vertex(x2-outline(step+gap), y2);
    img.vertex(x2,y2);
    img.vertex(x2, y2-outline(step+gap));
    img.vertex(x1, y1-outline(step));
    img.endShape();
    
    
    
  }
  
  
}
float outline(float step){
  return .2*width*step;
}
