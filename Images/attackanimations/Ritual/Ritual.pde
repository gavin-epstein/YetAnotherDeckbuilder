PGraphics image1;
float t=0;
int frame=0;
PImage pentacle;
float fade = .9;
void setup(){
  size(600,600);
  pentacle = loadImage("../Pentagram.png");
  image1 = createGraphics(width, height);
}
void draw(){
   background(150);
   image1.beginDraw();
   fade(image1);
   image1.pushMatrix();
   image1.scale(.8,.8);
   image1.translate(image1.width*.1,image1.height*.1);
   ritual(image1);
   //pentagram(width/4, height/4, 100,100, t ,image1);
   image1.popMatrix();
   image1.endDraw();
   image(image1,0,0,width, height);
   if (t<1+.4 && frame%10==0){
      image1.save(String.format("frame%03d.png",frame));
    }else{
      //exit();
    }
   
   t+=.0025;
   frame++;
}

void ritual( PGraphics img){
  for(float i = -1; i<=1; i+=.4){
    arc(i, t+.1*sin(22*i), img);
    //arc(i, t+.2*sin(3.4*i), img);
    //arc(i, t, img);
  }
}

void arc(float a, float t2, PGraphics img){
  float x = img.width*(t2 + a*t*(t2-1));
  float y =  img.height*( t2 - a*t*(t2-1));
  float size = -800*(t2)*(t2-1) + 10;
  pentagram(x,y,size, size,.3*sin(2.3*a)*2*PI*t2,img);
}

void pentagram(float x,float y,float w, float h,float r,PGraphics img){
  if (w<=0 || h<=0){
    return;
  }
  img.pushMatrix();
    
    img.translate(x,y);
    img.rotate(r);
    img.translate(-w/2, -h/2);
    img.image(pentacle,0,0,w,h);
  img.popMatrix();
  
}

void fade(PGraphics img){
  //img.beginDraw();
  img.loadPixels();
  for (int x = 0; x< img.width; x++){
    for(int y = 0; y<img.height; y++){
      int i = y*img.width+x;
    color c  =img.pixels[i];
    if (alpha(c)>1 && alpha(c) < 250){
      float x1= 1.2*x/img.width-.08;
      float y1= 1.2*y/img.height-.08;
      
      float path = 2.0*(x1-y1)/((x1+y1)*(x1+y1-2.0));
      fade = (sin(20.0*path + 10*sin((x+y)/100.0 + 10*t))+30)/30.5;
      //(sin((5*path + 5*sin((x+y)/250.5 + .5*t)) + 0*t)+1)/2;
      //+ .1*sin(x*y/1000.0 + 20.0*t) + .5  + 10)/11 ;
      fade = min(fade,.99);
      img.pixels[i] = color(red(c),green(c), blue(c), fade*alpha(c));
    }else if(alpha(c) >= 250){
      img.pixels[i] = color(red(c),green(c), blue(c), .5*alpha(c));
    }
    else{
      img.pixels[i] = color(0,0,0,0);
    }
    }
  }
  img.updatePixels();
  //img.endDraw();
  
}
