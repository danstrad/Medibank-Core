package med.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class BackgroundImage extends Bitmap {

		public var finished:Boolean;
		
		protected var fadingIn:Boolean;
		protected var fadingOut:Boolean;
		protected var fadeTime:Number;
		
		public function BackgroundImage(bitmapData:BitmapData) {
			super(bitmapData, "auto", true);
			scaleX = scaleY = Math.max(BoxesMain.STAGE_WIDTH / bitmapData.width, BoxesMain.STAGE_HEIGHT / bitmapData.height);
		}
		
		public function fadeOut():void {
			if (fadingOut) return;
			fadingOut = true;
			fadingIn = false;
			fadeTime = 1000;
		}
		
		public function fadeIn():void {
			if (fadingIn) return;
			fadingIn = true;
			fadingOut = false;
			finished = false;
			alpha = 0;
			fadeTime = 1000;
		}
		
		public function animate(dTime:Number):void {
			fadeTime = Math.max(0, fadeTime - dTime);
			var f:Number = 1 - fadeTime / 1000;
			var eased:Number = Utils.easeOut(f);
			if (fadingOut) {
				alpha = 1 - eased;
				if (f >= 1) {
					finished = true;
					fadingOut = false;
				}
			} else if (fadingIn) {
				alpha = eased;				
				if (f >= 1) {
					fadingIn = false;
				}
			}
		}

	}

}