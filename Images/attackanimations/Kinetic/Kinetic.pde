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

   
   circles(image1);
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

void circles(PGraphics img){
  img.loadPixels();
  for (float x = 0.0; x< img.width; x++){
     for(float y = 0.0; y< img.height; y++){
       float th = atan(y/x);
       float r = .5*(width*width+height*height) / (x*x+y*y);
       if (th < PI/6 || th >PI/3 || 1/r > 1.3 ){
         continue;
       }
       
       float h = 39;
       float s = 255-16*sqrt(r*t);
       float v =255;
       float a = 255*sin(30*(sqrt(1/r) -t));
       a*= sin(6*th+ PI);
       
       a=2*a*r*t*t*pow((1-t),.7);
       
       img.pixels[(int)y*img.width+(int)x] = color(h,s,v,a);
     }
  }
  img.updatePixels();
  
}
