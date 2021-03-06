shader_type canvas_item;
uniform sampler2D mask;
const float horizontal = 2.0;
const float speed = 10.0;
const float freqdivisor = 30.0/horizontal;
float sinwave(float var, float freq, float minn, float maxx){
	return (sin(var*freq) +1.0)*(maxx-minn)/2.0 + minn ;
}
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float map(float val, float inmin, float inmax, float outmin, float outmax){
	return (val-inmin) * (outmax-outmin)/(inmax-inmin)+ outmin;	
}
void vertex(){
	float hue = 0.0;
	float val = 0.0;
	float sat = 0.0;
	float maxx = 0.0;
	float r[15];
	for (int i = 0; i<12; i++){
		for (int j = 0; j<15; j++){
			r[j] = .5*sin(.41 * float(i) + .6 * float(j));
		}
		hue += sinwave(r[0]*(UV.x+speed*TIME) + r[1]*horizontal*UV.y + r[12]*speed*TIME, (r[2] + .5)/freqdivisor, 0.0, 1.0 )*(r[3]+.5); 
		sat += sinwave(r[4]*(UV.x+speed*TIME) - r[5]*horizontal*UV.y + r[13]*speed*TIME, (r[6] + .5)/freqdivisor,0.0,1.0)*(r[7]+.5); 
		val += sinwave(r[8]*(UV.x+speed*TIME) + r[9]*horizontal*UV.y + r[14]*speed*TIME, (r[10] + .5)/freqdivisor,0.0,1.0)*(r[11] + .5);
		maxx++;
	}
	hue= map(hue, 0.0, maxx, 0.0, 4.0);
	while(hue>=1.0){
		hue -= 1.0;
	}
	hue = map(hue,0.0,1.0, .45 , .6);
	sat = map(sat,0.0,maxx, 0,.7);
	//val = map(val, 0.0, maxx, 0.0,1.0);
	val = map(val,0.0,maxx,.7,1.0);
	vec2 uv = vec2(UV.x/1920.0,UV.y/1080.0);
	float alpha = texture(mask,uv).g;
	vec3 rgb = hsv2rgb(vec3(hue,sat,val));
	//COLOR = vec4(texture(mask,UV.xy).g,0.0,1.0,1.0);
	COLOR = vec4(rgb.x,rgb.y,rgb.z,alpha);
}




