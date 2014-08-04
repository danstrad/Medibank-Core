package med.display {
	import fl.motion.Color;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class Background extends Sprite {
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var animating:Boolean;
		protected var animLength:Number;
		protected var animProgress:Number;
		protected var startColor:uint;
		protected var targetColor:uint;
		protected var currentColor:uint;
		public function getColor():uint { return currentColor; }
		public function getTargetColor():uint { return targetColor; }
		
		public function Background(width:Number, height:Number) {
			_height = height;
			_width = width;
			currentColor = 0x0;
			animating = false;			
		}
		
		public function showColor(color:uint):void {
			animating = false;
			redraw(color);
		}
		public function fadeToColor(color:uint, animLength:Number):void {
			this.animLength = animLength;
			animProgress = 0;
			startColor = currentColor;
			targetColor = color;
			animating = true;
		}
		
		protected function redraw(color:uint):void {
			currentColor = color;
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		public function animate(dTime:Number):void {
			if (!animating) return;
			animProgress += dTime;
			if (animProgress >= animLength) {
				redraw(targetColor);
				animating = false;
			} else {
				var f:Number = animProgress / animLength;
				redraw(Color.interpolateColor(startColor, targetColor, f));
			}
		}
		
	}

}