package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class SplashTextSlide extends Sprite implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var textField:TextField;
		protected var bitmaps:Vector.<Bitmap>;
		
		public function SplashTextSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
			
			bitmaps = new Vector.<Bitmap>();
			
			for each(var imageXML:XML in xml.Image) {
				var url:String = imageXML.@url.toString();
				var bitmap:Bitmap = new Bitmap(AssetManager.getImage(url), "auto", true);
				if (imageXML.hasOwnProperty("@scale")) bitmap.scaleX = bitmap.scaleY = parseFloat(imageXML.@scale.toString());
				if (imageXML.hasOwnProperty("@x")) bitmap.x = parseFloat(imageXML.@x.toString());
				if (imageXML.hasOwnProperty("@y")) bitmap.y = parseFloat(imageXML.@y.toString());
				bitmap.x -= bitmap.width / 2;
				bitmap.y -= bitmap.height / 2;
				bitmaps.push(bitmap);
			}
			
			if (xml.hasOwnProperty("text")) {
				textField = new TextField();
				textField.mouseEnabled = false;
				textField.width = 1;
				textField.height = 1;
				textField.defaultTextFormat = TextUtils.infographicSplashFormat;
				textField.autoSize = TextFieldAutoSize.LEFT;
				textField.textColor = 0xFFFFFF;
				
				var text:String = TextUtils.safeText(xml.text[0].toString());
				textField.text = text;
				textField.width = Math.min(textField.width, 1024);

				textField.x = -textField.width / 2;
				textField.y = -textField.height / 2;
			}
			
		}
		
		public function animateOn():void {
			for each(var bitmap:Bitmap in bitmaps) {
				addChild(bitmap);
				bitmap.alpha = 0;
				TweenMax.to(bitmap, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			}
			if (textField) {
				addChild(textField);
				textField.x = SCROLL_X - textField.width / 2;
				TweenMax.to(textField, SCROLL_TIME, { x:(0 - textField.width / 2), ease:Quad.easeOut } );
			}
		}
		public function animateOff(callback:Function):void {
			for each(var bitmap:Bitmap in bitmaps) {
				TweenMax.to(bitmap, SCROLL_TIME, { alpha:0, ease:Quad.easeOut } );
			}
			if (textField) {
				TweenMax.to(textField, SCROLL_TIME, { x:(SCROLL_X - textField.width / 2), ease:Quad.easeIn } );
			}
		}
		
		public function animate(dTime:Number):void { }
		
	}

}