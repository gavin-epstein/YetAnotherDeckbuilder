PGraphics image1;
float t=0;
int frame=0;
PImage upper;
PImage lower;
static final float jawsize = .7;
void setup(){
  size(1000,1000);
   upper = loadImage("Jaws.png");
   lower = loadImage("Jaws2.png");
  image1 = createGraphics(width, height);
}
void draw(){
   background(150);
   image1.beginDraw();
   image1.clear();
   image1.endDraw();
   chomp(image1);
   image(image1,0,0,width, height);
   if (t<1){
      image1.save(String.format("frame%03d.png",frame));
    }else{
      t=0;
      exit();
    }
   
   t+=.05;
   frame++;
}
void chomp(PGraphics img){
    float a = -.25*PI*(.5-.5*cos(3*PI*t));
    float x = (1-jawsize)*width*t;

    img.beginDraw();
    img.pushMatrix();
      img.translate(x+jawsize*162, x+jawsize*117);
      img.rotate(-1*a);
      img.translate(-x-jawsize*162, -x-jawsize*117);
      img.image(upper, x,x,jawsize*width, jawsize*width);
    img.popMatrix();
    img.pushMatrix();
      img.translate(x+jawsize*162, x+jawsize*117);
      img.rotate(a);
      img.translate(-x-jawsize*162, -x-jawsize*117);
      img.image(lower, x,x,jawsize*width, jawsize*width);
    img.popMatrix();
    
    img.endDraw();
  
  
}
