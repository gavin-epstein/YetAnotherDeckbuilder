PGraphics image1;
float t=0;
int frame=0;
void setup(){
  size(500,500);
  colorMode(HSB,255);
  image1 = createGraphics(width, height);
  image1.colorMode(HSB,255);
}
void draw(){
   background(0);
   image1.beginDraw();
   image1.clear();

   
   needle(image1);
   backlash2(image1);
   image1.endDraw();
   image(image1,0,0,width, height);
   if (t<1){
      image1.save(String.format("frame%03d.png",frame));
    }else{
      //t=0;
      exit();
    }
   
   t+=.05;
   frame++;
}
void needle(PGraphics img){
  for (float step = 1; step>=0; step-=.01){
    img.fill(color(136,255*(1-step), 255-200*step));
    img.stroke(0,0,0,0);
    dart(img, .02*step);
  }
  
}
void backlash(PGraphics img) { 
  float x2 = width*(.8*t+.2);
  for(float step = 0; step<1; step+=.02){
    float x3 = width*step;
    float x4 = width*(step+.01);
    float pass = max(0,7*(x2-x3)/width);
    float size = max(0, width*pass*(1-pass));//*(1+.2*sin(100*step));
    if (x3>.85*width && size > 0){
      
      /*//img.fill(255);
      img.beginShape();
      img.vertex(x3,x3);
      img.vertex(x3-size,x3);
      img.vertex(x4, x4);
      img.endShape();
      img.beginShape();
      img.vertex(x3,x3);
      img.vertex(x3,x3-size);
      img.vertex(x4, x4);
      img.endShape();*/
      img.strokeWeight(1);
      img.stroke(color(136,0,150));
      img.fill(color(136,200,200));
      img.beginShape();
      img.vertex(.95*width,.95*width);
      img.vertex(x3-size,x3);
      img.vertex(.97*width, .97*width);
      img.endShape();
      img.beginShape();
      img.vertex(.95*width,.95*width);
      img.vertex(x3,x3-size);
      img.vertex(.97*width, .97*width);
      img.endShape();
    }
    
  }
}
void backlash2(PGraphics img){
  if(t<.8){
    return;
  }
  for(float step = 0; step<1; step+=.05){
    float r = width*.2*(1+sin(100*step))*10*(t-.8);
    float th = (PI/2*step +PI);
    float x = .97*width + r*cos(th);
    float y = .97*height + r*sin(th);
    img.fill(color(136, 200+25*sin(100*step), 200+25*sin(153*step)));
    img.beginShape();
    img.vertex(.95*width,.95*height);
    img.vertex(x,y);
    img.vertex(.97*width, .97*height);
    img.endShape();
  }
  
}

void dart(PGraphics img, float sizefactor){
     float x1 = width*(.07+.25*t);
    float y1 = height*(.07+.25*t); 
    float x2 = width*(.8*t+.2);
    float y2 = height*(.8*t+.2);
    float size = width*sizefactor;//(x2-x1)*sizefactor;
    float handle = size*(4/3)*tan(PI/8);
    img.beginShape();
      img.vertex(x1+size, y1-size);
      img.bezierVertex(x1+size-handle, y1-size-handle,
                       x1-size+handle, y1-size-handle,
                       x1-size       , y1-size);
      img.bezierVertex(x1-size-handle, y1-size+handle,
                       x1-size-handle, y1+size-handle,
                       x1-size       , y1+size);
      img.bezierVertex(x1-size+handle, y1+size+handle, 
                        x2,y2,
                        x2,y2);
       img.bezierVertex(x2,y2,
                        x1+size+handle, y1-size+handle,
                        x1+size       , y1-size
                        );
    
    img.endShape();  
    //print(size);
    
}
/*
void arrows(PGraphics img){
  float gap =.01;
  for(float step = 1; step >= 0; step-=(gap*2)){
    float x1 = width*(.07+0*step*t+.25*t);
    float y1 = height*(.07+0*step*t+.25*t); 
    float x2 = width*(.3*t+.6*(step+gap)*t+.2);
    float y2 = height*(.3*t+.6*(step+gap)*t+.2);
    img.fill(255,255*(1-step),0,255*pow(sin(PI*t),.1));
    img.stroke(0,0,0,0);
    img.beginShape();
    img.vertex(x1,y1);
    img.vertex(x1-outline(step), y1);
   // img.vertex(x2-outline(step+gap), y2);
    img.vertex(x2,y2);
    //img.vertex(x2, y2-outline(step+gap));
    img.vertex(x1, y1-outline(step));
    img.endShape();
    
    
    
  }
  
  
}
float outline(float step){
  return .5*t*(1-t)*width;
}
*/
