package med.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class ImageContent extends Sprite {
		
		protected var baseWidth:Number;
		protected var baseHeight:Number;
		protected var padding:Number;
		
		protected var bitmap:Bitmap;
		protected var scrollMask:Sprite;
		
		protected var scrollMarginX:Number;
		protected var scrollMarginY:Number;

		public function ImageContent(bitmapData:BitmapData, width:Number, height:Number, scrollMargin:Number):void {			
			scrollMarginX = scrollMarginY = scrollMargin;
			if (scrollMargin > 0) {
				var aspect:Number = width / height;
				if (aspect > 1) {
					scrollMarginX *= aspect;
				} else {
					scrollMarginY /= aspect;
				}
			}
			
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
			
			baseWidth = width;
			baseHeight = height;

			padding = 0;
			
			resize();
			
		}
		
		protected function resize():void {
			var w:Number = baseWidth + padding;
			var h:Number = baseHeight + padding * (baseHeight / baseWidth);
			
			bitmap.width = w + scrollMarginX * 2;
			bitmap.height = h + scrollMarginY * 2;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;

			if ((scrollMarginX) > 0 || (scrollMarginY > 0)) {
				if (!scrollMask) {
					scrollMask = new Sprite();
					scrollMask.visible = false;
					addChild(scrollMask);
					bitmap.mask = scrollMask;
				}
				scrollMask.graphics.clear();
				scrollMask.graphics.beginFill(0xFFFFFF);
				scrollMask.graphics.drawRect(-w / 2, -baseHeight / 2, w, baseHeight);
				scrollMask.graphics.endFill();
			}			
		}
		
		public function setPadding(value:Number):void {
			padding = value;
			resize();
		}

		public function scrollTo(xDif:Number, yDif:Number):void {
			//trace(scrollMargin);
			if ((scrollMarginX == 0) && (scrollMarginY == 0)) return;
			
			const SCROLL_FACTOR:Number = 0.08;
			var xF:Number = Math.max( -1, Math.min(1, xDif * SCROLL_FACTOR / scrollMarginX));
			var yF:Number = Math.max( -1, Math.min(1, yDif * SCROLL_FACTOR / scrollMarginY));
			
			//dx = ((dx > 0) ? 1 : -1) * Math.pow(Math.abs(dx), 1.5)
			// ease dx/dy?
			
			bitmap.x = -bitmap.width / 2 + scrollMarginX * xF;
			bitmap.y = -bitmap.height / 2 + scrollMarginY * yF;
			
		}
		
		

		
		
	}

}