shader_type canvas_item;
float map(float val, float inmin, float inmax, float outmin, float outmax){
	return (val-inmin) * (outmax-outmin)/(inmax-inmin)+ outmin;	
}
void fragment(){
	COLOR = vec4(
		map(sin(UV.x*3.0-TIME*2.1) +sin(UV.y*6.4+TIME/4.0) ,-2,2,0,.3),
		map(sin(UV.x*6.1+TIME)+sin(UV.y*3.1 + TIME/3.1),-2,2,0,.2),
		map(sin(UV.x*8.3-TIME)+sin(UV.y*7.1),-2,2,0,.3),
		map(sin(UV.x*12.4-2.0*sin(TIME/6.0))+sin(UV.y*3.3+TIME),-2,2,.7,1)
	);
}

