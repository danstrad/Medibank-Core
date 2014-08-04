package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class Pick3ResultsSlide extends _Pick3ResultsSlide implements ISlide {
		
		protected static const BAR_X:Number = -512;
		protected static const BAR_WIDTH:Number = 970;
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var inputVars:Object;
		protected var finishedCallback:Function;

		protected var bars:Vector.<Pick3Bar>;
		
		public function Pick3ResultsSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, inputVars:Object, finishedCallback:Function) {
			this.inputVars = inputVars;
			this.finishedCallback = finishedCallback;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			
			var optionCT1:ColorTransform = new ColorTransform();
			var optionCT2:ColorTransform = new ColorTransform();
			var selectedOptionCT:ColorTransform = new ColorTransform();
			if (xml.hasOwnProperty("optionColor1")) optionCT1.color = uint(xml.optionColor1[0].toString().replace("#", "0x"));
			else optionCT1.color = 0x744785;
			if (xml.hasOwnProperty("optionColor2")) optionCT2.color = uint(xml.optionColor2[0].toString().replace("#", "0x"));
			else optionCT2.color = 0x744785;
			if (xml.hasOwnProperty("selectedOptionColor")) selectedOptionCT.color = uint(xml.selectedOptionColor[0].toString().replace("#", "0x"));
			else selectedOptionCT.color = 0xB0018D;
			
			bars = new Vector.<Pick3Bar>();
			var barCount:int = 0;
			for each(var barXML:XML in xml.bar) {
				var barID:String = barXML.@id;
				var barText:String = barXML.@text.toString();
				var barValue:Number = parseFloat(barXML.@value.toString());
				var ct:ColorTransform = ((barCount % 2) == 0) ? optionCT1 :optionCT2;
				if (inputVars.pick3Options && (inputVars.pick3Options.indexOf(barID) >= 0)) ct = selectedOptionCT;
				var bar:Pick3Bar = new Pick3Bar(barID, barText, barValue, ct);
				bars.push(bar);
				addChild(bar);
				bar.x = BAR_X;
				bar.y = -180 + 32 * barCount;
				barCount++;
			}
			
			nextButton.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);			
		}
		
		public function animateOn():void {
			var t:Number = 0;
			titleField.x = -SCROLL_X - titleField.width / 2;
			TweenMax.to(titleField, SCROLL_TIME, { x:(-titleField.width / 2), ease:Quad.easeOut } );
			nextButton.alpha = 0;
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			t += SCROLL_TIME;
			
			const BAR_START:Number = 0.3;
			const BAR_LENGTH:Number = 0.5;
			const TEXT_START:Number = 0.6;
			const TEXT_LENGTH:Number = 0.3;
			for each(var bar:Pick3Bar in bars) {
				bar.x = BAR_X;
				bar.barWidth = 0;
				TweenMax.to(bar, BAR_LENGTH, { x:(BAR_X + bar.value * BAR_WIDTH), barWidth:(bar.value * BAR_WIDTH), delay:BAR_START, ease:Quad.easeOut } );
				bar.textField.x = 5;
				TweenMax.to(bar.textField, TEXT_LENGTH, { x:(-5 - bar.textField.width), delay:TEXT_START, ease:Quad.easeOut } );
			}

			t = Math.max(t, BAR_START + BAR_LENGTH, TEXT_START + TEXT_LENGTH);
		}
		
		public function animateOff(callback:Function):void {
			var t:Number = 0;
			TweenMax.to(titleField, SCROLL_TIME, { x:(SCROLL_X - titleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:0, ease:Quad.easeIn } );
			t += SCROLL_TIME;
			
			const BAR_START:Number = 0.4;
			const BAR_LENGTH:Number = 0.5;
			const TEXT_START:Number = 0.3;
			const TEXT_LENGTH:Number = 0.3;
			for each(var bar:Pick3Bar in bars) {
				TweenMax.to(bar, BAR_LENGTH, { x:BAR_X, barWidth:0, delay:BAR_START, ease:Quad.easeOut } );
				TweenMax.to(bar.textField, TEXT_LENGTH, { x:5, delay:TEXT_START, ease:Quad.easeOut } );
			}

			t = Math.max(t, BAR_START + BAR_LENGTH, TEXT_START + TEXT_LENGTH);
			TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
		}		

		protected function handleMouseDown(event:MouseEvent):void {
			if (event.target == nextButton) {
				animateOff(finishedCallback);
			}
		}
		
	}

}