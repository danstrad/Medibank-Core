package med.infographic {
	import flash.display.Shape;
	import flash.display.Sprite;

	public class FlipNumber extends _FlipNumber {

		
		protected var numerals:Vector.<FlipNumberNumeral>;
		
		protected var numeralParent:Sprite;
		
		protected var targetValues:Array;
		
		public static const NUMERAL_GAP_X:Number = 64;
		
		
		
		public function FlipNumber() {
			
			numeralParent = new Sprite();
			numeralParent.x = 0;
			numeralParent.y = 0;
			addChild(numeralParent);
			
			numerals = new Vector.<FlipNumberNumeral>();
			
			
//			for (var i:int = 0; i < numDigits; i++) {
//				addNewNumeral();
//			}
			
			
		}
		
		
		
		protected function addNewNumeral():void {
			var numeral:FlipNumberNumeral = new FlipNumberNumeral();
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
			
			for (var i:int = 0; i < numerals.length; i++) {
				var numeral:FlipNumberNumeral = numerals[i];
				
				// remember that the origin of the numerals is in their center.. need to add half the width to this
				numeral.x = 30 + (i * NUMERAL_GAP_X);
				
				if (i == 0)		totalWidth += 60;
				else			totalWidth += NUMERAL_GAP_X;
				
				// todo: handle commas
			}
			
			// center the whole thing
			numeralParent.x = -(totalWidth * 0.5);
			
		}
		
		

		
		public function initForNumber(value:int):void {
			var i:int;
								
			targetValues = value.toString().split("");

			
			if (targetValues.length > numerals.length) {
				// do we need more numerals?				
				while (targetValues.length > numerals.length) {
					addNewNumeral();
				}
				
			} else if (targetValues.length < numerals.length) {
				// need fewer numerals
				while (targetValues.length < numerals.length) {
					removeNumeral();
				}
			}
			
			
			// do we need commas?
			if (value > 1000) {
			
				// place them correctly
				
			
				// todo
				
			}
			
			
			// finalize placement of numerals and commas
			repositionNumerals();
						
		}
		
		
		
		public function flipToNumber(value:int):void {

			initForNumber(value);
			
			
			for (var i:int = 0; i < targetValues.length; i++) {
				
				var targetValue:int = int(String(targetValues[i]));				
				
				// set an offset value for us to flip too
				numerals[i].setValue(0, true);
				
				// tell it to flip to this value
				numerals[i].setValue(targetValue, false);
				
			}

			
		}
		
		
		public function slideOn():void {
						
			for each (var numeral:FlipNumberNumeral in numerals) {
				numeral.slideOn();
			}
			
		}
		

	}

}