package med.infographic {
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	
	public class SpinNumberComma extends _SpinNumberComma {

		public var isNew:Boolean = true;
		
		public function SpinNumberComma() {
			
		}

		
		protected static const OFFSET_Y:Number = 50;
		protected static const ANIMATE_DURATION_SEC:Number = 0.3;
		
		
		public function animateOn():void {
			TweenMax.fromTo(this, ANIMATE_DURATION_SEC, { alpha:0, y:0-OFFSET_Y }, { alpha:1, y:0, ease:Sine.easeIn, immediateRender:true } );
		}
		
		public function animateOff():void {
			TweenMax.to(this, ANIMATE_DURATION_SEC, { alpha:0, y:0+OFFSET_Y, ease:Sine.easeOut, immediateRender:true, onComplete:remove } );
		}		
	
		public function remove():void {
			if (parent) parent.removeChild(this);
		}
		
	}

}