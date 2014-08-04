package med.infographic {
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class SpinNumberSlot extends _SpinNumberSlot {

		
		public var value:int;
		
		public var isSpinning:Boolean = false;
		
		
		public static const MIN_SPIN_TIME_SECONDS:Number = 1.0;
		
		
		
		public function SpinNumberSlot() {
			
			block1.y = -738;
			block2.y = 80;
			
		}

		
		public function startSpinning():void {
			
			isSpinning = true;
			addEventListener(Event.ENTER_FRAME, onSpinFrame, false, 0, true);
			
		}
		
		
		
		protected function onSpinFrame(e:Event):void {
			
			var moved:Number = 0;
			
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
			
			
			// if one block has moved too far up, put it back on the bottom
			if (topBlock.y < (SpinNumberSlide.ENTRY_HEIGHT * 10)) {
				topBlock.y = bottomBlock.y + (SpinNumberSlide.ENTRY_HEIGHT * 9.5); 
			}
			
		}
		
		
		
		
	}

}