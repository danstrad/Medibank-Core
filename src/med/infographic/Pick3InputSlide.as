package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class Pick3InputSlide extends _Pick3InputSlide implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var inputVars:Object;
		protected var finishedCallback:Function;
		
		protected var inputEnabled:Boolean;
		
		protected var options:Vector.<Pick3Option>;
		
		public function Pick3InputSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, inputVars:Object, finishedCallback:Function) {
			this.inputVars = inputVars;
			this.finishedCallback = finishedCallback;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";
			
			var optionCT:ColorTransform = new ColorTransform();
			var selectedOptionCT:ColorTransform = new ColorTransform();
			if (xml.hasOwnProperty("optionColor")) optionCT.color = uint(xml.optionColor[0].toString().replace("#", "0x"));
			else optionCT.color = 0x744785;
			if (xml.hasOwnProperty("selectedOptionColor")) selectedOptionCT.color = uint(xml.selectedOptionColor[0].toString().replace("#", "0x"));
			else selectedOptionCT.color = 0xB0018D;

			options = new Vector.<Pick3Option>();
			var optionCount:int = 0;
			for each(var optionXML:XML in xml.option) {
				var optionID:String = optionXML.@id;
				var optionText:String = optionXML.@text.toString();
				var option:Pick3Option = new Pick3Option(optionID, optionText, optionCT, selectedOptionCT);
				options.push(option);
				addChild(option);
				var col:int = optionCount % 3;
				var row:int = int(optionCount / 3);
				option.x = -212 + 212 * col;
				option.y = -128 + 85 * row;
				optionCount++;
			}
		
			submitButton.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);			
		}
		
		public function animateOn():void {
			var t:Number = 0;
			titleField.x = -SCROLL_X - titleField.width / 2;
			TweenMax.to(titleField, SCROLL_TIME, { x:(-titleField.width / 2), ease:Quad.easeOut } );
			subtitleField.x = -SCROLL_X - subtitleField.width / 2;
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(-subtitleField.width / 2), ease:Quad.easeOut } );
			submitButton.alpha = 0;
			TweenMax.to(submitButton, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			t += SCROLL_TIME;
			
			for each(var option:Pick3Option in options) {
				option.alpha = 0;
				TweenMax.to(option, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			}

			TweenMax.to(this, t, { onComplete:enableInput } );
		}
		
		public function animateOff(callback:Function):void {			
			var t:Number = 0;
			TweenMax.to(titleField, SCROLL_TIME, { x:(SCROLL_X - titleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(SCROLL_X - subtitleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(submitButton, SCROLL_TIME, { alpha:0, ease:Quad.easeIn } );
			t += SCROLL_TIME;

			for each(var option:Pick3Option in options) {
				TweenMax.to(option, SCROLL_TIME, { alpha:0, ease:Quad.easeIn} );
			}
			
			TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
		}		
		
		protected function enableInput():void {
			inputEnabled = true;
		}
		
		protected function getPickedCount():int {
			var count:int = 0;
			for each(var option:Pick3Option in options) {
				if (option.selected) count++;
			}
			return count;
		}
		protected function readInput():void {
			var selected:Array = [];
			for each(var option:Pick3Option in options) {
				if (option.selected) selected.push(option.id);
			}
			inputVars.pick3Options = selected;
		}
		
		protected function handleMouseDown(event:MouseEvent):void {
			if (!inputEnabled) return;
			
			if (event.target == submitButton) {
				if (getPickedCount() == 3) {
					inputEnabled = false;
					readInput();
					animateOff(finishedCallback);
				}
			} else {
				var option:Pick3Option = event.target as Pick3Option;
				if (option) {
					if (option.selected) {
						option.selected = false;
					} else {
						if (getPickedCount() < 3) {
							option.selected = true;
						}
					}
				}
			}
		}
		
		
		
	}

}