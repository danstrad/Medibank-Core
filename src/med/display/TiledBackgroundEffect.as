package med.display {
	import flash.events.Event;

	public class TiledBackgroundEffect extends BackgroundEffect {

		private static const OUT:Number = 1500;
		private static const IN:Number = 1500;
		
		private static const SIZE:Number = 80;
		private static const ALPHA:Number = 0.5;
		
		private static const RANGE:Number = 1.6;
		private static const FADE_RANGE:Number = 0.5;
		
		private var xMax:int;
		private var yMax:int;
		private var fadeSteps:int;
		private var steps:int;
		
		public function TiledBackgroundEffect() {			
			setBorders(BoxesMain.STAGE_WIDTH, BoxesMain.STAGE_HEIGHT);
		}
		
		protected function setBorders(width:int, height:int):void {
			xMax = Math.ceil((width + 1) / 2 / SIZE);
			yMax = Math.ceil((height + 1) / 2 / SIZE);
			fadeSteps = width * FADE_RANGE / SIZE;
			steps = width * RANGE / SIZE / 2;
		}

		
		override public function animate(dTime:Number):void {
			super.animate(dTime);

			graphics.clear();
			
			if (time > OUT + IN) {
				finished = true;
				return;
			}
			
			var f:Number;
			if (time >= OUT) f = 1 - (time - OUT) / IN;				
			else f = time / OUT;
			
			//var hang:Number = FADE_RANGE * 2;
			var hang:Number = FADE_RANGE;
			f = -hang + (1 + hang) * f;
			
			var off:Number = -SIZE / 2;
			
			var targetRange:Number = steps * 2 * f;
			for (var r:int = 0; r < steps * 2; r++) {
				var a:Number = (fadeSteps - Math.abs(targetRange - r)) / fadeSteps;
				if (a < 0) continue;
				graphics.beginFill(0xFFFFFF, a * ALPHA);
				for (var i:int = 0; i <= r; i++) {
					var j:int = r - i;
					if ((i > xMax) || (j > yMax)) continue;
					graphics.drawRect(off + i * SIZE, off + j * SIZE, SIZE, SIZE);
					if (i != 0) graphics.drawRect(off - i * SIZE, off + j * SIZE, SIZE, SIZE);
					if (j != 0) graphics.drawRect(off + i * SIZE, off - j * SIZE, SIZE, SIZE);
					if ((i != 0) && (j != 0)) graphics.drawRect(off - i * SIZE, off - j * SIZE, SIZE, SIZE);
				}
				graphics.endFill();
			}
			
		}
		

	}

}