package com.garin.particles {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	
	import flash.display.PixelSnapping;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import flash.events.Event;
	
	
	
	public class ParticleBurst extends Sprite {
	
		protected const WIDTH:int 	= 800;
		protected const HEIGHT:int 	= 600;
		
		protected const LIFE_START_FADE:uint	= 25;
		protected const LIFE_MAX:uint			= LIFE_START_FADE + 5;
		
		protected var maxParticles:uint;	// = 10000;
			
		protected var particleCount:uint = 0;
		protected var radians:Number = Math.PI/180;
		protected var addPTC:uint = 0;
		
		protected var rect:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
		protected var bitmapData:BitmapData;
		protected var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 0, 0, 0, 0, 0);
		protected var blur:BlurFilter = new BlurFilter(2, 2, 1);
		
		protected var first:Particle;
		protected var temp:Particle;
		
		protected var xTarget:int = 0;
		protected var yTarget:int = 0;

		protected var groundPlane:Number = 0;
		protected var gravityStrength:Number = 1;
		
		protected var color:uint;
		
		
		public function ParticleBurst(tx:uint, ty:uint, groundPlane:int=-1, gravityStrength:Number=0, colorARGB:uint=0xffffffff, particles:int=2000):void {
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			this.color = colorARGB;
			
			this.xTarget = tx;
			this.yTarget = ty;
	
			this.groundPlane = groundPlane;
			this.gravityStrength = gravityStrength;
	
			bitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);
			
			addPTC = particles;
			maxParticles = particles;
			
			first = new Particle();
			temp = first;
			
			addChild(new Bitmap(bitmapData, PixelSnapping.NEVER));

			// set up linked list
			for (var b:uint = 0; b < maxParticles; b++, temp = temp.next)
				temp.next = new Particle();
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		/*
		protected function getColor():uint {
			var c:uint;
			var roll:uint = dmf.randomInt(0, 30);
			if (roll < 20)			c = 0xffffff;
			else if (roll < 50)		c = 0xff0000;
			else					c = 0xcc3333;			
			return c + 0xFF000000;
		}
		*/
		
			
		protected function onFrame(e:Event=null):void {
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
						temp.xThrust = Math.cos(tempAng); // * root.Radians);
						temp.yThrust = Math.sin(tempAng); // * root.Radians);
						temp.thrust = 4 + Math.random() * 10;
						temp.active = true;

					//	var colRoll:uint = dmf.randomInt(0, 100);
					//	if (colRoll < 20)			temp.color = 0xFF000000;
					//	else if (colRoll < 50)		temp.color = 0xFFff0000;
					//	else 						temp.color = 0xFFcc3333;			
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