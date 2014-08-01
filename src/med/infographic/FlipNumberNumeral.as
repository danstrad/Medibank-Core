package med.infographic {
	import com.greensock.TweenMax;

	public class FlipNumberNumeral extends _FlipNumberNumeral {

		
		public static const SLIDE_IN_DURATION_SECS:Number = 0.5;
		
		protected static const DELAY_BETWEEN_TOP_AND_BOTTOM_SEC:Number = 0.07; // 0.03;
		protected static const DELAY_BEFORE_STARTING_NEXT_FLIP_SEC:Number = 0.1; // 0.025;
		
		
		protected var currentValue:int = 0;
		protected var targetValue:int = 0;
		
		
		public function FlipNumberNumeral() {
			// start blank
			setValue(-1, true);
		}
		
		
		public function setValue(newValue:int, changeInstantly:Boolean):void {
			
			// now we have "blank card" as a thing
			// pass -1 to use it
			
			if (changeInstantly) {			
				
				if (newValue == -1) {
					upperHalf.numberField.text = "";
					lowerHalf.numberField.text = "";					
				} else {				
					upperHalf.numberField.text = String(newValue);
					lowerHalf.numberField.text = String(newValue);	
				}
				
				this.currentValue = newValue;
				
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
		
		
		protected function flipLowerHalfUp():void {
						
			if (currentValue < targetValue) {
				currentValue++;							
			} else {
				// we've reached our target, break the loop
				return;
			}
			
			// change the bottom half immediately, change the upper one on a timer
			lowerHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { onComplete: flipUpperHalfUp } );
			
		}
		
		
		protected function flipUpperHalfUp():void {
			upperHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { onComplete: flipLowerHalfUp } );
		}
		

		
		
		protected function flipUpperHalfDown():void {
						
			if (currentValue > targetValue) {
				currentValue--;							
			} else {
				// we've reached our target, break the loop
				return;
			}
			
			// change the top half immediately, change the bottom one on a timer
			upperHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, DELAY_BETWEEN_TOP_AND_BOTTOM_SEC, { onComplete: flipLowerHalfDown } );
			
		}
		
		
		protected function flipLowerHalfDown():void {
			lowerHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, DELAY_BEFORE_STARTING_NEXT_FLIP_SEC, { onComplete: flipUpperHalfDown } );
		}		
		
		
		
		
	}

}