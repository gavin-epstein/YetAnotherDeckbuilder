PGraphics image1;
float t=0;
int frame=0;
float opacity;
void setup(){
  size(1000,1000);

  image1 = createGraphics(width, height);
  
}
void draw(){
   background(255);
   image1.beginDraw();
   image1.clear();

   image1.endDraw();
   shadow(image1);
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
void shadow(PGraphics img){
   opacity = pow((1-t),.4);
   img.beginDraw();
   for(float step = 0; step <1; step=step+.1){
      
      float x = width*(.3*t+.1*step+.2);
      float y = height*(.3*t+.1*step+.2); 
      float len = .1 * (width+x)*(3+sin(33.22*step))*t;
      x = x+ .5*(100+len)*cos(20*step+t);
      y = y + .5*(100+len)*cos(11.7*step+t);
      float flip = 1;
      if (cos(22*step) < 0){
        flip =-1;
      }

      spiral(x,y,len,img,flip);
    }
   
   img.endDraw();
}
void spiral(float x,float y,float rad, PGraphics img, float flip){
  for (float step = 0; step <1; step=step+.005){
    float p = 7*t+10*step;
    float e = 2.71828;
    float x1 = x+pow(e,-.2*p)*sin(p)*rad * flip;
    float y1 = y+pow(e,-.2*p)*cos(p)*rad;
    
    img.strokeWeight(0);
    img.stroke(0,0,0,0);
    float v = 100*(1-step);
    img.fill(v,random(0,v),v,20*opacity);
    float size = sin(PI*step);
    img.ellipse(x1,y1,size*random(30,60),size*random(30,60));
    
  }
  
  
}
