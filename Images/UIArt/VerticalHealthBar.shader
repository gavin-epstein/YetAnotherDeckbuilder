shader_type canvas_item;
uniform float speed = 1.0;
uniform float xdir = 2.7;
uniform float yoffset = 0.0;
uniform float r = 1.0;
uniform float g = .82;
uniform float b = .43;
float map(float val, float inmin, float inmax, float outmin, float outmax){
	return (val-inmin) * (outmax-outmin)/(inmax-inmin)+ outmin;	
}
void fragment(){
	COLOR = vec4(
		map(sin(3.14*UV.x),-1,1,0,r),
		map(sin(3.14*UV.x),-1,1,0,g),
		map(sin(3.14*UV.x),-1,1,0,b),
		map(sin(tan(xdir*(UV.x)+(6.28-xdir)*.5)+30.0*(UV.y+yoffset)+speed*TIME),-1,1,0,1)
	);
}
