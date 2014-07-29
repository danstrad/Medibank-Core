package med.animation {
	import flash.geom.Point;
	import med.display.Box;

	public class HighlightController {

		public var box:Box;
		public var highlighted:Boolean;
		public var returning:Boolean;
		
		public function offsetToTarget():Point { return targetOffset.subtract(currentOffset); }

		public var linkMoveAndScale:Boolean;
		
		protected var baseOffset:Point;
		protected var fromOffset:Point;
		protected var targetOffset:Point;
		protected var currentOffset:Point;
		
		protected var baseScale:Number;
		protected var fromScale:Number;
		protected var targetScale:Number;
		protected var currentScale:Number;		
		
		protected var basePad:Number;
		protected var fromPad:Number;
		protected var targetPad:Number;
		protected var currentPad:Number;		
		
		protected var baseColor:Number;
		protected var fromColor:Number;
		protected var targetColor:Number;
		protected var currentColor:Number;
		
		protected var totalTime:Number;
		protected var timeRemaining:Number;

		public var finished:Boolean;
		
		public function HighlightController(box:Box, highlighted:Boolean, x:Number, y:Number, scale:Number, pad:Number, time:Number) {
			this.box = box;
			
			baseOffset = new Point(0, 0);
			currentOffset = baseOffset.clone();
			
			baseScale = 1;
			currentScale = baseScale;
			
			basePad = 0;
			currentPad = basePad;
			
			baseColor = box.color;
			currentColor = baseColor;
			
			update(highlighted, x, y, scale, pad, time);			
		}
		public function update(highlighted:Boolean, x:Number, y:Number, scale:Number, pad:Number, time:Number):void {
			this.highlighted = highlighted;
			
			fromOffset = currentOffset.clone();
			targetOffset = new Point(x, y);

			fromScale = currentScale;
			targetScale = scale;

			fromPad = currentPad;
			targetPad = pad;

			fromColor = currentColor;
			targetColor = (highlighted ? 0xFFFFFF : baseColor);

			timeRemaining = totalTime = time;
			returning = false;
		}
		public function returnToSource():void {
			if (!returning) {
				returning = true;
				totalTime *= 0.6;
				timeRemaining = totalTime;
			}
		}
		
		public function animate(dTime:Number):void {
			if (timeRemaining < 0) return;
			timeRemaining -= dTime;
			
			var f:Number = 1 - (timeRemaining / totalTime);
			if (timeRemaining <= 0) f = 1;
			if (returning) {
				finished = (timeRemaining <= 0);
				f = 1 - f;
			}

			var easedMove:Number = Utils.easeOut(Utils.f(0, 0.5, f));
			var easedColor:Number = returning ? Utils.easeOut(Utils.f(0.3, 1, f)) : Utils.easeOut(Utils.f(0, 0.4, f));
			var easedGrow:Number = linkMoveAndScale ? easedMove : Utils.easeOut(Utils.f(0.5, 1, f));
			
			currentOffset.x = fromOffset.x + (targetOffset.x - fromOffset.x) * easedMove;
			currentOffset.y = fromOffset.y + (targetOffset.y - fromOffset.y) * easedMove;
			currentScale = fromScale + (targetScale - fromScale) * easedGrow;
			currentPad = fromPad + (targetPad - fromPad) * easedGrow;
			currentColor = interpolateColor(fromColor, targetColor, easedColor);
			
			box.setPosition(currentOffset.x, currentOffset.y, "Highlight");
			box.setScale(currentScale, "Highlight");
			box.setPadding(currentPad);
			box.setColor(currentColor);
			box.invertedBlendMode = (highlighted && (easedColor >= 0.5));
		}
		
		protected function interpolateColor(from:uint, to:uint, f:Number):uint {
			var fromR:uint = (from & 0xFF0000) >> 16;
			var fromG:uint = (from & 0xFF00) >> 8;
			var fromB:uint = (from & 0xFF);
			var toR:uint = (to & 0xFF0000) >> 16;
			var toG:uint = (to & 0xFF00) >> 8;
			var toB:uint = (to & 0xFF);
			var r:uint = uint(Math.round(fromR + (toR - fromR) * f)) << 16;			
			var g:uint = uint(Math.round(fromG + (toG - fromG) * f)) << 8;			
			var b:uint = uint(Math.round(fromB + (toB - fromB) * f))
			return r + g + b;
		}
		
		
		

	}

}