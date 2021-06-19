PGraphics image1;
float t=0;
int frame=0;
float opacity;
void setup(){
  size(1000,1000);
  colorMode(HSB,255);
  image1 = createGraphics(width, height);
  
}
void draw(){
   background(0);
   image1.beginDraw();
   image1.clear();

   image1.endDraw();
   light(image1);
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

void light(PGraphics img){
  img.beginDraw();
  img.loadPixels();
  for (float x = 0.0; x< img.width; x++){
     for(float y = x/3; y< min(img.height, 3*x); y++){
       float r = .5*(width*width+height*height) / (x*x+y*y);
       float h = 39;
       float s = 255-16*sqrt(r*t);
       float v =255;
       float a = 0;
       for (float i = 1;i<5; i++){
         a += 255/4*(.2+sin( 75*(sin(2*i))*atan(x/y)+ 72*i));
       }
       a=a*r*t*t*pow((1-t),.7);
       
       img.pixels[(int)y*img.width+(int)x] = color(h,s,v,a);
     }
  }
  img.updatePixels();
  img.endDraw();
  
}
