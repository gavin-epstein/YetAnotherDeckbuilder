PGraphics image1;
float t=0;
int frame=0;
float opacity;
float beamw;
void setup(){
  size(800,800);
  image1 = createGraphics(width, height);
  
}
void draw(){
   background(0,0,255);
   image1.beginDraw();
   image1.clear();
   
   image1.endDraw();
   beam(image1);
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

void beam(PGraphics img){
  
  beamw = .1*width*sin(.5*PI*t); 
  img.beginDraw();
  
  img.loadPixels();
  for(float x=0; x<width; x++){
      for(float y=0; y<width; y++){
          if (boundary(x,y)){
            img.pixels[int(y)*width+int(x)] = beamColor(x,y);
          }
          else if(alpha(img.pixels[int(y)*width+int(x)]) >0){
             img.pixels[int(y)*width+int(x)] = beamColor(x,y);
          }else{
            img.pixels[int(y)*width+int(x)] = color(0,0,0,0);
          }
      }
  }
  img.updatePixels();
  backlash2(img);
  img.endDraw();
}

boolean boundary(float x, float y){
  
  if ((x-beamw)*(x-beamw) + (y-beamw)*(y-beamw) < beamw*beamw){
    return true;
  }
  if (y +x <beamw){
    return false;
  }
  if (abs(x-y) > 1.414*beamw ){
    return false;
  }
  return true;
  
}
int beamColor(float x, float y){
  //.1- .1*(x/width+y/height) +
  float brightness = pow(cos(.75*width/beamw*(x/width-y/height)), 2)+ .1 * cos(PI*t - (x/width+y/height));
  float r = 250 * brightness;
  float b = 255 * brightness;
  float g = 255*brightness*brightness;
  return color(constrain(r,0,255), constrain(g,0,255),constrain(b,0,255));

}
void splash(PGraphics img){
  for(float i =0; i<beamw; i++){
    if(random(0,1)< .01){
      float vecx = width - 3*i/1.414;
      float vecy = height - 3*(beamw-i)/1.141;
      img.strokeCap(SQUARE);
      img.stroke(50,25,50);
      img.strokeWeight(.1*beamw);
      //img.line(0,width, height,0);
      img.line(width,height, vecx, vecy);
      img.stroke(200,100,200);
      img.strokeWeight(.05*beamw);
      img.line(width,height, vecx, vecy);
      img.stroke(255,255,255);
      img.strokeWeight(.025*beamw);
      img.line(width,height, vecx, vecy);
    }
  }
}
void backlash2(PGraphics img){
  for(float i = 0; i<1; i+=.01){
    for(float step = 0.01; step<1; step+=.05){
      float r = (1-i)*width*.2*(1+sin(70*step))*t*1.5;
      if(r<beamw){
       continue; 
      }
      float th = (PI/2*step +PI);
      float x = width + r*cos(th);
      float y = height + r*sin(th);
      img.strokeWeight(0);
      img.stroke(0,0,0,0);
      img.fill(color(300*(i+.2), 255*(i+.2), 325*(i+.2)));
      img.beginShape();
      img.vertex(width-1.4*beamw,height);
      img.vertex(x,y);
      img.vertex(width, height-1.4*beamw);
      img.endShape();
      img.beginShape();
      img.vertex(width-1.4*beamw,height);
      img.vertex(width, height);
      img.vertex(width, height-1.4*beamw);
      img.endShape();
    }
    
  }
  
}
