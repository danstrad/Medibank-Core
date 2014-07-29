package com.garin {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.filters.BitmapFilter;
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Tinting {
		
		/* range -1 to +1 */
		public static function setBrightness(target:DisplayObject, brightness:Number):void { 
			var col:Color = new Color();
			col.brightness = brightness;	// -1 to 1
			var t:Transform = target.transform;
			t.colorTransform = col;
			target.transform = t;
		}
		
		public static function setTint(target:DisplayObject, color:uint, brightness:Number=0, strength:Number=1.0):void {
			// note that using this method will not interface well with previously adjusted brightness
			var col:Color = new Color();
			col.setTint(color, strength);			
			col.brightness = brightness;
			
			var t:Transform = target.transform;
			t.colorTransform = col;
			target.transform = t;		
		}
		
		public static function setColor(target:DisplayObject, color:uint):void {
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			target.transform.colorTransform = ct;	
		}
	
		
	}
}