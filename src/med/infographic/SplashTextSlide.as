package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class SplashTextSlide extends Sprite implements ISlide {
		
		public static const WIPE_TIME:Number = 0.7;
		
		public static const SCROLL_TIME:Number = 0.6;
		public static const SCROLL_X:Number = 1200;
		
		protected var textField:TextField;
		protected var backdrops:Vector.<DisplayObject>;
		
		protected var animateOnType:String;
		protected var animateOffType:String;
		
		protected var initialBackgroundColor:uint;
		
		public function SplashTextSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			this.initialBackgroundColor = initialBackgroundColor;
			
			var xml:XML = slideData.xml;
			
			backdrops = new Vector.<DisplayObject>();
			
			if (xml.hasOwnProperty("appearance")) {
				var appearanceXML:XML = xml.appearance[0];
				if (appearanceXML.hasOwnProperty("@backdropColor")) {
					var backdropColor:uint = slideData.currentColors[parseInt(appearanceXML.@backdropColor) - 1];
					var backdrop:Shape = new Shape();
					var g:Graphics = backdrop.graphics;
					g.beginFill(backdropColor);
					g.drawRect( -Infographic.WIDTH / 2, -Infographic.HEIGHT / 2, Infographic.WIDTH, Infographic.HEIGHT);
					g.endFill();
					backdrops.push(backdrop);
					addChild(backdrop);					
				}
			}
			
			for each(var imageXML:XML in xml.Image) {
				var url:String = imageXML.@url.toString();
				var bitmap:Bitmap = new Bitmap(AssetManager.getImage(url), "auto", true);
				if (imageXML.hasOwnProperty("@scale")) bitmap.scaleX = bitmap.scaleY = parseFloat(imageXML.@scale.toString());
				if (imageXML.hasOwnProperty("@x")) bitmap.x = parseFloat(imageXML.@x.toString());
				if (imageXML.hasOwnProperty("@y")) bitmap.y = parseFloat(imageXML.@y.toString());
				bitmap.x -= bitmap.width / 2;
				bitmap.y -= bitmap.height / 2;
				backdrops.push(bitmap);
				addChild(bitmap);
			}
			
			if (xml.hasOwnProperty("text")) {
				var textXML:XML = xml.text[0];
				
				var text:String = TextUtils.safeText(textXML.toString());
				var textScale:Number = 1;
				if (textXML.hasOwnProperty("@textScale")) textScale = parseFloat(textXML.@textScale);
				
				switch(textXML.@type.toString()) {
					case "corner":
					case "cornerText":
						var cornerAssets:MovieClip = new _CornerText();						
						textField = cornerAssets.textField;
						textField.text = text;
						if (textScale != 1) textField.scaleX = textField.scaleY = textScale;
						break;

					default:
						textField = createTextField(text, textScale);
						break;
						
				}
				

				addChild(textField);
			}
			
			animateOnType = xml.@animateOn;
			animateOffType = xml.@animateOff;
			
		}
		
		public static function createTextField(text:String, textScale:Number):TextField {
			var textField:TextField = new TextField();
			textField.mouseEnabled = false;
			textField.width = 1;
			textField.height = 1;
			textField.defaultTextFormat = TextUtils.infographicSplashFormat;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.textColor = 0xFFFFFF;

			textField.text = text;
			textField.width = Math.min(textField.width, 1024);
			textField.scaleX = textField.scaleY = textScale;
			textField.x = -textField.width / 2;
			textField.y = -textField.height / 2;
			
			return textField;
		}
		
		public function animateOn():void {
			var scrollTextOff:Boolean = true;

			switch(animateOnType) {
				case "none":
					break;
				default:
					for each(var backdrop:DisplayObject in backdrops) {
						backdrop.alpha = 0;
						TweenMax.to(backdrop, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
					}
					break;
			}

			if (scrollTextOff) {
				if (textField) {
					textField.x = -SCROLL_X - textField.width / 2;
					TweenMax.to(textField, SCROLL_TIME, { x:(0 - textField.width / 2), ease:Quad.easeOut } );
				}
			}
		}
		public function animateOff(callback:Function):void {
			var scrollTextOff:Boolean = true;
			
			switch(animateOffType) {
				case "none":
					break;
				default:
					for each(var backdrop:DisplayObject in backdrops) {
						TweenMax.to(backdrop, SCROLL_TIME, { alpha:0, ease:Quad.easeOut } );
					}
					break;
				case "wipe":
					scrollTextOff = false;
					wipeOff(callback);
					break;
			}
			
			if (scrollTextOff) {
				if (textField) {
					TweenMax.to(textField, SCROLL_TIME, { x:(SCROLL_X - textField.width / 2), ease:Quad.easeIn } );
				}				
				TweenMax.to(this, SCROLL_TIME, { onComplete:callback, onCompleteParams:[this] } );
			}
		}
		
		protected function wipeOff(callback:Function):void {
			var wipeMask:Sprite = new Sprite();
			var g:Graphics = wipeMask.graphics;
			g.beginFill(0x0);
			g.drawRect(-Infographic.WIDTH, -Infographic.HEIGHT / 2, Infographic.WIDTH, Infographic.HEIGHT);
			g.endFill();
			wipeMask.x = Infographic.WIDTH / 2;
			wipeMask.visible = false;
			addChild(wipeMask);
			mask = wipeMask;
			TweenMax.to(wipeMask, WIPE_TIME, { scaleX:0, ease:Quad.easeOut, onComplete:callback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void { }
		
	}

}