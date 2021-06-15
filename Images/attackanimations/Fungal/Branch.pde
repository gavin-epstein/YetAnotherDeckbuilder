import java.util.Iterator;
static final float seekangle = .002*PI;
public class Branch implements Iterable{
  static final float branchchance = .01;
  float angle;
  float x;
  float y;
  int t;
  float size;
  ArrayList<Branch> branches;
  Branch self;
  
  Branch(float inx, float iny, float inangle, float insize){
    this( inx,  iny,  inangle,  insize, 0);
  }
  Branch(float inx, float iny, float inangle, float insize, int tin){
    x=inx;
    y=iny;
    angle = inangle;
    size= insize;
    t = tin;
    branches = new ArrayList();
    self = this;
  }
  
  void copy(Branch branch){
    x=branch.x;
    y=branch.y;
    angle = branch.angle;
    size= branch.size;
    t=branch.t;
    self.branches.addAll(branch.branches);
  }
  
  boolean onDraw(PGraphics canv){
    if (size<2){
      return false;
     }
    canv.stroke(0,0,0,0);
   
    canv.fill(255,236,195,255);
    canv.ellipse(x,y,.8*size,.8*size);
    
    x+= .1*size * cos(angle);
    y+= .1*size* sin(angle);
    canv.fill(0,0,0,min(70, 3*size));
    canv.ellipse(x,y,size,size);
   // size *= random(.999,1);
    angle += .2*random(-.05,.05);
    if (size < 10){
      angle += .2*random(-.1,.1);
    }
    if (size < 30){
      angle += .2*random(-.1,.1);
    }
    float bestangle = 0;
    float bestscore =0;
    for (float da:new Float[]{-1*seekangle, 0.0, seekangle}){
      float testx = x+.1*size*cos(angle+da);
      float testy = y+.1*size*sin(angle+da);
      float testscore = Score(testx, testy);
      if ( testscore>bestscore){
        bestscore = testscore;
        bestangle = da;
      }
    }
    angle +=bestangle;
    
   
    if ((size <10 && random(0,1)<.2*branchchance)
         || ( size>4 && random(0,100/(t+1)) < branchchance)){
       float newsize = size /1.414;
       branches.add(new Branch(x,y,angle-.25*PI,newsize));
       size =newsize;
     
       angle +=.25*PI;
       t=0;
    }
    for(int i = branches.size()-1; i>=0; i--){
       if(!branches.get(i).onDraw(canv)){
         branches.remove(i);
       }
    }
 
    
    t++;
    return true;
    
  }

  
  public Iterator<Branch> iterator(){
    return new Iterator(){
       int index = -1;
       Iterator<Branch> branchIterator;
       public Branch next(){
         if (index ==-1){
           index = 0;
           return self;
         } else if (branchIterator == null){
           //branchIterator = branches.get(0).iterator();
         }
         if (branchIterator.hasNext()){
           return branchIterator.next();
         } else {
           index++;
           branchIterator = branches.get(index).iterator();
           return branchIterator.next(); 
         }
       }
       
       public boolean hasNext(){
         if (index ==-1){
           return true;
         } else if (branchIterator == null){
           if (branches.size() ==0){
             return false;
           }
           
           branchIterator = branches.get(0).iterator();
         }
         if (branchIterator.hasNext()){
           return true;
         } else {
           return index+1 < branches.size();
         }
         
         
       }
       public void remove(){
         if (branchIterator == null){
           if (branches.size() ==0){
             self.size= 0;
             return;
           }
           Branch replace = branches.get(branches.size()-1);
           branches.remove(branches.get(branches.size()-1));
           copy(replace);
         }else{
           branchIterator.remove();
         }
       }
       
       
    };
    
  }
  
  float Score(float x,float y){
    
    return 10-(pow((.9-x/width),2)+ pow((.9-y/height),2)) ;
  }
  
  
  
}
