package com.garin {
	import flash.geom.ColorTransform;
	
	/**
	 * Color value handling and manipulation
	 * Includes some code by nsDevaraj (nsdevaraj.wordpress.com)
	 * @author Daniel Stradwick "garin"
	 */
	
	public class ColorFunctions {
		
		/* TODO
		var argb  : int = (alpha<<24)|rgb;
		var rgb   : int = 0xFFFFFF & argb;
		var alpha : int = (argb >> 24) & 0xFF;
		*/
		
		public static function extractRed(c:uint):uint {
			return (( c >> 16 ) & 0xFF);
		}
		 
		public static function extractGreen(c:uint):uint {
			return ( (c >> 8) & 0xFF );
		}
		 
		public static function extractBlue(c:uint):uint {
			return ( c & 0xFF );
		}

		public static function combineRGB(r:uint,g:uint,b:uint):uint {
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}

		public static function combineRGBfromArray(rgb:Array):uint {
			return combineRGB(rgb[0], rgb[1], rgb[2]);
		}
		
		public static function getHexRGBString(color:uint):String {
			var r:String = extractRed(color).toString(16);
			if (r.length == 1)	r += "0";
			
			var g:String = extractGreen(color).toString(16);
			if (g.length == 1)	g += "0";
			
			var b:String = extractBlue(color).toString(16);
			if (b.length == 1)	b += "0";
			
			return r + g + b;
		}
		
		
		public static function extractRGB(c:uint):Object {
			var o:Object = new Object();
			o.red = extractRed(c);
			o.blue = extractBlue(c);
			o.green = extractGreen(c);
			return o;
		}

		
		public static function extractColors(c:uint):Object {
			// more comprehensive
			var o:Object = new Object();
			o.red = extractRed(c);
			o.blue = extractBlue(c);
			o.green = extractGreen(c);
			var cmyk:Array = RGBtoCMYK(o.red, o.green, o.blue);
			o.cyan = cmyk[0];
			o.magenta = cmyk[1];
			o.yellow = cmyk[2];
			o.black = cmyk[3];			
			return o;
		}		
		
		/**
		 * @param	color 24 bit RGB
		 * @param	brightnessDelta (-1 to 1)
		 * @return	adjusted RGB values
		 */
		public static function adjustBrightness(color:uint, brightnessDelta:Number):uint {
			trace("color", color, extractRed(color), extractGreen(color), extractBlue(color));
			var hsv:Array = RGBtoHSV(extractRed(color), extractGreen(color), extractBlue(color));
			trace("hsv", hsv, "brightnessDelta", brightnessDelta);
			var endRGB:Array = HSVtoRGB(hsv[0], hsv[1], hsv[2] + brightnessDelta);
			return combineRGBfromArray(endRGB);			
		}
		
		
		
		/**
		 * RGB from the respective figures, HSV sequences in terms of returns.
		 * RGB values are as follows.
		 * R - a number from 0 to 255
		 * G - a number from 0 to 255
		 * B - a number from 0 to 255
		 *
		 * HSV values are as follows.
		 * H - a number between 360-0
		 * S - number between 0 and 1.0
		 * V - number between 0 and 1.0
		 *
		 * Can not compute, including alpha.
		 * @ Param r the red (R) indicating the number (0x00 to 0xFF to)
		 * @ Param g green (G) indicates the number (0x00 to 0xFF to)
		 * @ Param b blue (B) shows the number (0x00 to 0xFF to)
		 * @ Return HSV values into an array of [H, S, V]
		 **/
		public static function RGBtoHSV( r:Number, g:Number, b:Number ):Array
		{
			r/=255; g/=255; b/=255;
			var h:Number=0, s:Number=0, v:Number=0;
			var x:Number, y:Number;
			if(r>=g) x=r; else x=g; if(b>x) x=b;
			if(r<=g) y=r; else y=g; if(b<y) y=b;
			v=x;
			var c:Number=x-y;
			if(x==0) s=0; else s=c/x;
			if(s!=0){
				if(r==x){
					h=(g-b)/c;
				} else {
					if(g==x){
						h=2+(b-r)/c;
					} else {
						if(b==x){
							h=4+(r-g)/c;
						}
					}
				}
				
				h = h * 60;
				if(h < 0) h = h + 360;
			}
			
			return [ h, s, v ];
		}



        /**
		 * RGB from the respective figures, HSV sequences in terms of returns.
		 * RGB values are as follows.
		 * R - a number from 0 to 255
		 * G - a number from 0 to 255
		 * B - a number from 0 to 255
		 *
		 * CMYK values are as follows.
		 * C - a number between 0 to 255 representing cyan
		 * M - number between 0 to 255 representing magenta
		 * Y - number between 0 to 255 representing yellow
		 * K - number between 0 to 255 representing black
		 *
		 * Can not compute, including alpha.
		 * @ Param r the red (R) indicating the number (0x00 to 0xFF to)
		 * @ Param g green (G) indicates the number (0x00 to 0xFF to)
		 * @ Param b blue (B) shows the number (0x00 to 0xFF to)
		 * @ Return CMYK values into an array of [H, S, V] 
		 **/
		public static function RGBtoCMYK( r:Number, g:Number, b:Number ):Array
		{
			var c:Number=0, m:Number=0, y:Number=0, k:Number=0, z:Number=0;
			c = 255 - r;
			m = 255 - g;
			y = 255 - b;
			k = 255;

			if (c < k)
				k=c;
			if (m < k)
				k=m;
			if (y < k)
				k=y;
			if (k == 255)
			{
				c=0;
				m=0;
				y=0;
			}else
			{
				c=Math.round(255*(c-k)/(255-k));
				m=Math.round (255*(m-k)/(255-k));
				y=Math.round (255*(y-k)/(255-k));
			} 
			return [ c, m, y, k ];
		}
		
		
		/**
		 * HSV from each of the RGB values to determine a return as an array.
		 * RGB values are as follows.
		 * R - a number from 0 to 255
		 * G - a number from 0 to 255
		 * B - a number from 0 to 255
		 *
		 * HSV values are as follows.
		 * H - a number between 360-0
		 * S - number between 0 and 1.0
		 * V - number between 0 and 1.0
		 *
		 * H is replaced with equivalent numbers in the range of the 360-0 that is out of range.
		 * Can not compute, including alpha.
		 *
		 * @ Param h hue (Hue) number that indicates (to 360-0)
		 * @ Param s the saturation (Saturation) shows the number (0.0 to 1.0)
		 * @ Param v lightness (Value) indicates the number (0.0 to 1.0)
		 * @ Return RGB values into an array of [R, G, B]
		 **/
		public static function HSVtoRGB (h: Number, s: Number, v: Number): Array
		{
			var r: Number = 0, g: Number = 0, b: Number = 0;
			var i: Number, x: Number, y: Number, z: Number;
			if (s <0) s = 0; if (s> 1) s = 1; if (v <0) v = 0; if (v> 1) v = 1;
			h = h% 360; if (h <0) h += 360; h /= 60;
			i = h>> 0;
			x = v * (1 - s); y = v * (1 - s * (h - i)); z = v * (1 - s * (1 - h + i));
			switch (i) {
				case 0: r = v; g = z; b = x; break;
				case 1: r = y; g = v; b = x; break;
				case 2: r = x; g = v; b = z; break;
				case 3: r = x; g = y; b = v; break;
				case 4: r = z; g = x; b = v; break;
				case 5: r = v; g = x; b = y; break;
			}
			return [r * 255>> 0, g * 255>> 0, b * 255>> 0];
		}
		
        /**
		 * RGB from each of the CMYK values to determine a return as an array.
		 * CMYK values are as follows.
		 * C - a number between 0 to 255 representing cyan
		 * M - number between 0 to 255 representing magenta
		 * Y - number between 0 to 255 representing yellow
		 * K - number between 0 to 255 representing black
		 * 
		 **/
		public static function CMYKtoRGB( c:Number, m:Number, y:Number, k:Number ):Array {
			c = 255 - c;
			m = 255 - m;
			y = 255 - y;
			k = 255 - k; 
			return [(255 - c) * (255 - k) / 255, (255 - m) * (255 - k) / 255, (255 - y) * (255 - k) / 255];
		}
		

		
	}

}