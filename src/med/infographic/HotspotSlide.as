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
		
		protected const SKIP_INTRO:Boolean = false;
		
		//76b82a
		
		protected var bitmap:Bitmap;
		protected var intro:MovieClip;
		protected var disclaimer:MovieClip;
		
		protected var hotspotsLayer:Sprite;
		
		public function HotspotSlide(slideData:InfographicSlideData, color:uint) {
			
			var W:Number = 1024;
			var H:Number = 576;
			var coordScale:Number = 1 / 2.400390625;
					
			var xml:XML = slideData.xml;
			
			var hotspotColor:uint = 0x0;

			if (xml.hasOwnProperty("Background")) {
				var bgXML:XML = xml.Background[0];
				if (bgXML.hasOwnProperty("Image")) {
					var imageXML:XML = bgXML.Image[0];
					var url:String = imageXML.@url.toString();
					if (url) {
						var bmd:BitmapData = AssetManager.getImage(url);
						bitmap = new Bitmap(bmd);
						addChild(bitmap);
						var bgScale:Number = 1;
						if (imageXML.hasOwnProperty("@scale")) bgScale = parseFloat(imageXML.@scale.toString());
						bitmap.scaleX = bitmap.scaleY = bgScale * coordScale;
						bitmap.x = -bitmap.width / 2;
						bitmap.y = -bitmap.height / 2;
						bitmap.alpha = 0;
					}
					
				}
			}
			if (xml.hasOwnProperty("hotspotColor")) {
				hotspotColor = uint(xml.hotspotColor[0].toString().replace("#", "0x"));
			}
			
			if (xml.hasOwnProperty("intro")) {
				var introXML:XML = xml.intro[0];
				var explanationText:String = null;
				var instructionsText:String = null;
				if (introXML.hasOwnProperty("explanationText")) explanationText = TextUtils.safeText(introXML.explanationText[0].toString());
				if (introXML.hasOwnProperty("instructionsText")) instructionsText = TextUtils.safeText(introXML.instructionsText[0].toString());
				if (explanationText || instructionsText) {
					intro = new _HotspotIntroAssets();
					if (explanationText) intro.explanationField.text = explanationText;
					else intro.explanationField.visible = false;
					if (instructionsText) intro.instructionsField.text = instructionsText;
					else intro.instructionsField.visible = false;
				}				
			}
			if (xml.hasOwnProperty("disclaimer")) {
				var disclaimerText:String = TextUtils.safeText(xml.disclaimer[0].toString());
				disclaimer = new _HotspotDisclaimerAssets();
				disclaimer.disclaimerField.text = disclaimerText;
			}
			
			
			hotspotsLayer = new Sprite();
			for each(var hotspotXML:XML in xml.hotspot) {
				var expanderTitle:String = null;
				var expanderText:String = null;
				var expanderImageURL:String = null;
				var expanderDir:String = null;
				if (hotspotXML.hasOwnProperty("Title")) expanderTitle = TextUtils.safeText(hotspotXML.Title[0].toString());
				if (hotspotXML.hasOwnProperty("Text")) expanderText = TextUtils.safeText(hotspotXML.Text[0].toString());
				if (hotspotXML.hasOwnProperty("Image")) expanderImageURL = hotspotXML.Image[0].@url.toString();
				if (hotspotXML.hasOwnProperty("@dir")) expanderDir = hotspotXML.@dir.toString();

				var expander:HotspotExpander = new HotspotExpander(expanderTitle, expanderText, expanderImageURL, expanderDir, hotspotColor);
				expander.x = (parseFloat(hotspotXML.@x) * coordScale) || 0;
				expander.y = (parseFloat(hotspotXML.@y) * coordScale) || 0;
				hotspotsLayer.addChild(expander);
			}
			
		}
		
		public function animateOff(callback:Function):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			callback(this);
		}
		
		public function animateOn():void {
			
			var t:Number = 0;
			
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
			
			if (disclaimer) {
				addChild(disclaimer);
				disclaimer.alpha = 0;
				TweenMax.to(disclaimer, 1, { alpha:1, delay:t, ease:Quad.easeOut } ); 
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
				if (expander.mouseWithinImage) {
					expander.showFullscreenImage();
				} else {
					expander.toggle();
					if (expander.expanded) {
						expander.parent.setChildIndex(expander, expander.parent.numChildren - 1);
					} else {
						//expander.parent.setChildIndex(expander, 0);
					}
				}
			}			
		}
		
	}

}