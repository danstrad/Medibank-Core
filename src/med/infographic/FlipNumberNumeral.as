package med.infographic {
	import com.greensock.TweenMax;

	public class FlipNumberNumeral extends _FlipNumberNumeral {

		
		public static const SLIDE_IN_DURATION_SECS:Number = 0.5;
		
		
		protected var currentValue:int = 0;
		protected var targetValue:int = 0;
		
		
		public function FlipNumberNumeral() {
			setValue(0, true);
		}
		
		
		public function setValue(newValue:int, changeInstantly:Boolean):void {
			
			if (changeInstantly) {				
				upperHalf.numberField.text = String(newValue);
				lowerHalf.numberField.text = String(newValue);	
				this.currentValue = newValue;
				
			} else {				
				this.targetValue = newValue;	
				
				// this begins the cycle of flipping until we reach the target
				flipLowerHalf();
			}
		}
		
		
		public function slideOn():void {
			
			var xDelta:int = 800;
			
			TweenMax.fromTo(upperHalf, SLIDE_IN_DURATION_SECS, { x:-xDelta }, { x:0, immediateRender:true } );
			TweenMax.fromTo(lowerHalf, SLIDE_IN_DURATION_SECS, { x:xDelta }, { x:0, immediateRender:true } );
			
		}
		
		
		protected function flipLowerHalf():void {
			
			
			if (currentValue < targetValue) {
				currentValue++;				
			
			} else {
				// we've reached our target, break the loop
				return;
			}
			
			// change the bottom half immediately, change the upper one on a timer
			lowerHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, 0.03, { onComplete: flipUpperHalf } );
			
		}
		
		
		protected function flipUpperHalf():void {
			upperHalf.numberField.text = String(currentValue);
			
			TweenMax.to(this, 0.025, { onComplete: flipLowerHalf } );
		}
		

	}

}