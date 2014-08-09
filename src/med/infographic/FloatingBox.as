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
		
		
		
		protected var backScale:Number;	
		public var isAtBack:Boolean;
		
		
		protected var targetValue:int;
		protected var currentValue:int;
		
		
		public function FloatingBox(value:int, showNumber:Boolean, textString:String, topTextString:String, boxColor:uint, textColor:uint) {
			
			this.targetValue = value;
			
			// set correct text size for numberField based on value length
			/*
			if (targetValue >= 10000) {
				var textFormat:TextFormat = numberField.getTextFormat();
				textFormat.size = 78;
				numberField.setTextFormat(textFormat);
			}		
			*/

			if (showNumber) {
				numberField.textColor = textColor;
				showNumberValue(0);
			} else {
				numberField.visible = false;
			}
			
				
			textField.text = TextUtils.safeText(textString);
			textField.textColor = textColor;
			Text.boldText(textField);
					
			const TOP_TEXT_NORMAL_FONT_SIZE:Number = 21;
			const TOP_TEXT_NORMAL_WIDTH:Number = 225;
			
			if (topTextString != "") {
				
				topTextField.text = TextUtils.safeText(topTextString);
				topTextField.textColor = textColor;
				Text.setTextSpacing(topTextField, -0.4);
				topTextField.autoSize = TextFieldAutoSize.LEFT;
				
				// move number down
				numberField.y += 20;
			
			
				// adjust font size if necessary
				var fontSize:Number = TOP_TEXT_NORMAL_FONT_SIZE;
				
				
				while (topTextField.height >= (BOX_SIZE - 20)) {
				
					fontSize--;
					
					topTextField.autoSize = TextFieldAutoSize.NONE;
					topTextField.width = TOP_TEXT_NORMAL_WIDTH;
					
					// if the text is too big, we need to reduce the font size					
					var tf:TextFormat = topTextField.getTextFormat();
					tf.size = fontSize;					
					topTextField.setTextFormat(tf);
					
					topTextField.autoSize = TextFieldAutoSize.LEFT;					
				}
				
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

		
		protected function initForBack():void {				
			// set it to background state
			isAtBack = true;
			
			this.alpha = BACK_BOX_ALPHA;
			this.scaleX = this.scaleY = backScale;
			this.filters = [new BlurFilter(BACK_BOX_BLUR, BACK_BOX_BLUR, BLUR_QUALITY)];	
			
			var colorTransform:ColorTransform = this.transform.colorTransform;
			colorTransform.color = 0xFFFFFF;
			this.transform.colorTransform = colorTransform;
			
			// add "shimmer" tween
			var targetAlpha:Number = BACK_BOX_ALPHA - (Rndm.integer(0, 20) * 0.01);
			var delay:Number = Rndm.integer(0, 100) * 0.001;
			var duration:Number = 1.0 + (Rndm.integer(0, 500) * 0.001);
			
			TweenMax.to(this, duration, { alpha: targetAlpha, repeat: -1, yoyo:true, delay:0 } );
		}
		
		
		public function bringForward():void {
			isAtBack = false;
			countingUpTimeMSec = 0;
			
			TweenMax.to(this, BOX_ANIM_TIME_SECONDS, { overwrite:1, scaleX:1.0, scaleY:1.0, alpha:1.0, colorTransform:{ tint:0xFFFFFF, tintAmount:0}, blurFilter: { blurX:0, blurY:0, quality:BLUR_QUALITY }, ease:SineIn.ease}); 					
			
			// timer
			TweenMax.to(this, FloatingBoxesSlide.BOX_DISPLAY_TIME_SECONDS + BOX_ANIM_TIME_SECONDS, { onComplete:sendBack } );
		}
		
		
		public function sendBack():void {
			if (isAtBack)	return;
			isAtBack = true;
			
			TweenMax.to(this, BOX_ANIM_TIME_SECONDS, { scaleX:backScale, scaleY:backScale, alpha:BACK_BOX_ALPHA, colorTransform:{ tint:0xFFFFFF, tintAmount:1.0}, blurFilter:{ blurX:BACK_BOX_BLUR, blurY:BACK_BOX_BLUR }, onComplete:initForBack, ease:SineOut.ease}); 	
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