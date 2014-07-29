package com.garin.particles {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class ParticleBurstHorizontal extends ParticleBurst {

		public var right:Boolean;
		
		public function ParticleBurstHorizontal(tx:uint, ty:uint, right:Boolean, groundPlane:int = -1, gravityStrength:Number = 0, colorARGB:uint = 0xffffffff, particles:int = 2000) {
			this.right = right;
			super(tx, ty, groundPlane, gravityStrength, colorARGB, particles);
		}
		
		
		override protected function onFrame(e:Event=null):void {
			bitmapData.colorTransform(rect, colorTransform);
			
			//bitmapData.applyFilter(bitmapData, rect, new Point(0,0), BlurFilt);
			bitmapData.lock();
			
			temp = first;
			
			for (var a:uint = 0; a < maxParticles; a++, temp = temp.next) {
				
				if (!temp.active) {
					
					if (addPTC > 0) {
						var tempAng:int = Math.round(Math.random() * 359);
						
						temp.xPos = xTarget;
						temp.yPos = yTarget;
						
						//temp.xThrust = Math.cos(tempAng); // * root.Radians);
						
						temp.xThrust = Math.abs(Math.cos(tempAng));
						if (right == false)	temp.xThrust *= -1;			
						
						temp.yThrust = Math.sin(tempAng); // * root.Radians);
						temp.thrust = 4 + Math.random() * 10;
						temp.active = true;

						temp.color = color;
					
						addPTC--;
						particleCount++;
					} else {
						continue;
					}
				}
				
				// apply gravity
				temp.yThrust += gravityStrength;
						
				temp.xPos +=  temp.xThrust * temp.thrust;
				temp.yPos +=  temp.yThrust * temp.thrust;
				
				// gravity.. hit the ground plane
				if (temp.yPos > groundPlane) {
					temp.yPos = groundPlane;
					if (temp.lifetime < LIFE_START_FADE)
						temp.lifetime = LIFE_START_FADE;
				}
				
				temp.lifetime++;
				
				
				if (temp.lifetime > LIFE_MAX) {
					temp.active = false;
					particleCount--;
				
				} else {
				//	if (temp.lifetime > LIFE_START_FADE) temp.color -= 0x11000000;
					bitmapData.setPixel32(temp.xPos, temp.yPos, temp.color);	
				}
			}
			
			bitmapData.unlock();
//			Count.text = PTCCount;

			// remove us
			if (particleCount <= 0) {
				removeEventListener(Event.ENTER_FRAME, onFrame);
				if (parent != null) 	parent.removeChild(this);
				//trace("particle burst removed");
			}
			
		}		
		
		
		
	}

}