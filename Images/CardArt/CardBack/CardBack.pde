PGraphics image1;
int dropshadowsize = 10;
int cornerradius = 60;
float t=0;
PImage image2;
int frame = 0;
PGraphics export;
void setup(){
  size(738,1028);
  //size(369,514);
  image1 = createGraphics(width-2*dropshadowsize, height-2*dropshadowsize);
  export = createGraphics(width, height, JAVA2D);
  export.smooth();
}
void draw(){
  image1.beginDraw();
  image1.background(100);
  pattern1(image1);
  //diamond(image1);
  roundcorners(image1);
  image1.endDraw();
  export.beginDraw();
  //background(0,255,0);
  if (image2 ==null){
    image2 = shadow(image1);
    export.image(image2,dropshadowsize,dropshadowsize,image2.width+dropshadowsize, image2.height+dropshadowsize);

  }
  //image(image2,dropshadowsize,dropshadowsize,image2.width+dropshadowsize, image2.height+dropshadowsize);
  
  export.image(image1,0,0,image1.width, image1.height);
  export.endDraw();
  image(export,0,0,width, height);
  if (t<2*PI){
    //saveFrame(String.format("frame%03d.png",frame));
    export.save(String.format("frame%03d.png",frame));
  }
  t+=.05;
  frame++;
}

void roundcorners(PGraphics image){
  image.loadPixels();
  int radsq = cornerradius* cornerradius;
  //Top left
  for (int x = 0; x<cornerradius; x++){
    for (int y = 0; y< cornerradius; y++){
      int d = distsq(x,y,cornerradius,cornerradius);
      if (d > radsq+20){
        image.pixels[y*image.width+x] = color(0,0,0,0);
      }
      else if (d > radsq){
         color col = image.pixels[y*image.width+x];
        image.pixels[y*image.width+x] = color(red(col),green(col),blue(col),50);
      }
    }  
  }
  //Top right
  for (int x = image.width - cornerradius; x<image.width; x++){
    for (int y = 0; y< cornerradius; y++){
      int d = distsq(x,y,image.width-cornerradius,cornerradius);
      if (d > radsq+20){
        image.pixels[y*image.width+x] = color(0,0,0,0);
      }
      else if (d > radsq){
         color col = image.pixels[y*image.width+x];
        image.pixels[y*image.width+x] = color(red(col),green(col),blue(col),50);
      }
    }  
  }
  //Bottom left
  for (int x = 0; x<cornerradius; x++){
    for (int y = image.height - cornerradius; y< image.height; y++){
      int d = distsq(x,y,cornerradius,image.height - cornerradius);
      if (d > radsq+20){
        image.pixels[y*image.width+x] = color(0,0,0,0);
      }
      else if (d > radsq){
         color col = image.pixels[y*image.width+x];
        image.pixels[y*image.width+x] = color(red(col),green(col),blue(col),50);
      }
    }  
  }
  //bottom right
  for (int x = image.width - cornerradius; x<image.width; x++){
    for (int y = image.height - cornerradius; y< image.height; y++){
      int d = distsq(x,y,image.width - cornerradius,image.height - cornerradius);
      if (d > radsq+20){
        image.pixels[y*image.width+x] = color(0,0,0,0);
      }
      else if (d > radsq){
         color col = image.pixels[y*image.width+x];
        image.pixels[y*image.width+x] = color(red(col),green(col),blue(col),50);
      }
    }  
  }
  image.updatePixels();
}

int distsq(int x0,int y0,int x1,int y1){
  return (x0-x1)*(x0-x1)+(y0-y1)*(y0-y1);
}
void pattern1(PGraphics image){
   image.loadPixels();
   for (float x = 0.0; x< image.width; x++){
     for(float y = 0.0; y< image.height; y++){
       /*if (x/image.width-y/image.height > .5 
         || x/image.width+y/image.height < .5  
         || -1.0*x/image.width+y/image.height > .5 
         || x/image.width+y/image.height > 1.5
         ){*/
         
       
       float rad = sqrt(distsq((int)x,(int)y,image.width/2, image.height/2));
       if (rad > image.width/3)
         {
       if (tan(-t+rad/15)/3 +sin(1.0*(y-image.height/2)/15) + sin(1.0*(x-image.width/2)/15) > .5 ){
         image.pixels[(int)y*image.width+(int)x] = color(0,50,100);
       } else {
         int r = (int)map(rad,0,image.height/2+image.width/2,255,100);
         int g = (int)map(rad,0,image.height/2+image.width/2,175,50);
         image.pixels[(int)y*image.width+(int)x] = color(r,g,50);
       }
       } else {
         int r = (int)map(rad,0,image.height/2+image.width/2,255,100);
         int g = (int)map(rad,0,image.height/2+image.width/2,175,50);
         image.pixels[(int)y*image.width+(int)x] = color(r,g,50);
       }
     }
   }
   image.updatePixels();
}
void diamond(PGraphics image){
  image.stroke(0,0,0);
  image.strokeWeight(5);
  for(int i =-5; i<=5; i++){
    image.line(0,image.height/2-i, image.width/2+i, 0);
    image.line(image.width,image.height/2+i, image.width/2+i, 0);
    image.line(0,image.height/2+i, image.width/2+i, image.height);
    image.line(image.width,image.height/2-i, image.width/2+i, image.height);
    
  }
}

PImage shadow(PGraphics image){
  PGraphics shadow = createGraphics(image.width, image.height);
  shadow.beginDraw();
  shadow.tint(50);
  shadow.image(image, 0,0,image.width, image.height);
  shadow.endDraw();
  return shadow;
}
