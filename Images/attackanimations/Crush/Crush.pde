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
   crush(image1);
   image(image1,0,0,width, height);
   if (t<1){
      image1.save(String.format("frame%03d.png",frame));
    }else{
      exit();
    }
   
   t+=.05;
   frame++;
}
void crush(PGraphics img){
  for (float step = 1; step >0; step=step-.05){
    if (step > sin(PI*t)*sin(PI*t)){
      continue;
    }
    float Cx = .5*width;
    float Cy = .5*height;
    float a = PI/4;
    float Rx = .6*width*(1-step/6);
    float Ry = .05*height*(1-step/6);
    float th = 3.1*t-2*step-.4;
    float x1 = Rx*cos(a)*cos(th) - Ry*sin(a)*sin(th)+Cx;
    float y1 = Rx*cos(a)*sin(th) + Ry*sin(a)*cos(th)+Cy;
    Rx = .75*Rx/(1-step/6)/(1-step/6);
    Ry = .75*Ry/(1-step/6)/(1-step/6);
    Cx = .9*Cx;
    Cy = .9*Cy;
    float x2 = Rx*cos(a)*cos(th) - Ry*sin(a)*sin(th)+Cx;
    float y2 = Rx*cos(a)*sin(th) + Ry*sin(a)*cos(th)+Cy;
    img.beginDraw();
    img.strokeWeight(0);
    
    for(int i = 0; i < 3; i++){
      int v = (int)(125*(.5*step+1+sin(300*i*step)));
      img.stroke(0,0,0,0);
      img.fill(v,.9*v,.7*v,255);
      float k = .5*(1+sin(20*i*step));
      float x3 = k*x1+(1-k)*x2;
      float y3 = k*y1+(1-k)*y2;
      float size = (x1-x2+y1-y2)*.2*(1.5+.5*sin(170*i*step));
      polygon(x3,y3,size,img);
    }
    img.endDraw();
  }
  
}

void polygon(float x,float y,float r,PGraphics img){
  img.beginShape();
    for(int i = 0; i<6; i+=1){
      float a = i*PI/3;
      float x1 = x+r*cos(a);
      float y1 = y+r*sin(a);
      x1+= .1*r*sin(x1*y1*i);
      y1+= .1*r*cos(x1*y1*i);
      img.vertex(x1,y1);
    }
  img.endShape();
  
}
