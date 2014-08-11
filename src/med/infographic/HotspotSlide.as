package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class HotspotSlide extends Sprite implements ISlide {
		
		public function get displayDurationSeconds():Number { return 0; }
		
		protected const TOGGLE_TIME:Number = 1000;
		
		protected const SKIP_INTRO:Boolean = false;
		
		//76b82a
		
		protected var bitmap:Bitmap;
		protected var intro:Sprite;
		protected var disclaimer:MovieClip;
		
		protected var hotspotsLayer:Sprite;		
		protected var expanders:Vector.<HotspotExpander>;
		protected var resetButton:Sprite;
		
		protected var auto:Boolean;
		
		protected var expandTime:Number;
		protected var retractTime:Number;
		protected var expandQueue:Vector.<HotspotExpander>;
		protected var retractQueue:Vector.<HotspotExpander>;
		
		protected var finishedCallback:Function;
				
		public function HotspotSlide(slideData:InfographicSlideData, color:uint, finishedCallback:Function) {
			this.finishedCallback = finishedCallback;
			
			var W:Number = 1024;
			var H:Number = 576;
			var coordScale:Number = 1 / 2.400390625;
					
			var xml:XML = slideData.xml;
			
			var hotspotColor:uint = 0x0;
			
			if (xml.hasOwnProperty("mode")) {
				auto = xml.mode[0].toString() == "auto"
			}

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
			
			hotspotColor = slideData.currentGraphColor1;
			
			if (xml.hasOwnProperty("intro")) {
				var introXML:XML = xml.intro[0];
				var cornerText:String = null;
				var splashText:String = null;
				if (introXML.hasOwnProperty("cornerText")) cornerText = TextUtils.safeText(introXML.cornerText[0].toString());
				if (introXML.hasOwnProperty("splashText")) splashText = TextUtils.safeText(introXML.splashText[0].toString());
				if (cornerText || splashText) {
					intro = new Sprite();
					if (cornerText) {
						var cornerAssets:MovieClip = new _CornerText();						
						var cornerField:TextField = cornerAssets.textField;
						cornerField.text = cornerText;
						intro.addChild(cornerField);
					}					
					if (splashText) {
						var splashField:TextField = SplashTextSlide.createTextField(splashText, 1);
						intro.addChild(splashField);
					}
				}				
			}
			if (xml.hasOwnProperty("disclaimer")) {
				var disclaimerText:String = TextUtils.safeText(xml.disclaimer[0].toString());
				disclaimer = new _HotspotDisclaimerAssets();
				disclaimer.disclaimerField.text = disclaimerText;
			}
			
			
			expanders = new Vector.<HotspotExpander>();
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

				var expander:HotspotExpander = new HotspotExpander(expanderTitle, expanderText, expanderImageURL, expanderDir, hotspotColor, !auto);
				expander.x = (parseFloat(hotspotXML.@x) * coordScale) || 0;
				expander.y = (parseFloat(hotspotXML.@y) * coordScale) || 0;
				hotspotsLayer.addChild(expander);
				expanders.push(expander);
			}
			
			if (xml.hasOwnProperty("resetButton")) {
				var resetXML:XML = xml.resetButton[0];
				var resetText:String = "Replay";
				if (resetXML.hasOwnProperty("text")) resetText = resetXML.text[0].toString();
				resetButton = ResetSlide.createResetButton(resetText);
				const MARGIN:Number = 10;
				resetButton.x = Infographic.WIDTH / 2 - resetButton.width / 2 - MARGIN;
				resetButton.y = Infographic.HEIGHT / 2 - resetButton.height / 2 - MARGIN;
				hotspotsLayer.addChild(resetButton);
			}
			
			if (auto) {
				expandTime = 0;
				retractTime = 2.5 * TOGGLE_TIME;
				expandQueue = expanders.concat();
				retractQueue = new Vector.<HotspotExpander>();
			}
			
		}
		
		public function animate(dTime:Number):void { 
			if (auto) {
				var expander:HotspotExpander;
				
				expandTime -= dTime;
				if (expandTime <= 0) {
					expandTime += TOGGLE_TIME;
					autoExpand();
				}
				
				retractTime -= dTime;
				if (retractTime <= 0) {
					retractTime += TOGGLE_TIME;
					autoRetract();
				}
			}
		}
		
		protected function autoExpand():void {
			var expander:HotspotExpander = expandQueue.shift();
			expandQueue.push(expander);
			retractQueue.push(expander);
			expander.toggle();
		}		
		protected function autoRetract():void {
			if (retractQueue.length == 0) return;
			
			var expander:HotspotExpander = retractQueue.shift();
			expander.toggle();
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
			if (expanders.length > 0) addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		public function animateOff(callback:Function):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			finishedCallback = callback;

			var t:Number = 0;			
			const FADE_TIME:Number = 0.8;
			
			if (bitmap) {
				TweenMax.to(bitmap, FADE_TIME, { alpha:0, delay:t, ease:Quad.easeOut } ); 
			}
			
			TweenMax.to(hotspotsLayer, FADE_TIME, { alpha:0, delay:t, ease:Quad.easeOut, onComplete:onHotspotsGone } ); 
			//t += HOTSPOTS_OPAQUE_TIME;			
		}		
		protected function onHotspotsGone():void {
			finishedCallback(this);
		}
		

		protected function handleMouseDown(event:MouseEvent):void {
			if (resetButton && (event.target == resetButton)) {
				animateOff(finishedCallback);
				return;
			}
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