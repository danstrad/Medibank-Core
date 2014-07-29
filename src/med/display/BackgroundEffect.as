package med.display {
	import flash.display.Sprite;

	public class BackgroundEffect extends Sprite {

		public var finished:Boolean;
		
		protected var time:Number;
		
		public function BackgroundEffect() {
			time = 0;
		}
		
		public function animate(dTime:Number):void {
			time += dTime;
		}
		
		

	}

}