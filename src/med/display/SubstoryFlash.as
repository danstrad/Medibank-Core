package med.display {
	import flash.display.Shape;

	public class SubstoryFlash extends Shape {
	
		public static const SIZE:Number = Box.SIZE;
		public static const TIME:Number = 1500;
		public static const MAX_ALPHA:Number = 0.4;// 0.2;
		
		protected var flashing:Boolean;
		
		protected var time:Number;
		
		public function SubstoryFlash() {
			time = 0;
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect( -SIZE / 2, -SIZE / 2, SIZE, SIZE);
			graphics.endFill();
			
			alpha = 0;
		}
		
		public function flash():void {
			flashing = true;
			//time = 0;
		}

		public function animate(dTime:Number):void {
			if (flashing) {
				time += dTime;
				
				if (time >= TIME) {
					time = 0;
					flashing = false;
				}
				//time %= TIME;
				
				//var a:Number = (time / TIME) * Math.PI * 2;
				//var f:Number = (Math.sin(a) + 1) / 2;
				//alpha = f * MAX_ALPHA;
				alpha = Math.sin((time / TIME) * Math.PI) * MAX_ALPHA;
			}
		}

	}

}