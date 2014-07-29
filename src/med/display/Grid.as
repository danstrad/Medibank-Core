package med.display {
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Grid extends Shape {

		protected var w:Number;
		protected var h:Number;
		
		public function Grid() {
			graphics.lineStyle(0, 0xFF0000);
			w = BoxesMain.STAGE_WIDTH;
			h = BoxesMain.STAGE_HEIGHT;
			var step:Number = Box.SIZE;// / 6;
			var n:int;
			for (var i:int = 0; i < w; i += step) {
				for (n = 0; n < 6; n++) {
					graphics.moveTo(i + n * step / 6, 0);
					graphics.lineTo(i + n * step / 6, h);
				}
			}
			for (var j:int = 0; j < h; j += step) {
				for (n = 0; n < 6; n++) {
					graphics.moveTo(0, j + n * step / 6);
					graphics.lineTo(w, j + n * step / 6);
				}
			}
		}
		
		public function focus(focus:Point):void {
			var step:Number = Box.SIZE / 6;
			x = Math.round((focus.x - w / 2) / step) * step;
			y = Math.round((focus.y - h / 2) / step) * step;
		}
		
		

	}

}