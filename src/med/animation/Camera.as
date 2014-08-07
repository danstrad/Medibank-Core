package med.animation {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Camera {
		
		static public const WIDTH:Number = 1024;// 1920;
		static public const HEIGHT:Number = 576;// 1080;

		public function get animating():Boolean { return _animating; }
		
		protected var displayObject:DisplayObject;
		protected var origin:Point;
		protected var current:Point;
		protected var float:Point;
		protected var _animating:Boolean;
		protected var start:Point;
		protected var target:Point;
		protected var startScale:Number;
		protected var scale:Number;
		protected var animProgress:Number;
		protected var animLength:Number;
		protected var easing:Number;
		protected var floatTime:Number;
		protected var waitTimeRemaining:Number;
		protected var roundFactor:Number;
		
		protected var panBounds:Rectangle;
		
		public function Camera(displayObject:DisplayObject, origin:Point) {
			this.displayObject = displayObject;
			this.origin = origin;
			start = new Point(0, 0);
			current = new Point(0, 0);
			target = new Point(0, 0);
			startScale = scale = 1;
			float = new Point(0, 0);
			floatTime = 0;
			_animating = false;
			waitTimeRemaining = 0;
			roundFactor = 1;
		}
		
		public function setScreenSize(w:Number, h:Number):void {
			roundFactor = h / BoxesMain.STAGE_HEIGHT;
			//var roundFactor:Number = 1080 / 576;
			//trace(w, h);
		}
		
		public function move(xShift:Number, yShift:Number):void {
			current.x = clampX(current.x + xShift);
			current.y = clampY(current.y + yShift);
			target.x = current.x;
			target.y = current.y;
			_animating = false;
			update();
		}
		
		public function getTarget():Point { return target.clone(); }

		public function getFocus():Point { return current.clone(); }
		public function setFocus(focus:Point):void {
			target.x = clampX(focus.x);
			target.y = clampY(focus.y);
			current.x = target.x;
			current.y = target.y;
			_animating = false;
			update();
		}
		
		public function animateTo(focusX:Number, focusY:Number, time:Number, easing:Number = 0):void {
			this.easing = easing;
			start.x = current.x;
			start.y = current.y;
			//target.x = clampX(focusX);
			//target.y = clampY(focusY);
			target.x = focusX;
			target.y = focusY;
			animProgress = 0;
			animLength = time;
			startScale = scale;
			_animating = true;
		}
		
		public function setPanArea(area:Rectangle):void {
			if (!area) {
				panBounds = null;
				return;
			}
			panBounds = area.clone();
			panBounds.inflate( -WIDTH / 2, -HEIGHT / 2);
			target.x = clampX(target.x);
			target.y = clampY(target.y);
		}
		
		
		public function wait(time:Number):void {
			waitTimeRemaining += time;
		}		
		
		public function animate(dTime:Number, dragging:Boolean):void {
			if (waitTimeRemaining > 0) {
				if (waitTimeRemaining > dTime) {
					waitTimeRemaining -= dTime;
					return;
				} else {
					dTime -= waitTimeRemaining;
					waitTimeRemaining = 0;
				}
			}
			
			if (!dragging) pullBackToBounds();
			
			if (_animating) {
				animProgress += dTime;
				if (animProgress > animLength) {
					current.x = target.x;
					current.y = target.y;
					_animating = false;
					startScale = scale = 1;
				} else {
					var f:Number = animProgress / animLength;
					var eased:Number = Utils.ease(f, easing)
					current.x = start.x + (target.x - start.x) * eased;
					current.y = start.y + (target.y - start.y) * eased;
					
					const ZOOM_OUT_SCALE:Number = 0.5;// 0.8;// 0.5;
					
					
					const SCALE_TIME:Number = 1000;
					var scaleF:Number = Math.min(1, animProgress / SCALE_TIME, (animLength - animProgress) / SCALE_TIME);
					scaleF = Math.min(scaleF, 1 - eased);
					var growing:Boolean = (animProgress <= animLength / 2);
					var smoothed:Number = Math.pow(scaleF, 0.7);
					var zoomInScale:Number = 1;// growing ? startScale : 1;
					scale = zoomInScale + smoothed * (ZOOM_OUT_SCALE - zoomInScale);
					
					scale = 1;
					
					/*
					var scaleF:Number = 1 - Math.abs((animProgress - (animLength / 2)) / animLength) * 2;
					//scaleF = Math.min(scaleF, 1 - eased);
					var growing:Boolean = (animProgress <= animLength / 2);
					var smoothed:Number = Math.pow(scaleF, 0.7);
					var zoomInScale:Number = growing ? startScale : 1;
					scale = zoomInScale + smoothed * (ZOOM_OUT_SCALE - zoomInScale);
					*/
				}
			}
			
			update();
		}
		
		protected function update():void {
			var x:Number = origin.x - (current.x + float.x) * scale;
			var y:Number = origin.y - (current.y + float.y) * scale;
			if (BoxesMain.CACHE_AND_SNAP) {
				displayObject.x = Math.round(x * roundFactor) / roundFactor;
				displayObject.y = Math.round(y * roundFactor) / roundFactor;
			} else {
				displayObject.x = x;
				displayObject.y = y;
			}
			
			displayObject.scaleX = displayObject.scaleY = scale;		
		}
		
		public function animateFloat(dTime:Number):void {
			floatTime += dTime;
			var loop:Number = 15000;
			var a:Number = (floatTime / loop) * (Math.PI * 2);
			var x:Number = Math.cos(a);
			var y:Number = Math.sin(a);
			//float.y = y * 12;
			//float.x = x * 9 - y * 3;
			update();
		}
		
		public function pan(dx:Number, dy:Number):void {
			if (!panBounds) return;

			current.x -= dx;
			current.y -= dy;
			
			update();
		}
		protected function pullBackToBounds():void {
			if (!panBounds) return;
			const PULL:Number = 0.15;
			if (current.x > panBounds.right) {
				current.x -= (current.x - panBounds.right) * PULL;
			} else if (current.x < panBounds.left) {
				current.x += (panBounds.left - current.x) * PULL;
			}
			if (current.y > panBounds.bottom) {
				current.y -= (current.y - panBounds.bottom) * PULL;
			} else if (current.y < panBounds.top) {
				current.y += (panBounds.top - current.y) * PULL;
			}
		}
		
		public function clampX(x:Number):Number {
			if (!panBounds) return x;
			return Math.max(panBounds.left, Math.min(panBounds.right, x));
		}
		public function clampY(y:Number):Number {
			if (!panBounds) return y;
			return Math.max(panBounds.top, Math.min(panBounds.bottom, y));
		}
		
		public function getPanArea():Rectangle {
			return panBounds;
		}
		
		
		
		
		
		
	}

}