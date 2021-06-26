PGraphics image1;
int dropshadowsize = 10;
int cornerradius = 60;
float t=0;
PImage image2;
int frame = 0;
PGraphics export;
void setup(){
  size(1107,1542);
  //size(369,514);
  image1 = createGraphics((int)(.66*width-2*dropshadowsize), (int)(.66*height-2*dropshadowsize));
  export = createGraphics(width, height, JAVA2D);
  export.smooth();
}
void draw(){
  clear();
  image1.beginDraw();
  image1.background(100);
  pattern1(image1);
  //diamond(image1);
  roundcorners(image1);
  image1.endDraw();
  //arrow(image1);
  export.beginDraw();
  export.clear();
  //background(0,255,0);
  if (image2 ==null){
    image2 = shadow(image1);
  }
  export.image(image2,.16*width+dropshadowsize,.16*height+dropshadowsize,image2.width+dropshadowsize, image2.height+dropshadowsize);

  
  //image(image2,dropshadowsize,dropshadowsize,image2.width+dropshadowsize, image2.height+dropshadowsize);
  
  export.image(image1,.16*width,.16*height,image1.width, image1.height);
  export.endDraw();
 // arrow(export);
  image(export,0,0,width, height);
  if (t<2*PI){
    //saveFrame(String.format("frame%03d.png",frame));
    export.save(String.format("frame%03d.png",frame));
  }else{
    exit();
  }
  t+=.1;
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
       if (value(x,y,rad,image) > .5 ){
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


PImage shadow(PGraphics image){
  PGraphics shadow = createGraphics(image.width, image.height);
  shadow.beginDraw();
  shadow.tint(50);
  shadow.image(image, 0,0,image.width, image.height);
  shadow.endDraw();
  return shadow;
}

void arrow(PGraphics img){
  img.beginDraw();
  float at = PI-t+.01;
  float[] coords  =null;
  float x1  = .1 *img.width;
  float x2 = .9*img.width;
  float y1 = .1*img.height;
  float y2 = .9*img.height;
  float x3 = img.width/2;
  float y3 = img.height/2;
  float x4 = img.width/2 + img.height*cos(at);
  float y4 = img.height/2 + img.height*sin(at);
  coords  = get_line_intersection(x1,y1,x1,y2,x3,y3,x4,y4);
  if (coords==null){
    coords = get_line_intersection(x1,y1,x2,y1,x3,y3,x4,y4);
  }
  if (coords==null){
    coords = get_line_intersection(x2,y2,x1,y2,x3,y3,x4,y4);
  }
  if (coords==null){
    coords = get_line_intersection(x2,y2,x2,y1,x3,y3,x4,y4);
  }
  if (coords ==null){
    return;
  }
  float cx = coords[0];
  float cy = coords[1];
  float tsize = 50;
  float a = floor((int)((2*PI+at+PI/4)*2/PI))*PI/2;
  img.strokeWeight(0);
  float rad = sqrt(distsq((int)cx,(int)cy,img.width/2, img.height/2));
  int r = (int)map(rad,0,img.height/2+img.width/2,255,100);
  int g = (int)map(rad,0,img.height/2+img.width/2,175,50);
  img.fill( color(r,g,50));
 // img.fill(0);
  img.stroke(0,0,0,0);
  img.beginShape();
    img.vertex(cx + tsize*cos(a),cy+tsize*sin(a));
    img.vertex(cx - tsize*cos(a),cy-tsize*sin(a));
    img.vertex(cx + tsize*cos(a-PI/2),cy+tsize*sin(a-PI/2));
  img.endShape();
  img.endDraw();
  
}
float value(float x, float y, float rad, PGraphics img){
  float val = (tan(-t+rad/15)/3 +sin(1.0*(y-img.height/2)/15) + sin(1.0*(x-img.width/2)/15));
  float angle = atan((y-img.height/2)/(x-img.width/2));
  if (x<img.width/2){
    angle +=PI;
  }else if (y<img.height/2){
    angle+=2*PI;
  }
  val += 3*(-sin(.05*x)+sin(angle)-cos(.05*rad)+sin(.025*y+4*t+sin(.1*x)));
  return val;
  
}


// Returns 1 if the lines intersect, otherwise 0. In addition, if the lines 
// intersect the intersection point may be stored in the floats i_x and i_y.
float[] get_line_intersection(float p0_x, float p0_y, float p1_x, float p1_y, 
    float p2_x, float p2_y, float p3_x, float p3_y)
{
    float s1_x, s1_y, s2_x, s2_y;
    s1_x = p1_x - p0_x;     s1_y = p1_y - p0_y;
    s2_x = p3_x - p2_x;     s2_y = p3_y - p2_y;

    float s, t;
    s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y);
    t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y);

    if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
    {
        // Collision detected
        
        float i_x = p0_x + (t * s1_x);
        
       float  i_y = p0_y + (t * s1_y);
        return new float[] {i_x,i_y};
    }

    return null; // No collision
}
