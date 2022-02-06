//precision mediump float;
precision highp float;
uniform float Opacity;
uniform vec4 Color;
uniform vec4 ColorParent;

void main()
{
	if (ColorParent.a > 0.0)
	{
		if (gl_FragColor == ColorParent)
		{	
			gl_FragColor.xyz = Color.xyz;
			//gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
			gl_FragColor.a = Color.a * Opacity;
		} else
		gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
	
	} else
	{ 
		// for vector fonts not need texture, because use only Color
		gl_FragColor.xyz = Color.xyz;
		//gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		gl_FragColor.a = Color.a * Opacity;
	}
	
}
