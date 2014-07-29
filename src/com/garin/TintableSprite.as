package com.garin {
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.filters.BitmapFilter;
	
	/**
	 * Sprite with built in methods for easily adjusting color & brightness
	 * @author Daniel Stradwick "garin"
	 */
	
	public class TintableSprite extends Sprite {
		
		public function TintableSprite() {
			super();
		}
		
		public function tint(color:uint, strength:Number=1.0):void {
			Tinting.setTint(this, color, _brightness, strength);
		}		
		
		/* should be in the range of -1 to 1 */
		public function get brightness():Number { return _brightness; }
		private var _brightness:Number = 0;	
		
		
		public function set brightness(b:Number):void { 
			Tinting.setBrightness(this, b);
			_brightness = b;			
		}
		
		
		
		private var _storedFilters:Array = [];
		
		public function addFilter(f:BitmapFilter, toEnd:Boolean=true):Boolean {
			for each (var sf:BitmapFilter in _storedFilters)  
				if (sf == f)  return false;
			
			if (_storedFilters.length) {
				
				if (toEnd)		_storedFilters.push(f);
				else 			_storedFilters.unshift(f);
				
			} else	_storedFilters = [f];
			
			this.filters = _storedFilters.slice();
			return true;
		}
			
		public function removeFilter(f:BitmapFilter):void {
			for (var i:int = _storedFilters.length-1; i >= 0; i--)
				if (_storedFilters[i] == f) {
					_storedFilters.splice(i, 1);
				}			
			this.filters = _storedFilters.slice();
		}		
		
		public function clearFilters():void {
			_storedFilters = [];
			this.filters = null;
		}
		
	}

}