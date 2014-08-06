package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class ClockSlide extends _ClockSlide implements ISlide {
		
		protected static const SLIDE_TIME:Number = 5000;
		
		static public const TEXT_TIME:Number = 0.3;
		
		protected var textStartX:Number;
		protected var textX:Number;
		protected var maskX:Number;
		protected var clockX:Number;
		
		protected var finishedCallback:Function;

		protected var clock:Clock;
				
		protected var textMask:Sprite;
		
		public function ClockSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, finishedCallback:Function) {
			this.finishedCallback = finishedCallback;
			
			var featuredText:String = "";
			var clockText:String = "";
			var clockTextColor:uint = 0xFFFFFF;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("featuredText")) featuredText = xml.featuredText[0].toString();
			if (xml.hasOwnProperty("clockText")) clockText = xml.clockText[0].toString();
			if (xml.hasOwnProperty("appearance")) {
				var appearanceXML:XML = xml.appearance[0];
				if (appearanceXML.hasOwnProperty("@clockTextColor")) clockTextColor = uint(appearanceXML.@clockTextColor.toString().replace("#", "0x"));
			}
			
			var tf:TextField = textField;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = featuredText;
			tf.y = -tf.height / 2;
			
			textX = tf.x;
			maskX = -150;
			textStartX = maskX - textField.width - 5;
			clockX = -270;

			textMask = new Sprite();
			var g:Graphics = textMask.graphics;
			g.beginFill(0x0);
			g.drawRect(maskX, tf.y, tf.x + tf.width - maskX, tf.height);
			g.endFill();
			addChild(textMask);
			textMask.visible = false;
			tf.mask = textMask;


			clock = new Clock(clockText, clockTextColor);
			clock.x = clockX;
			addChild(clock);
			
		}
		
		public function animateOn():void {
			clock.animateOn();

			var t:Number = 1.0;
			textField.x = textStartX
			TweenMax.to(textField, TEXT_TIME, { x:textX, delay:t, ease:Quad.easeOut } );
			t += TEXT_TIME;
			
			TweenMax.to(this, SLIDE_TIME / 1000, { onComplete:slideTimeUp } );
		}
		
		protected function slideTimeUp():void {
			animateOff(finishedCallback);
		}
		
		public function animateOff(callback:Function):void {			
			var t:Number = 0;
			clock.animateOff();
			t += 0.9;
			
			TweenMax.to(textField, TEXT_TIME, { x:textStartX, ease:Quad.easeIn } );
			t += TEXT_TIME;
			
			
			TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
			clock.animate(dTime);
		}

		
	}

}