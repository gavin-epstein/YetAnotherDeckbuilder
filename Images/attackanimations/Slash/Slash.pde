PGraphics image1;
float t=0;
int frame=0;

void setup(){
  size(1000,1000);

  image1 = createGraphics(width, height);
}
void draw(){
   background(150);
   image1.beginDraw();
   image1.clear();
   image1.endDraw();
   slash(image1);
   image(image1,0,0,width, height);
   if (t<1){
      image1.save(String.format("frame%03d.png",frame));
    }else{
      exit();
    }
   
   t+=.05;
   frame++;
}
void slash(PGraphics img){
  for (float step = 1; step >0; step=step-.01){
    float Cx = .5*width;
    float Cy = .5*height;
    float a = PI/4;
    float Rx = .6*width*(1-step/6);
    float Ry = .05*height*(1-step/6);
    float th = 3.1*t-step-.4;
    float x1 = Rx*cos(a)*cos(th) - Ry*sin(a)*sin(th)+Cx;
    float y1 = Rx*cos(a)*sin(th) + Ry*sin(a)*cos(th)+Cy;
    Rx = .75*Rx/(1-step/6)/(1-step/6);
    Ry = .75*Ry/(1-step/6)/(1-step/6);
    Cx = .9*Cx;
    Cy = .9*Cy;
    float x2 = Rx*cos(a)*cos(th) - Ry*sin(a)*sin(th)+Cx;
    float y2 = Rx*cos(a)*sin(th) + Ry*sin(a)*cos(th)+Cy;
    img.beginDraw();
    img.strokeWeight(6);
    int v = (int)(255*(1-.5*step));
    img.stroke(v,v,v,255*sin(PI*t)*sin(PI*t));
    img.line(x1,y1,x2,y2);
    img.endDraw();
  }
  
}
