PGraphics image1;
PGraphics clouds;
float t=0;
int frame=0;
ArrayList<Float> lightningx;
ArrayList<Float> lightningy;
void setup(){
  size(1000,1000);

  image1 = createGraphics(width, height);
  clouds = createGraphics(width, height);
  lightningx = new ArrayList<Float>();
  lightningy = new ArrayList<Float>();
  lightningx.add(.13*width);
  lightningy.add(.13*height);
}
void draw(){
   background(30);
   clouds.beginDraw();
   //clouds.clear();
   makeClouds(clouds);
   clouds.endDraw();
   image1.beginDraw();
   image1.clear();

   
   lightning(image1);
   image1.image(clouds,0,0,width,height);
   image1.endDraw();
   image(image1,0,0,width, height);
   if (t<1){
      //image1.save(String.format("frame%03d.png",frame));
    }else{
      //t=0;
      //exit();
    }
   
   t+=.05;
   frame++;
}

void lightning(PGraphics img){
  for (int i=0; i<2; i++){
  float x = lightningx.get(lightningx.size()-1) + random(0, width)*random(-.1,.3);
  float y = lightningy.get(lightningy.size()-1) + random(0, height)*random(-.1,.3);
  if (x>width || y>height){
    lightningx.clear();
    lightningy.clear();
    float x2 = (.35*t+.13)*width;
    lightningx.add(x2);
    lightningy.add(x2);
    break;
    
  }
  lightningx.add(x);
  lightningy.add(y);
  }
  for(int i=0;i<lightningx.size()-1; i++){
    float sizefactor = lightningx.size()-i;
    img.strokeWeight(20+ sizefactor);
    img.stroke(255,255,100);
    img.line(lightningx.get(i), lightningy.get(i),lightningx.get(i+1),lightningy.get(i+1));
   
    img.strokeWeight(10+sizefactor);
    img.stroke(255,255,250);
    img.line(lightningx.get(i), lightningy.get(i),lightningx.get(i+1),lightningy.get(i+1));
    
  }
  img.filter(BLUR,20);
  for(int i=0;i<lightningx.size()-1; i++){
    float sizefactor = lightningx.size()-i;
    img.strokeWeight(min(1,sizefactor/2));
    img.stroke(255,255,250);
    img.line(lightningx.get(i), lightningy.get(i),lightningx.get(i+1),lightningy.get(i+1));
    
  }
 
}
void makeClouds(PGraphics img){
  //float x1=(.1*t+.1)*width;
  float x2=(.21*t+.13)*width;
  
  for (int i=0; i<3000; i++){
    img.stroke(0,0,0,0);
    float b = random(50,255);
    float g= random(b-50,b);
    float r = random(g-20,g+15);
    img.fill(r,g,b,7);
    float th = random(0,2*PI);
    float rad = random(5,x2)*.12*(5+sin(20*th) + 1*sin(2*th + PI) );
    img.ellipse(x2+rad*cos(th), x2+rad*sin(th) ,random(30,60),random(30,60));
  }
}
