package com.garin.animation {
	import flash.display.BitmapData;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	/**
	 * Data structure for BitmapSequence
	 * @author Daniel Stradwick "garin"
	 */
	
	public class BitmapFrame {
		
		public var xOffset:Number;
		public var yOffset:Number;
		public var bitmapData:BitmapData;
		
		public function BitmapFrame(bitmapData:BitmapData, xOffset:Number, yOffset:Number) {
			this.bitmapData = bitmapData;
			this.xOffset = xOffset;
			this.yOffset = yOffset;			
		}
		

		public static function renderFromClip(source_clip:DisplayObject, relativeTo:DisplayObject, scale:Number=1.0, pixelBuffer:int=0):BitmapFrame { 
			var bounds:Rectangle = relativeTo.getBounds(source_clip);
			
			// use pixelBuffer to adjust bounds
			bounds.x -= pixelBuffer;
			bounds.y -= pixelBuffer;
			bounds.width += pixelBuffer * 2;
			bounds.height += pixelBuffer * 2;						
			
			// push it over so nothing will be in "negative" space and it'll draw into the 0,0 aligned bitmap						
			var matrix:Matrix = new Matrix(scale, 0, 0, scale, -bounds.left * scale, -bounds.top * scale);
			var bmd:BitmapData = new BitmapData(Math.ceil(bounds.width * scale), Math.ceil(bounds.height * scale), true, 0x00000000);
			bmd.draw(source_clip, matrix);
					
			return new BitmapFrame(bmd, bounds.left, bounds.top);
		}				
		
		
	}

}