PGraphics image1;
PGraphics image2;
float t=0;
int frame=0;
float opacity;
void setup(){
  size(1000,1000);
  colorMode(HSB,255);
  image1 = createGraphics((int)(1.3*width), (int)(1.3*height));
  image2 = createGraphics(width, height);
  //moss(image1);
}

void draw(){
   background(255);
   image1.beginDraw();
   image1.clear();
    
   image1.endDraw();
    moss(image1);
    image2.beginDraw();
    image2.clear();
    image2.pushMatrix();
   image2.translate(0, -.35*height);
    image2.rotate(PI/6-.07);
    
   image2.image(image1,0,0,image1.width, image1.height);
   image2.popMatrix();
   image2.loadPixels();
    for (float x = 0.0; x< image2.width; x++){
       for(float y =0.0; y< image2.height; y++){
          color c = image2.pixels[(int)y*image2.width+(int)x];
          float a = alpha(c);
         // float xr = 1-x/width;
          //float yr = 1-y/height;
          
          if (x*y<.01*width*height){
            a=0;
          }
         
          image2.pixels[(int)y*image2.width+(int)x] = color(hue(c), saturation(c), brightness(c),a);
       }
       
    }
   
   image2.updatePixels();
   image2.endDraw();
   image(image2,0,0,width,height);
   if (t<1){
      //image2.save(String.format("frame%03d.png",frame));
    }else{
      t=0;
      exit();
    }
   
   t+=.05;
   frame++;
}

void moss(PGraphics img){
  img.beginDraw();
  img.loadPixels();
  for (float x = 0.0; x< img.width; x++){
     for(float y =0.0; y< img.height; y++){
       int i =0;
       float [] z = new float[]{0,0};
       float[] c = new float[]{.4*x/img.width-.45, .4*y/img.height-1};
      // float [] lastz = z;
       while (i<30*t+1){
         
         z= cMult(z,cMult(z,z));
         z = cAdd(z,c);
         if (z[0]+z[1] >50*t*t){
           break;
         }
         i+=1;
       }
       float h = 80 + 20*(1+sin(.0000001*z[0]+100));
       float a = (z[0]+z[1]);
       float s = 200*(1+sin(.000000001*z[0]));
       float v = .01*(z[0]*z[0] + z[1]*z[1]);
       img.pixels[(int)y*img.width+(int)x] = color(h,s,v,a);
     }
  }
  img.updatePixels();
  img.endDraw();
  
}

float[] cMult(float [] a, float[] b ){
  return new float []{
    a[0]*b[0] - a[1]*b[1],
    a[0]*b[1] + a[1]*b[0]
  };
}
float [] cAdd(float [] a, float[] b ){
  return new float []{
    a[0]+b[0],
    a[1]+b[1]
  };
}
float [] sMult(float []a, float b){
   return new float []{
    a[0]*b,
    a[1]*b
  };
}
