package med.infographic {
	import com.greensock.easing.BounceInOut;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Shape;
	import flash.display.Sprite;

	
	public class SpinNumberSlide extends _SpinNumberSlide implements ISlide {

		
		public static const ENTRY_HEIGHT:Number = 82;
		
		protected static const SLOT_GAP_X:Number = 62;

		protected static const RIGHT_EDGE_SLOT_OFFSET:Number = 40;
		
		public static const AFTER_SPINNING_WAIT_TIME_SECONDS:Number = 2.5;
		
	
		
		protected var featuredTextPanel:Sprite;
		protected var featuredTextEntries:Vector.<_FeaturedTextEntry>;
		
		protected var graphStateIndex:int = 0;
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
				
		protected var alphaShadingLayer:Shape;
		
		protected var slots:Vector.<SpinNumberSlot>;		
		protected var commas:Vector.<SpinNumberComma>;
		
		protected var targetValues:Array;
		protected var value:Number;
		
		
		public function SpinNumberSlide(slideData:InfographicSlideData) {
			
			// parse xml
			var graphStateXML:XML;
			
			for each (graphStateXML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
			
			
			commas = new Vector.<SpinNumberComma>();
			slots = new Vector.<SpinNumberSlot>();
			
			
			// build featured text panel
			featuredTextPanel = new Sprite();
			
			featuredTextPanel.x = -512;
			featuredTextPanel.y = ENTRY_HEIGHT * 0.5;
			addChild(featuredTextPanel);
			
			
			// draw correct color for color line
			colorLine.graphics.clear();
			colorLine.graphics.beginFill(slideData.boxColor, 1.0);
			colorLine.graphics.drawRect(-512, -ENTRY_HEIGHT * 0.5, 1024, ENTRY_HEIGHT);
			colorLine.graphics.endFill();
			
			
			// add entries
			featuredTextEntries = new Vector.<_FeaturedTextEntry>();
			
			for each (graphStateXML in graphStatesXML) {
	
				var featuredTextEntry:_FeaturedTextEntry = new _FeaturedTextEntry(); 			
				featuredTextEntry.textField.text = TextUtils.safeText(graphStateXML.@featuredText);

				featuredTextEntry.y = (featuredTextEntries.length * ENTRY_HEIGHT);
				featuredTextEntries.push(featuredTextEntry);
				featuredTextPanel.addChild(featuredTextEntry);
				
			}


			
			// draw the colored alpha overlays (use background color)
			alphaShadingLayer = new Shape();
			addChild(alphaShadingLayer);
			
			// 90% (directly above and below)
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.9);
			alphaShadingLayer.graphics.drawRect(-512, -(1.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();

			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.9);
			alphaShadingLayer.graphics.drawRect(-512, (0.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();
			
			
			// 97% (next)
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.97);
			alphaShadingLayer.graphics.drawRect(-512, -(2.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();

			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.97);
			alphaShadingLayer.graphics.drawRect(-512, (1.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();
			
			
			// 98% (last)
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.98);
			alphaShadingLayer.graphics.drawRect(-512, -(3.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();
			
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 0.98);
			alphaShadingLayer.graphics.drawRect(-512, (2.5 * ENTRY_HEIGHT), 1024, ENTRY_HEIGHT);
			alphaShadingLayer.graphics.endFill();
			
			// draw completely solid strips at the very top and bottom
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 1.0);
			alphaShadingLayer.graphics.drawRect(-512, -288-98, 1024, 100);
			alphaShadingLayer.graphics.endFill();
			
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 1.0);
			alphaShadingLayer.graphics.drawRect(-512, 288-2, 1024, 100);
			alphaShadingLayer.graphics.endFill();
			

			
			
			loadGraphState(0);
		}

		
		
		public function animateOn():void {
			
			TweenMax.fromTo(colorLine, 1.0, { x: -1024 }, { x:0, immediateRender:true } );
		}
		
		
		
		public function animateOff(callback:Function):void {
				
			// close up the color line
//			TweenMax.to(colorLine, 1.0, { x:-1024, onComplete:callback, onCompleteParams:[this] } );
			
			TweenMax.to(colorLine, 0.75, { height:0, onComplete:callback, onCompleteParams:[this] } );
	
			
			// scroll up all the numbers
			for each (var slot:SpinNumberSlot in slots) {				
				slot.moveToTopAndRetainValue();
				TweenMax.to(slot, 1.0, { y: -1000 } );
			}
			
			for each (var comma:SpinNumberComma in commas) {
				TweenMax.to(comma, 1.0, { y: -1000 } );
			}
			
			TweenMax.to(dollarSign, 1.0, { y: -1000, alpha:0 } );			
			TweenMax.to(decimalPoint, 1.0, { y: -1000, alpha:0 } );
			
			// move off text to the left
			TweenMax.to(featuredTextPanel, 0.5, { x: featuredTextPanel.x - 400 } );
			
		}
		
		
		
		protected function rollUpText():void {
			
			// note: this text is supposed to scroll up with the list on the left
			// we'll need to get the text from all graphstates at first to populate this?
						

			
			TweenMax.fromTo(featuredTextPanel, 0.3, { y: featuredTextPanel.y }, { y:featuredTextPanel.y - ENTRY_HEIGHT, immediateRender:true } );
		}
		

		
		protected var showDecimal:Boolean = false;
		protected var numDigitsAfterDecimalPoint:int = 0;

		
		public function initForNumber(value:Number):void {
			var i:int;
								
			targetValues = value.toString().split("");

			
			// show / hide decimal point
			showDecimal = ((value % 1) > 0);
			
			if (showDecimal) {
				decimalPoint.visible = true;
				
				var decimalIndex:int = targetValues.indexOf(".");
				
				numDigitsAfterDecimalPoint = (targetValues.length - 1) - decimalIndex;

				// we need to splice the "." out of targetValues
				targetValues.splice(decimalIndex, 1);
				
				if (numDigitsAfterDecimalPoint == 1) {
					// add a trailing zero
					targetValues.push("0");
					numDigitsAfterDecimalPoint = 2;
				} 
				
					
			} else {
				decimalPoint.visible = false;
				numDigitsAfterDecimalPoint = 0;
			}
			
			
			
			// add slots
			var slot:SpinNumberSlot;
						
			if (targetValues.length > slots.length) {
				// do we need more numerals?				
				while (targetValues.length > slots.length) {
					slot = new SpinNumberSlot();
					slots.push(slot);
					addChild(slot);
				}
				
			} else if (targetValues.length < slots.length) {
				// need fewer numerals
				while (targetValues.length < slots.length) {
					slot = slots.shift();
					removeChild(slot);
				}
			}

			// finalize placement of slots
			repositionSlots();
					
			
			// move the alpha thing back on top of letters
			addChild(alphaShadingLayer);
			
		}
		
				
		
		
		protected function repositionSlots():void {
			// finalize placement of slots			
			var totalWidth:Number = 0;
			
			
			// make sure we have the right number of commas
			var comma:SpinNumberComma;
				
			var numCommasRequired:int = Math.ceil((targetValues.length - numDigitsAfterDecimalPoint) / 3) - 1;
			
			while (commas.length < numCommasRequired) {			
				comma = new SpinNumberComma();
				commas.push(comma);
				addChild(comma);
			}
			
			while (commas.length > numCommasRequired) {
				comma = commas.pop();
				removeChild(comma);
			}
							
			var commaIndex:int = commas.length - 1;
			
			
			for (var i:int = 0; i < slots.length; i++) {
				
				var slot:SpinNumberSlot = slots[(slots.length-1)-i];
				
				// now we start with the least significant digit, and place digits leftwards from the origin
				// this is to make it easier to insert the comma in the right position
				var significantDigitIndex:int = i - numDigitsAfterDecimalPoint;
				
				
				if ((significantDigitIndex > 0) && ((significantDigitIndex % 3) == 0)) {
					// insert comma here
					commas[commaIndex].x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth + 18;
					totalWidth += 14;
					commaIndex--;
				}				
				
				if (showDecimal && (significantDigitIndex == 0)) {
					// figure out where to put the decimal
					decimalPoint.x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth + 15;
					totalWidth += 20;
				}
				
				slot.x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth;
				totalWidth += 50;
				
			}
	
			// place dollar sign correctly
 			dollarSign.x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth + 5;

			
			
		}
				
		
		
		
		protected function nextGraphState():void {
			loadGraphState(graphStateIndex + 1);
		}
		
		
		
		protected function loadGraphState(stateIndex:int):void {
			
			this.graphStateIndex = stateIndex;
						
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
//				flipNumber.slideOff();
				return;
			}
			
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];

			// Example XML
//			<graphstate value="1500000.50" featuredText="Psychology and psychiatry consultations take place each month." />			


			value = Number(graphStateXML.@value);
				
			
			// set text
			var featuredString:String = graphStateXML.@featuredText;
			
			// we don't need to do anything with this-- it's aready mined and the entries created in the constructor
			
			
			initForNumber(value);
			
			flipToTargetValue();
			
		}		
		
		

		
		protected function flipToTargetValue():void {
						
			rollUpText();
			
			for (var i:int = 0; i < targetValues.length; i++) {
				slots[i].startSpinning(targetValues[i], Rndm.integer(0, 50));
			}
			
			TweenMax.to(this, SpinNumberSlot.MIN_SPIN_TIME_SECS + AFTER_SPINNING_WAIT_TIME_SECONDS, {onComplete: nextGraphState});
		}		
		
		
		
		public function animate(dTime:Number):void {
			
			for each (var slot:SpinNumberSlot in slots) {
				if (slot.isSpinning) {
					slot.spin(dTime);
				}
			}
			
		}

		
	}

}