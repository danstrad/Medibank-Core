package com.garin.animation {
	import flash.display.BlendMode;
	
	/**
	 * Data structure which hoolds useful animation info
	 * @author Daniel Stradwick "garin"
	 */
	
	 public class AnimationData {
		
		public var id:uint = 0;
		public var blendMode:String;
		public var frameDuration:int;
		
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;
		
		public function AnimationData(id:uint, frameDuration:int=0, blendMode:String="normal") {
			this.id = id;
			this.frameDuration = frameDuration;
			this.blendMode = blendMode;
		}
		
	}

}