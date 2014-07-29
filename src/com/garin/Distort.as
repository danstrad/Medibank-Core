package com.garin {
	import flash.geom.*;
	import flash.display.DisplayObject;
		
	/**
	 * Useful transformation methods and shortcuts
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Distort {
		
		public static function skew(target:DisplayObject, skewXdegrees:Number, skewYdegrees:Number):void {
			var mtx:Matrix = new Matrix();
			mtx.b = skewYdegrees * Math.PI/180;
			mtx.c = skewXdegrees * Math.PI/180;
			mtx.concat(target.transform.matrix);
			target.transform.matrix = mtx;
		}		
		
		
	}

}