package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import med.display.Background;

	public class InfographicCenterBox extends _InfographicCenterBox implements ISlide {

		
		public static const CENTER_BOX_WIDTH:Number = 464.1;
		public static const CENTER_BOX_HEIGHT:Number = 443;
		
		public static const BOX_X:Number = -CENTER_BOX_WIDTH * 0.5;
		public static const BOX_Y:Number = -CENTER_BOX_HEIGHT * 0.5;
			

		
		protected static const ANIMATE_ON_TIME:Number = 0.4;	// time for the box to rotate (or squash up)
		
		protected static const TEXT_TRANSITION_ON_TIME:Number = 0.1;
		protected static const TEXT_TRANSITION_OFF_TIME:Number = 0.1;

		protected static const ANIMATE_OFF_TIME:Number = 0.3;	// how long is take the box to 'squash'
		
		
		
		protected var box:Shape;
		protected var textMask:Shape;
	
		protected var textFieldOriginalX:Number;
		
		protected var data:InfographicSlideData;
		protected var boxColor:uint;
		
		
		
		public function InfographicCenterBox(slideData:InfographicSlideData) {
			this.data = slideData;
			
			// get details from xml
			var textColor:uint = uint(slideData.xml.appearance.@textColor.toString().replace("#", "0x"));
			var backgroundColor:uint = uint(slideData.xml.appearance.@backgroundColor.toString().replace("#", "0x"));
			
			this.boxColor = uint(slideData.xml.appearance.@boxColor.toString().replace("#", "0x"));	
				
			var boxText:String = TextUtils.safeText(slideData.xml.featuredText);
			
			
			// draw box
			box = new Shape();
			box.graphics.clear();
			box.graphics.beginFill(boxColor);
			box.graphics.drawRect(BOX_X, BOX_Y, CENTER_BOX_WIDTH, CENTER_BOX_HEIGHT);
			box.graphics.endFill();
			addChildAt(box, 0);
			
			// text mask (same size and position as box)
			textMask = new Shape();
			textMask.graphics.clear();
			textMask.graphics.beginFill(0x0000FF);
			textMask.graphics.drawRect(BOX_X, BOX_Y, CENTER_BOX_WIDTH, CENTER_BOX_HEIGHT);
			textMask.graphics.endFill();
			addChild(textMask);			
			
			// set text
//			textField.htmlText = "<font color='#" + textColor.toString(16) + "'>" + boxText + "</font>";
			textField.text = boxText;
			textField.textColor = textColor;
			Text.boldText(textField);
			Text.setTextSpacing(textField, -2);
			
			textField.autoSize = TextFieldAutoSize.CENTER;						
			textField.y = 0 - (textField.height * 0.5);
						
			// move the text to the left, outside of its mask
			textFieldOriginalX = textField.x;
			textField.x -= 450;
			
			textField.mask = textMask;
			
		}

		
			
		public function animateOn():void {
			// standard animation on-- squish out			
			TweenMax.fromTo(box, ANIMATE_ON_TIME, { scaleX:0, scaleY:0 }, { scaleX:1, scaleY:1, immediateRender:true, onComplete:rollOutText } );
		}
		
		public function animateOnLaunch(launchRect:Rectangle):void {
			// roll out from a specific point. Used in tansition from BoxesMain into Infographic
			var startRot:Number = (launchRect.x + launchRect.width / 2 < 0) ? -180 : 180;
			var startX:Number = (launchRect.x + launchRect.width / 2);
			var startY:Number = (launchRect.y + launchRect.height / 2);
			var startScaleX:Number = launchRect.width / CENTER_BOX_WIDTH;
			var startScaleY:Number = launchRect.height / CENTER_BOX_HEIGHT;
			TweenMax.fromTo(box, ANIMATE_ON_TIME, { x:startX, y:startY, scaleX:startScaleX, scaleY:startScaleY, rotation:startRot }, { x:0, y:0, scaleX:1, scaleY:1, rotation:0, immediateRender:true, onComplete:rollOutText } );
		}
		
		public function animateOnRotate(previousBoxColor:uint):void {
			// animation when transitioning from a previous box			
			TweenMax.fromTo(box, ANIMATE_ON_TIME, { rotation:-180, colorTransform:{ tint:previousBoxColor, tintAmount:1.0} }, { rotation:0, colorTransform:{ tint:previousBoxColor, tintAmount:0}, immediateRender:true, onComplete:rollOutText } );
		}
		
		
		public function animateOnNone():void {
			// no animation, just roll the text out
			rollOutText();
		}
		
		
		public function animateOnZoom():void {
			// animate on by zooming in
			TweenMax.fromTo(this, ANIMATE_ON_TIME, { scaleX:3.0, scaleY:3.0 }, { scaleX:1.0, scaleY:1.0, onComplete:rollOutText } );			
		}
		
		
		public function animateOff(callback:Function):void {
			slideTextOff(callback);
		}
		
		public function animateOffSquash(callback:Function):void {								
			// squash to a point
			// note: this isn't used if the next slide is also an InfographicCenterBox
			slideTextOff();
			TweenMax.fromTo(box, ANIMATE_OFF_TIME, { scaleX:1, scaleY:1 }, { scaleX:0, scaleY:0, immediateRender:true, onComplete:callback, onCompleteParams:[this], delay: TEXT_TRANSITION_OFF_TIME } );						
		}
		
		
		public function animateOffZoom(callback:Function):void {		
			// zoom in to this box until it fills the screen
			slideTextOff(null);
			TweenMax.fromTo(this, ANIMATE_OFF_TIME, { scaleX:1.0, scaleY:1.0 }, { scaleX:3.0, scaleY:3.0, delay:TEXT_TRANSITION_OFF_TIME, onComplete:callback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void { }
		
		

		
		protected function hide():void {
			this.visible = false;
		}
		

		protected function slideTextOff(callback:Function = null):void {
			if (callback != null) {
				TweenMax.to(textField, TEXT_TRANSITION_OFF_TIME, { x:textFieldOriginalX + 450, onComplete:callback, onCompleteParams:[this] } );	
			} else {
				TweenMax.to(textField, TEXT_TRANSITION_OFF_TIME, { x:textFieldOriginalX + 450 } );	
			}
		}
		
		
		protected function rollOutText():void {
			// once our animation is done, we have the text appear from the left hand side
			TweenMax.to(textField, TEXT_TRANSITION_ON_TIME, { x:textFieldOriginalX } );			
		}
		
		

		
	}

}