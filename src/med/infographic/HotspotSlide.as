package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class HotspotSlide extends Sprite implements ISlide {
		
		public function get displayDurationSeconds():Number { return 0; }
		
		//76b82a
		
		protected var bitmap:Bitmap;
		protected var intro:MovieClip;
		
		protected var hotspotsLayer:Sprite;
		
		public function HotspotSlide(slideData:InfographicSlideData, color:uint) {
		
			var W:Number = 1024;
			var H:Number = 576;
			
			var data:Object; // = slideData.data;
			
			var url:String = data.backgroundURL;
			if (url) {
				var bmd:BitmapData = AssetManager.getImage(url);
				bitmap = new Bitmap(bmd);
				addChild(bitmap);
				if (data.backgroundScale) bitmap.scaleX = bitmap.scaleY = data.backgroundScale;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				bitmap.alpha = 0;
			}
			
			if (data.introExplanationText || data.introInstructionsText) {
				intro = new _HotspotIntroAssets();
				if (data.introExplanationText) intro.explanationField.text = data.introExplanationText;
				else intro.explanationField.visible = false;
				if (data.introInstructionsText) intro.instructionsField.text = data.introInstructionsText;
				else intro.instructionsField.visible = false;
			}
			
			hotspotsLayer = new Sprite();
			for each(var o:Object in data.hotspots) {
				var expander:HotspotExpander = new HotspotExpander(o.text, o.imageURL);
				expander.x = o.x;
				expander.y = o.y;
				hotspotsLayer.addChild(expander);
			}
			
		}
		
		public function animateOff(callback:Function):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			callback(this);
		}
		
		public function animateOn():void {
			
			var t:Number = 0;
			
			const SKIP_INTRO:Boolean = true;
			if (!SKIP_INTRO) {
				if (bitmap) {
					const BITMAP_FADE_TIME:Number = 1.5;
					TweenMax.to(bitmap, BITMAP_FADE_TIME, { alpha:0.2, ease:Quad.easeOut } ); 
					t += BITMAP_FADE_TIME;
				}
				
				if (intro) {
					const INTRO_ANIMATE_X:Number = 1400;
					intro.x = -INTRO_ANIMATE_X;
					addChild(intro);
					
					t -= 0.5;
					const INTRO_ANIMATE_TIME:Number = 1;
					TweenMax.to(intro, INTRO_ANIMATE_TIME, { x:0, delay:t, ease:Quad.easeOut } ); 
					t += INTRO_ANIMATE_TIME;
					t += 5;
					TweenMax.to(intro, INTRO_ANIMATE_TIME, { x:INTRO_ANIMATE_X, delay:t, ease:Quad.easeIn } ); 
					t += INTRO_ANIMATE_TIME;			
				}
			}
			
			if (bitmap) {
				const BITMAP_OPAQUE_TIME:Number = 1.5;
				TweenMax.to(bitmap, BITMAP_OPAQUE_TIME, { alpha:1, delay:t, ease:Quad.easeOut } ); 
				t += BITMAP_OPAQUE_TIME;
			}

			addChild(hotspotsLayer);
			hotspotsLayer.alpha = 0;
			const HOTSPOTS_OPAQUE_TIME:Number = 1.5;
			TweenMax.to(hotspotsLayer, HOTSPOTS_OPAQUE_TIME, { alpha:1, delay:t, ease:Quad.easeOut, onComplete:onHotspotsAppeared } ); 
			t += HOTSPOTS_OPAQUE_TIME;
			
		}
		
		protected function onHotspotsAppeared():void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		protected function handleMouseDown(event:MouseEvent):void {
			var expander:HotspotExpander = event.target as HotspotExpander;
			if (!expander) return;
			if (expander.canToggle) {
				expander.toggle();
				if (expander.expanded) {
					expander.parent.setChildIndex(expander, expander.parent.numChildren - 1);
				} else {
					expander.parent.setChildIndex(expander, 0);
				}
			}			
		}
		
	}

}