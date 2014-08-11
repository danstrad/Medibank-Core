package med.infographic {
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	import com.gskinner.utils.Rndm;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class FloatingBox extends _FloatingBox {

		
		public static const BOX_SIZE:Number = 256;
		
//		protected static const BACK_BOX_SCALE:Number = 0.2;
		protected static const BACK_BOX_ALPHA:Number = 0.5;
		
		public static const BACK_BOX_BLUR:Number = 16;	
		public static const BLUR_QUALITY:int = 2;
				
		public static const BOX_ANIM_TIME_SECONDS:Number = 0.6;

		protected static const NUMBER_COUNT_UP_TIME_MSEC:Number = 1000;
				
		
		protected var countingUpTimeMSec:Number = 0;
		
		
		protected var textLayer:Sprite;
		
		
		protected var backScale:Number;	
		public var isAtBack:Boolean;
		
		
		protected var targetValue:int;
		protected var currentValue:int;
		
		
		protected var textLength:int = 0;
		
		
		public function FloatingBox(value:int, showNumber:Boolean, textString:String, topTextString:String, boxColor:uint, textColor:uint) {
			
			this.targetValue = value;

			// added so we can toggle text visibility as a whole (and preserve individual visibility for each textfield)
			textLayer = new Sprite();
			addChild(textLayer);
			
			removeChild(numberField);
			removeChild(textField);
			removeChild(topTextField);
			
			textLayer.addChild(numberField);
			textLayer.addChild(textField);
			textLayer.addChild(topTextField);
			
			
			if (showNumber) {
				numberField.textColor = textColor;
				showNumberValue(0);
			} else {
				numberField.visible = false;
			}
			
				
			textField.text = TextUtils.safeText(textString);
			textField.textColor = textColor;
			Text.boldText(textField);
					
			textLength += textString.length;
			
			const TOP_TEXT_NORMAL_FONT_SIZE:Number = 21;
			const TOP_TEXT_NORMAL_WIDTH:Number = 225;
			
//			var topTextSpacing:Number = -0.4;
//			var topTextLeading:Number = -3.0;
			
			
			if (topTextString != "") {
				
				topTextField.text = TextUtils.safeText(topTextString);
				topTextField.textColor = textColor;
				Text.boldText(topTextField);
//				Text.setTextSpacing(topTextField, topTextSpacing);
				topTextField.autoSize = TextFieldAutoSize.LEFT;

					
				textLength += topTextString.length;
				
				// move number down
				numberField.y += 20;
			
				
				// make sure we fit in the box
				TextUtils.scaleToFit(topTextField, 225, BOX_SIZE-20, 1.0, 0.05); 

				
				
				// adjust font size if necessary
				/*
				var fontSize:Number = TOP_TEXT_NORMAL_FONT_SIZE;
				
				while (topTextField.height >= (BOX_SIZE - 20)) {
				
					fontSize--;
										
					topTextField.autoSize = TextFieldAutoSize.NONE;
					topTextField.width = TOP_TEXT_NORMAL_WIDTH;
					
					// if the text is too big, we need to reduce the font size					
					var tf:TextFormat = topTextField.getTextFormat();
					tf.size = fontSize;	
					tf.letterSpacing = topTextSpacing * (TOP_TEXT_NORMAL_FONT_SIZE / fontSize);
					tf.leading = topTextLeading * (TOP_TEXT_NORMAL_FONT_SIZE / fontSize);
					topTextField.setTextFormat(tf);
					
					topTextField.autoSize = TextFieldAutoSize.LEFT;					
				}
				*/
				
				
			} else {
				topTextField.visible = false;
			}
			
			textField.autoSize = TextFieldAutoSize.LEFT;

			textField.y = (BOX_SIZE * 0.5) - textField.height - 15; 
			
			// draw the box
			graphics.clear();
			graphics.beginFill(boxColor, 1.0);
			graphics.drawRect( -BOX_SIZE * 0.5, -BOX_SIZE * 0.5, BOX_SIZE, BOX_SIZE);
			
			graphics.endFill();
			
			backScale = Rndm.integer(8, 20) * 0.01;
			
			initForBack();			
		}

		
		public function addBlur():void {
			TweenMax.to(this, 0.5, {  blurFilter: { blurX:BACK_BOX_BLUR, blurY:BACK_BOX_BLUR, quality:FloatingBox.BLUR_QUALITY }, delay:0.3 } );
		}
				
		
		protected function initForBack():void {				
			// set it to background state
			isAtBack = true;
			
			textLayer.visible = false;
			
			this.alpha = BACK_BOX_ALPHA;
			this.scaleX = this.scaleY = backScale;
			
//			this.filters = [new BlurFilter(BACK_BOX_BLUR, BACK_BOX_BLUR, BLUR_QUALITY)];	
			
			var colorTransform:ColorTransform = this.transform.colorTransform;
			colorTransform.color = 0xFFFFFF;
			this.transform.colorTransform = colorTransform;
			
			// add "shimmer" tween
			var targetAlpha:Number = BACK_BOX_ALPHA - (Rndm.integer(0, 20) * 0.01);
			var delay:Number = Rndm.integer(0, 100) * 0.001;
			var duration:Number = 1.0 + (Rndm.integer(0, 500) * 0.001);
			
			TweenMax.to(this, duration, { alpha: targetAlpha, repeat: -1, yoyo:true, delay:0 } );
		}
		

		
		public static const BOX_DISPLAY_TIME_MINIMUM_SECONDS:Number = 2.0;

		public static const BOX_DISPLAY_TIME_EXTRA_PER_CHARACTER:Number = 0.03;
		
		
		public function get displayDurationSeconds():Number {
			// new: now we try to dynamically adjust the length of time the box is shown for
			var duration:Number = BOX_DISPLAY_TIME_MINIMUM_SECONDS + BOX_ANIM_TIME_SECONDS;
			
			
			duration += (textLength * BOX_DISPLAY_TIME_EXTRA_PER_CHARACTER);
			
			
			return duration;
		}
		
		
		public function bringForward():void {
			isAtBack = false;
			countingUpTimeMSec = 0;
			
			textLayer.visible = true;
			
			TweenMax.to(this, BOX_ANIM_TIME_SECONDS, { overwrite:1, scaleX:1.0, scaleY:1.0, alpha:1.0, colorTransform:{ tint:0xFFFFFF, tintAmount:0}, blurFilter: { blurX:0, blurY:0, quality:BLUR_QUALITY }, ease:SineIn.ease}); 					
			
			// timer
			var duration:Number = displayDurationSeconds;
			
			TweenMax.to(this, duration, { onComplete:sendBack } );
		}
		
		
		public function sendBack():void {
			if (isAtBack)	return;
			isAtBack = true;
			
			TweenMax.to(this, BOX_ANIM_TIME_SECONDS * 0.5, { scaleX:backScale, scaleY:backScale, alpha:BACK_BOX_ALPHA, colorTransform:{ tint:0xFFFFFF, tintAmount:1.0}, blurFilter:{ blurX:BACK_BOX_BLUR, blurY:BACK_BOX_BLUR, quality:BLUR_QUALITY }, onComplete:initForBack, ease:SineOut.ease}); 	
		}
		
		
		
		public function animate(dTime:Number):void {
			
			if ((!isAtBack) && (currentValue < targetValue)) {
				
				countingUpTimeMSec += dTime;
				
				var frac:Number = Math.min(1.0, countingUpTimeMSec / NUMBER_COUNT_UP_TIME_MSEC);				
				var value:int = Math.round(frac * targetValue);
								
				showNumberValue(value);				
			}
			
		}
		

		
		protected function showNumberValue(value:int):void {
			var numberString:String = String(value);
			
			// add commas
			numberString = Text.addCommasToNumberString(numberString);
			
			// set correct text size for numberField based on value length
			if (targetValue >= 10000) {
				numberString = "<font size='78'>" + numberString + "</font>";
			}
			
			numberField.htmlText = numberString;
			Text.boldText(numberField);
			Text.setTextSpacing(numberField, -1);				
			
			this.currentValue = value;
		}
		
		

	}

}