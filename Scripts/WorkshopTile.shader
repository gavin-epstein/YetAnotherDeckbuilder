shader_type canvas_item;
uniform vec2 topleft = vec2(0.01, 0.0);
uniform vec2 topright;
uniform vec2 bottomleft;
uniform vec2 bottomright;
uniform float angle;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

float _cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d ) {
	vec2 res = vec2(-1.0);

	vec2 e = b-a;
	vec2 f = d-a;
	vec2 g = a-b+c-d;
	vec2 h = p-a;

	float k2 = _cross( g, f );
	float k1 = _cross( e, f ) + _cross( h, g );
	float k0 = _cross( h, e );

	// if edges are parallel, use a linear equation.
	if( abs(k2)<0.001 ) {
		res = vec2( (h.x*k1+f.x*k0)/(e.x*k1-g.x*k0), -k0/k1 );
	}
	// otherwise, it's a quadratic
	else {
		float w = k1*k1 - 4.0*k0*k2;
		if( w<0.0 ) return vec2(-1.0);
		w = sqrt( w );

		float ik2 = 0.5/k2;
		float v = (-k1 - w)*ik2;
		float u = (h.x - f.x*v)/(e.x + g.x*v);
		
		if( u<0.0 || u>1.0 || v<0.0 || v>1.0 ) {
		v = (-k1 + w)*ik2;
		   u = (h.x - f.x*v)/(e.x + g.x*v);
		}
		res = vec2( u, 1.0 - v );
	}
	
	return res;
}


void fragment(){
	vec2 topleftUV = topleft / vec2(textureSize(TEXTURE,0));  // compensates for screensize ratio
	vec2 toprightUV = topright / vec2(textureSize(TEXTURE,0));
	vec2 bottomrightUV = bottomright/ vec2(textureSize(TEXTURE,0));
	vec2 bottomleftUV =bottomleft / vec2(textureSize(TEXTURE,0));
	//vec2 pivot =invBilinear(vec2(.5,.5), topleftUV, toprightUV, bottomrightUV, bottomleftUV) ;
	vec2 pivot = (vec2(.5,.5));
	vec2 newUV = UV;
	
	newUV = invBilinear(newUV, topleftUV, toprightUV, bottomrightUV, bottomleftUV);
	
	if (newUV.x < 0.0 || newUV.x > 1.0 || newUV.y < 0.0 || newUV.y > 1.0){
		COLOR = vec4(0.0);
	}else{
		newUV = rotateUV(newUV, pivot, -1.0*angle);
		COLOR = vec4(UV.x, UV.y, 0.0,1.0);
		COLOR = texture(TEXTURE, newUV);
	}
}
