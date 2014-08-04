package med.infographic {
	import com.greensock.easing.ExpoIn;
	import com.greensock.easing.ExpoOut;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import org.flashdevelop.utils.FlashConnect;
	
	
	public class SpinNumberSlot extends _SpinNumberSlot {

		protected var startValue:int;
		protected var targetValue:int;
		
		public var isSpinning:Boolean = false;
		protected var isDecelerating:Boolean = false;

		public var speed:Number;

		protected var currentSpinTimeMsec:Number;
		protected var currentDistanceSpun:Number;
		
		protected var decelerationSpinTimeMsec:Number;
		
		protected var accelerationDistance:Number;
		protected var decelerationDistance:Number;
		
		protected var topBlock:Sprite;
		protected var bottomBlock:Sprite;
					
		
		public static const MIN_SPIN_TIME_SECS:Number = 3.0;
		protected static const MAXIMUM_SPEED:Number = 1.5;
		
		public static const ACCELERATION_DURATION_SECONDS:Number = 1.0;
		
		
		
		public function SpinNumberSlot() {
			
			// per matt's suggestion that the starting value should be random
			startValue = Rndm.integer(0, 10);
						
			block2.y = SpinNumberSlide.ENTRY_HEIGHT + (startValue * SpinNumberSlide.ENTRY_HEIGHT);			
			block1.y = block2.y - (30 * SpinNumberSlide.ENTRY_HEIGHT);
			
		}

		
		
		
		public function startSpinning(targetValue:int, delayMsec:Number):void {
			if (isSpinning)	return;
			
			trace(name + " startValue " + startValue + ", targetValue: " + targetValue);
			
			this.targetValue = targetValue;
			
//			debugField.text = startValue + ">" + targetValue;
			
			isSpinning = true;
			isDecelerating = false;			
			speed = 0; 
			
			TweenMax.fromTo(this, ACCELERATION_DURATION_SECONDS, { blurFilter:{blurY:0} }, { blurFilter:{blurY:12}, immediateRender:true, ease:ExpoIn.ease, delay:delayMsec/1000 } );
			

			currentSpinTimeMsec = 0;
			currentDistanceSpun = 0;
			
			accelerationDistance = 0;
			decelerationDistance = 0;
		}
		
		
		
		protected function reachedFullSpeed():void {
			accelerationDistance = currentDistanceSpun;
//			trace("Acceleration distance: "+accelerationDistance);
		}
		
		
		
		protected static const ONE_ROTATION_Y:Number = (10 * SpinNumberSlide.ENTRY_HEIGHT);
		
		
		protected var targetDistance:Number;
		
		public function stopSpinning(delayMsec:Number):void {
			
			// we need to figure out how much further we need to go from this point to reach our target value			
			// from 5->6 is 1 * ENTRY_HEIGHT			
			// from 0->9 is 9 * ENTRY_HEIGHT
			
			var valueDelta:int = targetValue - startValue;
			if (targetValue < startValue) valueDelta = 10 - Math.abs(valueDelta);
			
			var minimumDistance:Number = valueDelta * SpinNumberSlide.ENTRY_HEIGHT;
			
			// we should complete one more revolution + the minimum distance to land correctly on the target value
					
			// so how far do we need to rotate to get back to the starting value
			targetDistance = ONE_ROTATION_Y - (currentDistanceSpun % ONE_ROTATION_Y);
	
			// add the minimum distance to that
			targetDistance += minimumDistance;

			
			// our stopping distance is equal to our acceleration distance
//			trace(this.name + ".stopSpinning() - accelerationDistance: " + accelerationDistance+ ", minimumDistance: " + minimumDistance+", targetDistance: " + targetDistance); 
			
			// try something new. immediately cut animate() out of the picture
			// tween to final result
			isSpinning = false;
			
			var topTargetY:Number = topBlock.y + targetDistance;
			var bottomTargetY:Number = bottomBlock.y + targetDistance;			
			
			var stopDuration:Number = ACCELERATION_DURATION_SECONDS + (Rndm.integer(0, 500) / 1000);
			
			TweenMax.to(this, stopDuration, { blurFilter: { blurY:0 }, ease:ExpoOut.ease, delay:delayMsec/1000, onComplete:stopped } );
			
			TweenMax.to(topBlock, stopDuration, { y:topTargetY, ease:ExpoOut.ease, delay:delayMsec/1000 } );
			TweenMax.to(bottomBlock, stopDuration, { y:bottomTargetY, ease:ExpoOut.ease, delay:delayMsec/1000 } );
			
			
//			TweenMax.to(this, ACCELERATION_DURATION_SECONDS, { blurFilter:{blurY:0}, ease:ExpoOut.ease } );
			
//			TweenMax.to(this, (speed / MAXIMUM_SPEED) * ACCELERATION_DURATION_SECONDS, { speed:0, blurFilter:{blurY:0}, ease:ExpoOut.ease, delay:delayMsec * 0.001, onComplete:stopped } );
		}
	
		
		
		
		protected function stopped():void {
			isSpinning = false;
			startValue = targetValue;
		}
		
		
			
		
		public function spin(dTime:Number):void {
			if (!isSpinning)	return;

			
			var accelerationDurationMsec:Number = (ACCELERATION_DURATION_SECONDS * 1000);
			
			var p:Number;
			var ratio:Number;
			
			
			if ((currentSpinTimeMsec <= accelerationDurationMsec) || (!isDecelerating && (speed < MAXIMUM_SPEED))) {
				p = currentSpinTimeMsec / accelerationDurationMsec;
				ratio = ExpoIn.ease.getRatio(p);
				speed = Math.min(MAXIMUM_SPEED, ratio * MAXIMUM_SPEED);
				
//				trace(currentSpinTimeMsec, accelerationDurationMsec, p, speed);

				if (speed == MAXIMUM_SPEED) {
					reachedFullSpeed();
				}
			
			} 
			/*
			else if (isDecelerating && (speed > 0)) {
				
				p = 1.0 - (decelerationSpinTimeMsec / accelerationDurationMsec);
				ratio = ExpoIn.ease.getRatio(p);
				speed = Math.max(0, ratio * MAXIMUM_SPEED);
				
//				trace(decelerationSpinTimeMsec, accelerationDurationMsec, p, speed);
				
//				if (name == "instance263") {
//					trace(decelerationSpinTimeMsec, p, ratio, speed);
//				}

			}
			*/
			
			var moved:Number = speed * dTime; 

	
			
			
			
			block1.y += moved;
			block2.y += moved;
			
			if (block1.y < block2.y) {
				topBlock = block1;
				bottomBlock = block2;
			} else {
				topBlock = block2;
				bottomBlock = block1;
			}
			
			
			// if one block has moved too far down, put it back on the top
			if (bottomBlock.y > (2 * ONE_ROTATION_Y)) {
				bottomBlock.y = topBlock.y - (SpinNumberSlide.ENTRY_HEIGHT * 30); 
			}

			currentSpinTimeMsec += dTime;
			currentDistanceSpun += moved;			
						
			
			if (isDecelerating) {
				decelerationSpinTimeMsec += dTime;
				
				decelerationDistance += moved;
				
				if (speed == 0) {
					stopped();
//					trace("stopped - stopping distance ", decelerationDistance, "accelerationDistance", accelerationDistance);
				}				
			}
			

			if (!isDecelerating && (currentSpinTimeMsec > ((MIN_SPIN_TIME_SECS - ACCELERATION_DURATION_SECONDS) * 1000))) {
				isDecelerating = true;
				decelerationSpinTimeMsec = 0;
				stopSpinning(Rndm.integer(0, 50));
			}

			
		}
		
		
		
	}

}