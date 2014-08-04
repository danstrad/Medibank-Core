package med.infographic {
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class SpinNumberSlot extends _SpinNumberSlot {

		
		public var value:int;
		
		public var isSpinning:Boolean = false;
		
		
		public static const MIN_SPIN_TIME_SECONDS:Number = 1.0;
		
//		public static const 
		
		
		public function SpinNumberSlot() {
			
			block1.y = -738;
			block2.y = 80;
			
		}

		
		public function startSpinning():void {
			
			isSpinning = true;
			
		}
		
		
		
		public function spin(dTime:Number):void {
			if (!isSpinning)	return;
			
			// temp, needs acceleration
			var moved:Number = 0.01 * dTime;
			
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
			if (bottomBlock.y > ((BoxesMain.STAGE_HEIGHT * 0.5) + SpinNumberSlide.ENTRY_HEIGHT)) {
				bottomBlock.y = topBlock.y - (SpinNumberSlide.ENTRY_HEIGHT * 10); 
			}
			
		}
		
		
		
		
	}

}