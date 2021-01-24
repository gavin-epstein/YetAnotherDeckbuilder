float t=0;

PGraphics image1;
PGraphics image2;
int frame = 0;
PGraphics export;
float ellipsev = 250;
float ellipseh = 400;
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
  //export.image(image2,0,0,image2.width, image2.height);
  export.image(image1,0,0,image1.width, image1.height);
  export.endDraw();
  clear();
  background(255,255,255);
  image(export,0,0,width, height);
  if (t<2*PI){
    
    export.save(String.format("frame%03d.png",frame));
  }
  t+=.07;  
  frame++;
}

void generate(PGraphics image){
    image.beginDraw();
    image.clear();
    image.strokeWeight(0);
    image.stroke(0,0,0,0);
    for (float p = 90; p >0; p-=.007){
       
       float T = (p+t/6)%90 * PI;
       float C = 4.97 * ((p+t/6)%90-t/6)*PI;
       image.fill(100+10*cos(3*C)-T/2,90-T/2,140+50*sin(2*C) - T/2,2*T);
       float [] point = pointOnSpiral(T,ellipsev,ellipseh,1.008,.99);
       image.ellipse(point[0],point[1],ellipseh/20 * sin(1.77*C),ellipsev/20 * sin(1.77*C));
       
       
    }
    image.endDraw();
    
}

void generateBackground(PGraphics image){
  image.beginDraw();
  image.loadPixels();
    for (float x = 0.0; x< image.width; x++){
     for(float y = 0.0; y< image.height; y++){
       float radsq = distsq(x,(y*ellipseh/ellipsev),image.width/2, 40+image.height/2*(ellipseh/ellipsev));
       radsq = radsq*250/150;
       if(radsq < 250000){
          int r = min(255,(int)(10*2550000.0/radsq));
          int g = min(255,(int)(10*1000000.0/radsq));
          int b = min(255,(int)(10*1000000.0/radsq));
          int a = min(255,(int)(100000* 2550000.0/(pow(radsq,2))));
         image.pixels[(int)y*image.width+(int)x] = color(r,g,b,a);
       }
     }
    }
    image.updatePixels();
    image.endDraw();
}
float distsq(float x0,float y0,float x1,float y1){
  return (x0-x1)*(x0-x1)+(y0-y1)*(y0-y1);
}

float [] pointOnSpiral(float T, float w, float h, float descent, float inwards){
  float x  = width/2 - pow(inwards,T)*h*sin(T) ;
  float y  = height/2 - pow(inwards,T)* w*cos(T)+10*pow(descent,T);
  return new float[]{x,y};
}
