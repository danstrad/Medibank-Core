package com.garin {
	import flash.events.MouseEvent;
	
	/**
	 * For numbers you scroll through with interface elements, handles busywork
	 * @author Daniel Stradwick "garin"
	 */
	
	public class InterfaceScrollSetting {
		
		public var value:Number = 1;
		private var minValue:Number = 1;
		private var maxValue:Number = 1;
		private var wraps:Boolean;
		private var decrementCallback:Function = null;
		private var incrementCallback:Function = null;
		
		
		public function InterfaceScrollSetting(startValue:Number, minValue:Number, maxValue:Number, wraps:Boolean=true, incrementCallback:Function=null, decrementCallback:Function=null) {
			this.value = startValue;
			this.minValue = minValue;
			this.maxValue = maxValue;
			this.wraps = wraps;
			this.incrementCallback = incrementCallback;
			this.decrementCallback = decrementCallback;
		}
	
		public function increment(e:MouseEvent=null):void {
			this.value++;
			if (value > maxValue) {
				if (wraps) 	value = minValue;
				else		value = maxValue;
			}
			if (incrementCallback != null) incrementCallback();
		}
		
		public function decrement(e:MouseEvent=null):void {
			this.value--;
			if (value < minValue) {
				if (wraps) 	value = maxValue;
				else		value = minValue;
			}
			if (decrementCallback != null) decrementCallback();
		}		
		
	}

}