package med.display {
	import flash.display.Sprite;
	import flash.geom.Point;

	public class ClickBlip extends Sprite {

		protected static const ZERO_POINT:Point = new Point(0, 0);
		public static const SIZE:Number = Box.SIZE;
		
		static public const TIME:Number = 500;

		public var finished:Boolean;
		
		protected var sourceWidth:Number;
		protected var sourceHeight:Number;
		
		protected var minInflation:Number;
		protected var maxInflation:Number;
		
		public var box:Box;
		private var timeRemaining:Number;
		
		public function ClickBlip(box:Box) {
			this.box = box;
			timeRemaining = TIME;
			
			sourceWidth = box.getWidth();
			sourceHeight = box.getHeight();
			minInflation = Box.SIZE * -0.05;
			maxInflation = Box.SIZE * 0.8;
			
			redraw(0);
		}

		public function animate(dTime:Number):void {
			timeRemaining -= dTime;
			if (timeRemaining <= 0) {
				visible = false;
				finished = true;
			} else {
				var f:Number = 1 - timeRemaining / TIME;
				redraw(f);
				alignToBox();
			}
		}
		
		protected function redraw(f:Number):void {
			var eased:Number = Utils.easeOut(f);
			var margin:Number = 2 + 1.5 * eased;
			var a:Number = 1;
			if (eased > 0.7) a = 1 - (eased - 0.7) / (1 - 0.7);
			graphics.clear();
			graphics.beginFill(0xFFFFFF, a);
			var xRad:Number = (sourceWidth / 2) + (minInflation + (maxInflation - minInflation) * eased);
			var yRad:Number = (sourceHeight / 2) + (minInflation + (maxInflation - minInflation) * eased);
			graphics.drawRect(-xRad, -yRad, xRad * 2, yRad * 2);
			graphics.drawRect(-xRad + margin, -yRad + margin, xRad * 2 - margin * 2, yRad * 2 - margin * 2);
			graphics.endFill();
		}
		
		protected function alignToBox():void {
			if (!stage || !box.stage) return;
			x = box.parent.x + box.getX();
			y = box.parent.y + box.getY();
		}
		
	}

}