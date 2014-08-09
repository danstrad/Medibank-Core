package med.infographic {
	import com.gskinner.utils.Rndm;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class FlipNumber extends _FlipNumber {

		
		protected var numerals:Vector.<FlipNumberNumeral>;		
		protected var commas:Vector.<FlipNumberComma>;
		
		protected var numeralParent:Sprite;
		
		protected var targetValues:Array;
		
		public static const NUMERAL_GAP_X:Number = 64;
		
		protected var bgColor:uint;
		
		
		
		public function FlipNumber(bgColor:uint) {
			this.bgColor = bgColor;
			
			numeralParent = new Sprite();
			numeralParent.x = 0;
			numeralParent.y = 0;
			addChild(numeralParent);
			
			numerals = new Vector.<FlipNumberNumeral>();			
			commas = new Vector.<FlipNumberComma>();
			
//			for (var i:int = 0; i < numDigits; i++) {
//				addNewNumeral();
//			}
			
			
		}
		
		
		
		protected function addNewNumeral():void {
			var numeral:FlipNumberNumeral = new FlipNumberNumeral(bgColor);
			numeral.x = 0;
			numeral.y = 0;
			numerals.push(numeral);
			numeralParent.addChild(numeral);
		}
		
		
		protected function removeNumeral():void {
			var numeral:FlipNumberNumeral = numerals.pop();
			numeralParent.removeChild(numeral);
		}
		
		
		protected function repositionNumerals():void {
			// finalize placement of numerals and commas
			
			var totalWidth:Number = 0;
			
			
			// make sure we have the right number of commas
			var comma:FlipNumberComma;
				
			var numCommasRequired:int = Math.ceil(targetValues.length / 3) - 1;
			
			while (commas.length < numCommasRequired) {			
				comma = new FlipNumberComma();
				commas.push(comma);
				numeralParent.addChild(comma);
			}
			
			while (commas.length > numCommasRequired) {
				comma = commas.pop();
				numeralParent.removeChild(comma);
			}
							
			var commaIndex:int = commas.length - 1;
			
			
			for (var i:int = numerals.length - 1; i >= 0; i--) {
				var numeral:FlipNumberNumeral = numerals[i];

				
				// now we start with the least significant digit, and place digits leftwards from the origin
				// this is to make it easier to insert the comma in the right position
				var significantDigitIndex:int = ((numerals.length - 1) - i);
				
				
				if ((significantDigitIndex != 0) && ((significantDigitIndex % 3) == 0)) {
					// insert comma here
					commas[commaIndex].x = -30 - totalWidth + 20;
					commas[commaIndex].visible = true;
					totalWidth += 26;
					commaIndex--;
				}				
				
				// remember that the origin of the numerals is in their center.. need to add half the width to this
//				numeral.x = -30 - (((numerals.length-1) - i) * NUMERAL_GAP_X);
				
				numeral.x = -30 - totalWidth;

				if (i == 0)		totalWidth += 60;
				else			totalWidth += NUMERAL_GAP_X;
				
			}
			
			// center the whole thing
			numeralParent.x = (totalWidth * 0.5);
			
		}
		
		

		public function thisValueWillChangeNumeralCount(value:int):Boolean {
			var values:Array = value.toString().split("");
			
			if (values.length > numerals.length) 		return true;
			else if (values.length < numerals.length) 	return true;
			else	return false;
		}
		
		
		public function initForNumber(value:int, forceLengthTo:int=-1):void {
			var i:int;
								
			targetValues = value.toString().split("");

			while (targetValues.length < forceLengthTo) {
				targetValues.unshift("0");
			}
			
			var length:int = Math.max(forceLengthTo, targetValues.length);
						
			if (length > numerals.length) {
				// do we need more numerals?				
				while (length > numerals.length) {
					addNewNumeral();
				}
				
			} else if (length < numerals.length) {
				// need fewer numerals
				while (length < numerals.length) {
					removeNumeral();
				}
			}

			// finalize placement of numerals and commas
			repositionNumerals();
						
		}
		
		
		protected var afterFlipCallback:Function;
		protected var afterFlipCallbackParam:Object;
		
		public function flipToBlank(callback:Function, callbackParam:Object):void {
			afterFlipCallback = callback;
			afterFlipCallbackParam = callbackParam;
			
			numeralsFinishedCount = 0;
			
			for (var i:int = 0; i < numerals.length; i++) {
				var numeral:FlipNumberNumeral = numerals[i];
				numeral.setValue(-1, false, i * 0.1, numeralFinished);
			}
			
			for each (var comma:FlipNumberComma in commas) {
				comma.visible = false;
			}
		}
		
		
		protected var numeralsFinishedCount:int = 0;
		
		
		public function numeralFinished():void {
			numeralsFinishedCount++;
			
			if (numeralsFinishedCount >= numerals.length) {
				if (afterFlipCallback != null) {
					
					if (afterFlipCallbackParam != null) {
						afterFlipCallback(afterFlipCallbackParam);
					} else {
						afterFlipCallback();
					}
				}
			}
		}
		
		
		
		public function flipToNumber(value:int):void {

//			initForNumber(value);

			targetValues = value.toString().split("");

			numeralsFinishedCount = 0;
			
			for (var i:int = 0; i < targetValues.length; i++) {
				
				var targetValue:int = int(String(targetValues[i]));				

				var delay:Number = i * 0.12;
				
				// tell it to flip to this value
				numerals[i].setValue(targetValue, false, delay, null);
				
			}

			
		}
		
		
		public function setStartingValue(value:int, numDigits:int, changeInstantly:Boolean):void {

			// if numDigits is higher than it should be, we padd the value with leading zeroes
			targetValues = value.toString().split("");

			while (targetValues.length < numDigits) {
				targetValues.unshift("0");
			}
						
			initForNumber(value, numDigits);
			
			for (var i:int = 0; i < targetValues.length; i++) {
				var targetValue:int = int(String(targetValues[i]));				
				numerals[i].setValue(targetValue, changeInstantly);
			}
			
		}
		
		
		/*
		public function setRandomStartingNumber():void {
				
			for (var i:int = 0; i < targetValues.length; i++) {
				
				var targetValue:int = int(String(targetValues[i]));				

				var initValue:int = Rndm.integer(0, 10);
				
				while (Math.abs(initValue - targetValue) < 2) {
					initValue = Rndm.integer(0, 10);
				}
								
				numerals[i].setValue(initValue, true);
				
			}
							
		}
		*/
		
		/*
		public function slideOn():void {
						
			for each (var numeral:FlipNumberNumeral in numerals) {
				numeral.slideOn();
			}
			
		}
		
		
		public function slideOff():void {
			for each (var numeral:FlipNumberNumeral in numerals) {
				numeral.slideOff();
			}
		}
		*/

	}

}