float t=0;

PGraphics image1;
PGraphics image2;
int frame = 0;
PGraphics export;
void setup(){
  size(1000,1000);
  //size(369,514);
  image1 = createGraphics(width, height);
  image2 = createGraphics(width, height);
  generateBackground(image2);
  export = createGraphics(width, height, JAVA2D);
  export.smooth();
}
void draw(){
  generate(image1);
  export.beginDraw();
  export.clear();
  export.image(image2,0,0,image2.width, image2.height);
  export.image(image1,0,0,image1.width, image1.height);
  export.endDraw();
  clear();
  image(export,0,0,width, height);
  if (t<2*PI){
    //saveFrame(String.format("frame%03d.png",frame));
    export.save(String.format("frame%03d.png",frame));
  }
  t+=.05;
  frame++;
}

void generate(PGraphics image){
    image.beginDraw();
    image.loadPixels();
    for (float x = 0.0; x< image.width; x++){
     for(float y = 0.0; y< image.height; y++){
       float halfx = x-image.width/2.0 ;
       float halfy = y-image.height/2.0  ;
       float radsq = distsq((int)x,(int)y,image.width/2, image.height/2);
       float expand = sin(-t+radsq/8000)/2;
       float theta = atan(halfy/halfx);
       float ellipse1 = (halfx*halfx)/(image.width*image.width/4) + (halfy*halfy)/(image.width*image.width/8);
       float ellipse2 = (halfx*halfx)/(image.width*image.width/8) + (halfy*halfy)/(image.width*image.width/4);
       
       float ellipse1r = sin(10*ellipse1)*sin(14*theta +t);
       float ellipse2r= sin(10*ellipse2)*sin(10*theta -t);
       int c;
       if(radsq < 250000 ){//&& max(ellipse1r,ellipse2r)+expand>.5){
         float val = max(ellipse1r,ellipse2r)+expand;
         float r = 255*val;// (int)(200*sin(10*ellipse1));
         float g = 150*val;//(int)min(200*sin(10*ellipse2),r);
         float b = 50*val; //(int)(min(r,g)/2);
         
         int a =(int)(255*val);
         c=color(r,g,b,a);
         image.pixels[(int)y*image.width+(int)x] = c;
       } else{
         c= color(0,0,0,0);
       }
      /* if (brightness(c) < 20 || alpha(c) < 20){
         int r = min(255,(int)(4*2550000.0/radsq));
         int g = min(255,(int)(4*2000000.0/radsq));
         int b = min(255,(int)(4*1000000.0/radsq));
         int a = min(255,(int)(4*2550000.0/radsq));
         image.pixels[(int)y*image.width+(int)x] = color(r,g,b,a);
       }*/
       
     }
    }
    image.updatePixels();
    image.endDraw();
}

int distsq(int x0,int y0,int x1,int y1){
  return (x0-x1)*(x0-x1)+(y0-y1)*(y0-y1);
}
void generateBackground(PGraphics image){
  image.beginDraw();
  image.loadPixels();
    for (float x = 0.0; x< image.width; x++){
     for(float y = 0.0; y< image.height; y++){
       float radsq = distsq((int)x,(int)y,image.width/2, image.height/2);
      
       if(radsq < 250000){
          int r = min(255,(int)(4*2550000.0/radsq));
          int g = min(255,(int)(4*2000000.0/radsq));
          int b = min(255,(int)(4*1000000.0/radsq));
          int a = min(255,(int)(4*2550000.0/radsq));
         image.pixels[(int)y*image.width+(int)x] = color(r,g,b,a);
       }
     }
    }
    image.updatePixels();
    image.endDraw();
}
