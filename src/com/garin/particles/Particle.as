package com.garin.particles {
	import flash.events.Event;
	
	public class Particle {
		
		public var xPos:Number = 0;
		public var yPos:Number = 0;
		
		public var xThrust:Number = 0;
		public var yThrust:Number = 0;
		public var thrust:Number = 0;
		
		public var lifetime:uint = 0;
		public var active:Boolean = false;
		public var next:Particle;

		public var color:uint;	
		
		public function Particle() {}

	}
}