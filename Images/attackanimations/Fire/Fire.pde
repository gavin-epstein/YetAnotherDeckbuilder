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

   image1.endDraw();
   fire(image1);
   image(image1,0,0,width, height);
   if (t<1){
      //image1.save(String.format("frame%03d.png",frame));
    }else{
      t=0;
      //exit();
    }
   
   t+=.05;
   frame++;
}
void fire(PGraphics img){
  
    img.beginDraw();
    img.strokeWeight(0);
    float opacity = 255*pow((1-t),2);
    for(float step = 0; step <1; step=step+.003){
      
      float x = .2*width*t+step*t*width*.7;
      float y = .2*height*t+step*t*width*.7; 
      float angle = random(0,PI/2);
      float len = .4 * x;
      x = x+ random(0,.1*len)*cos(angle);
      y = y + random(0,.1*len)*sin(angle);
      float r = 255;
      float g = random(0,255);
      float b = random(0,g);
      img.fill(r,g,b,opacity);
      flame(x,y,len,angle,img);
    }

    img.endDraw();
  
  
}
void flame(float x,float y,float len, float angle, PGraphics img){
    img.strokeWeight(0);
    img.stroke(0,0,0,0);
    img.beginShape();
    img.vertex(x,y);
    img.bezierVertex(x+len*2*random(.1,.25)*cos(angle+PI/8), y+len*2*random(.1,.25)*sin(angle+PI/8),
    x+len*2*random(.20,.30)*cos(angle+PI/12), y+len*2*random(.20,.30)*sin(angle+PI/12),
    x+len*cos(angle), y+len*sin(angle));
    img.bezierVertex(
    x+len*2*random(.20,.30)*cos(angle-PI/12), y+len*2*random(.20,.30)*sin(angle-PI/12),
    x+len*2*random(.10,.25)*cos(angle-PI/8), y+len*2*random(.10,.25)*sin(angle-PI/8),
    x,y
    );
    img.endShape();
   
    
}
