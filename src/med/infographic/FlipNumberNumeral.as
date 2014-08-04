package med.infographic {
	import com.greensock.easing.ExpoIn;
	import com.greensock.easing.ExpoOut;
	import com.greensock.TweenMax;
	import flash.display.Sprite;

	public class FlipNumberNumeral extends _FlipNumberNumeral {

		
		public static const SLIDE_IN_DURATION_SECS:Number = 0.5;
		
		protected static const DELAY_BETWEEN_TOP_AND_BOTTOM_SEC:Number = 0.15; // 0.03;
		protected static const DELAY_BEFORE_STARTING_NEXT_FLIP_SEC:Number = 0.15; // 0.025;
		
		
		protected var currentValue:int = 0;
		protected var targetValue:int = 0;
				
		protected var callback:Function;
		
		protected var bgColor:uint;
				
		protected var upperHalfTemp:FlipNumberUpperHalf;
		protected var lowerHalfTemp:FlipNumberLowerHalf;
		
		
		public function FlipNumberNumeral(bgColor:uint) {
			this.bgColor = bgColor;
			
			// start blank
			setValue(-1, true);
			
			// draw the bg on the halves
			drawCardForNumeralHalf(upperHalf);
			drawCardForNumeralHalf(lowerHalf);
			
			
			lowerHalfTemp = new FlipNumberLowerHalf();
			drawCardForNumeralHalf(lowerHalfTemp);
			addChild(lowerHalfTemp);

			upperHalfTemp = new FlipNumberUpperHalf();
			drawCardForNumeralHalf(upperHalfTemp);
			addChild(upperHalfTemp);
						
			lowerHalfTemp.visible = false;
			upperHalfTemp.visible = false;
			
		}
		
		
		protected function drawCardForNumeralHalf(half:Sprite):void {
			half.graphics.beginFill(bgColor, 1);
			
			if (half is FlipNumberLowerHalf) {
				half.graphics.drawRect(-30, 0, 60, 50);
			} else {
				half.graphics.drawRect(-30, -50, 60, 50);
			}
				
			half.graphics.endFill();		
		}
		
		
		
		public function setValue(newValue:int, changeInstantly:Boolean, callback:Function=null):void {
			this.callback = callback;
			
			// now we have "blank card" as a thing
			// pass -1 to use it
			
			if (changeInstantly) {			
				
				this.currentValue = newValue;

				upperHalf.numberField.text = currentValueAsString;
				lowerHalf.numberField.text = currentValueAsString;				
				
				if (callback != null)  callback();
				
				
			} else {				
				this.targetValue = newValue;	
				
				// this begins the cycle of flipping until we reach the target
				
				if (targetValue > currentValue) {		
					// flip up
					flipLowerHalfUp();
					
				} else if (targetValue < currentValue) {
					// flip down
					flipUpperHalfDown();
					
				} else {
					// already there
					this.currentValue = targetValue;
				}
			}
		}
		
		
		/*
		public function slideOn():void {			
			var xDelta:int = 800;
			
			TweenMax.fromTo(upperHalf, SLIDE_IN_DURATION_SECS, { x:-xDelta }, { x:0, immediateRender:true } );
			TweenMax.fromTo(lowerHalf, SLIDE_IN_DURATION_SECS, { x:xDelta }, { x:0, immediateRender:true } );			
		}
		
		
		public function slideOff():void {
			// they continue to slide off in the same direction they slid in
			// ie. they don't go back the way they came
			var xDelta:int = 800;
			
			TweenMax.fromTo(upperHalf, SLIDE_IN_DURATION_SECS, { x:0 }, { x:xDelta, immediateRender:true } );
			TweenMax.fromTo(lowerHalf, SLIDE_IN_DURATION_SECS, { x:0 }, { x:-xDelta, immediateRender:true } );			
		}
		*/
		
		
		protected function get currentValueAsString():String {
			if (currentValue == -1) 	return "";
			else						return String(currentValue);
		}
		
		protected function get targetValueAsString():String {
			if (currentValue == -1) 	return "";
			else						return String(targetValue);
		}

		
		
		protected function flipLowerHalfUp():void {
						
			if (currentValue < targetValue) {
				
				// flip the old value
				lowerHalfTemp.numberField.text = currentValueAsString;
				
				currentValue++;		
				
				if (targetValue == -1) {
					// it only takes one flip to get back to blank
					currentValue = -1;	
				}
				
			} else {
				// we've reached our target, break the loop
				if (callback != null)  callback();
				return;
			}
			
			// change the bottom half immediately, change the upper one on a timer
			lowerHalf.numberField.text = currentValueAsString;
				
			lowerHalfTemp.visible = true;
			upperHalfTemp.visible = false;			
			TweenMax.fromTo(lowerHalfTemp, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { scaleY:1.0 }, { scaleY:0, immediateRender:true, onComplete: flipUpperHalfUp, ease:ExpoIn.ease} );
			
//			TweenMax.to(this, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { onComplete: flipUpperHalfUp } );
			
		}
		
		
		protected function flipUpperHalfUp():void {
			
			
			lowerHalfTemp.visible = false;
			upperHalfTemp.visible = true;			
			TweenMax.fromTo(upperHalfTemp, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { scaleY:0 }, { scaleY:1, immediateRender:true, onComplete:lockInValueUpper, ease:ExpoOut.ease } );
			
			upperHalfTemp.numberField.text = currentValueAsString;
			
			
//			TweenMax.to(this, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { onComplete: flipLowerHalfUp } );
		}
		

		protected function lockInValueUpper():void {
			upperHalf.numberField.text = currentValueAsString;
			flipLowerHalfUp();
		}
		
		protected function lockInValueLower():void {
			lowerHalf.numberField.text = currentValueAsString;
			flipUpperHalfDown();
		}		
		
		
		
		protected function flipUpperHalfDown():void {
						
			if (currentValue > targetValue) {
				
				// flip the old value
				upperHalfTemp.numberField.text = currentValueAsString;
				
				currentValue--;		
				
				if (targetValue == -1) {
					// it only takes one flip to get back to blank
					currentValue = -1;	
				}
				
			} else {
				// we've reached our target, break the loop
				if (callback != null)   callback();
				return;
			}
			
			// change the top half immediately, change the bottom one on a timer
			upperHalf.numberField.text = currentValueAsString;
			
			lowerHalfTemp.visible = false;
			upperHalfTemp.visible = true;			
			TweenMax.fromTo(upperHalfTemp, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { scaleY:1.0 }, { scaleY:0, immediateRender:true, onComplete: flipLowerHalfDown, ease:ExpoOut.ease } );
			
			
//			TweenMax.to(this, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { onComplete: flipLowerHalfDown } );
			
		}
		
		
		protected function flipLowerHalfDown():void {
//			lowerHalf.numberField.text = currentValueAsString;
			
			lowerHalfTemp.visible = true;
			upperHalfTemp.visible = false;			
			TweenMax.fromTo(lowerHalfTemp, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { scaleY:0 }, { scaleY:1, immediateRender:true, onComplete:lockInValueLower, ease:ExpoIn.ease } );
			
			lowerHalfTemp.numberField.text = currentValueAsString;
			
//			TweenMax.to(this, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { onComplete: flipUpperHalfDown } );
		}		
		
		
		
		
	}

}