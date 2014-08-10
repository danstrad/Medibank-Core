package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class TimeDialsSlide extends _TimeDials implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var inputVars:Object;
		protected var finishedCallback:Function;
		
		protected var dials:Vector.<TimeDial>;
		
		
		public function TimeDialsSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, inputVars:Object, finishedCallback:Function) {
			this.inputVars = inputVars;
			this.finishedCallback = finishedCallback;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";

			dials = new Vector.<TimeDial>();
			for each(var dialXML:XML in xml.dial) {
				var dial:TimeDial = new TimeDial();
				if (dialXML.hasOwnProperty("@type")) dial.input = (dialXML.@type.toString() == "input");
				dial.title = dialXML.@title;
				if (dialXML.hasOwnProperty("@variable")) {
					dial.variable = dialXML.@variable;
					dial.color = slideData.currentSelectionColor;
				} else {
					dial.color = slideData.currentGraphColor1;
				}				
				if (dialXML.hasOwnProperty("@value")) dial.value = parseFloat(dialXML.@value.toString());
				if (!dial.input && dial.variable) dial.value = inputVars[dial.variable];
				addChild(dial);
				dials.push(dial);
			}
			for (var i:int = 0; i < dials.length; i++) {
				dial = dials[i];
				dial.y = 43;
				if (dials.length == 0) dial.x = 0;
				else dial.x = -271 + (271 * 2) * i / (dials.length - 1);
			}
			
			nextButton.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		
		public function animateOn():void {
			var t:Number = 0;
			titleField.x = -SCROLL_X - titleField.width / 2;
			TweenMax.to(titleField, SCROLL_TIME, { x:(-titleField.width / 2), ease:Quad.easeOut } );
			subtitleField.x = -SCROLL_X - subtitleField.width / 2;
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(-subtitleField.width / 2), ease:Quad.easeOut } );
			nextButton.alpha = 0;
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			t += SCROLL_TIME;
			
			TweenMax.to(this, t, { onComplete:startTimeDials } );
		}
		
		public function animateOff(callback:Function):void {
			readInput();
			
			var t:Number = 0;
			for each(var dial:TimeDial in dials) {
				dial.animateOff();
			}
			t += 0.9;
			
			TweenMax.to(titleField, SCROLL_TIME, { x:(SCROLL_X - titleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(SCROLL_X - subtitleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:0, ease:Quad.easeIn } );
			t += SCROLL_TIME;
			
			
			TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
			for each(var dial:TimeDial in dials) dial.animate(dTime);
		}

		protected function readInput():void {
			for each(var dial:TimeDial in dials) {
				if (dial.input) {
					inputVars[dial.variable] = dial.value;
				}
			}
		}
		
		protected function startTimeDials():void {
			for each(var dial:TimeDial in dials) {
				dial.animateOn();
			}
		}
		
		protected function handleMouseDown(event:MouseEvent):void {
			for each(var dial:TimeDial in dials) {
				if (!dial.inputEnabled) return; // Abort if time dials are still rolling out
			}
			if (event.target == nextButton) {
				animateOff(finishedCallback);
			}
		}
		
	}

}