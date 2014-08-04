package med.infographic {
	import com.greensock.easing.ExpoIn;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import org.flashdevelop.utils.FlashConnect;
	
	
	public class SpinNumberSlot extends _SpinNumberSlot {

		
		public var value:int;
		
		public var isSpinning:Boolean = false;
		
		
		public static const MIN_SPIN_TIME_SECONDS:Number = 1.0;
		
		
		public var speed:Number;
		
		
		public function SpinNumberSlot() {
			
			block1.y = -738;
			block2.y = 80;
			
		}

		
		
		
		public function startSpinning():void {
			
			isSpinning = true;
			
			speed = 0; // 0.1;
			
			TweenMax.fromTo(this, 1.0, { speed:0, blurFilter:{blurY:0} }, { speed:3.0, blurFilter:{blurY:8}, immediateRender:true, ease:ExpoIn.ease } );
			
			
		}
		
		
		
		public function spin(dTime:Number):void {
			if (!isSpinning)	return;
			
			// temp, needs acceleration
			var moved:Number = speed * dTime;
			
			block1.y += moved;
			block2.y += moved;
			
			var topBlock:Sprite;
			var bottomBlock:Sprite;
			
			if (block1.y < block2.y) {
				topBlock = block1;
				bottomBlock = block2;
			} else {
				topBlock = block2;
				bottomBlock = block1;
			}
			
			
			// if one block has moved too far down, put it back on the top
			if (bottomBlock.y > ((300 * 0.5) + SpinNumberSlide.ENTRY_HEIGHT)) {
				bottomBlock.y = topBlock.y - (SpinNumberSlide.ENTRY_HEIGHT * 10); 
			}
			
		}
		
		
		
		
	}

}