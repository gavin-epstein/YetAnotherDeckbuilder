PGraphics image1;
float t=0;
int frame=0;
int merges=0;
ArrayList<Branch> branches;
void setup(){
  size(800,800);
  branches = new ArrayList();
  image1 = createGraphics(width, height);
  branches.add(new Branch(20, 20, PI/4 + random(-.1,.1),30,20));
  
}
void draw(){
   background(150);
   image1.beginDraw();
   //image1.clear();
   image1.endDraw();
   grow(image1);
   image(image1,0,0,width, height);
   if (t<1){
      //image1.save(String.format("frame%03d.png",frame));
    }else{
      print(merges);
      exit();
    }
   
   t+=.05;
   frame++;
}

void grow(PGraphics fg){
  fg.beginDraw();
  for (int repeat = 0; repeat < 60; repeat +=1){
  for(int i = branches.size()-1; i>=0; i--){
       if(!branches.get(i).onDraw(fg)){
         branches.remove(i);
       }
   }
   if (branches.size() ==0){
     if (merges>0){
       print(merges);
       merges = 0;
     }
     return;
   }
    Iterator<Branch> i1 = branches.get(0).iterator();

    while(i1.hasNext()){
      Branch branch  = i1.next();
      Iterator<Branch> i2 = branches.get(0).iterator();
      while(i2.hasNext()){
        
        Branch other = i2.next();
        if (other  == branch){ //<>//
          break;
        }
       if (branch.t>30&& pow(branch.x-other.x,2)+pow(branch.y-other.y,2)<branch.size*other.size){
        
        
        branch.size = sqrt(branch.size*branch.size +other.size*other.size);
        branch.angle = (branch.angle+other.angle)/2;
        i2.remove();
        merges++;
        break;
      }
      }
    }
   
  }
   fg.endDraw();
  
}
