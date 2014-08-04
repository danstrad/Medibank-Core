package med.infographic {
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;

	
	public class SpinNumberSlide extends _SpinNumberSlide implements ISlide {

		
		public static const ENTRY_HEIGHT:Number = 82;
		
		protected static const SLOT_GAP_X:Number = 62;

		protected static const RIGHT_EDGE_SLOT_OFFSET:Number = 40;
		
		
		
		protected var featuredTextPanel:Sprite;
		protected var featuredTextEntries:Vector.<FeaturedTextEntry>;
		
		protected var graphStateIndex:int = 0;
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
				
		protected var alphaShadingLayer:Shape;
		
		protected var slots:Vector.<SpinNumberSlot>;		
		protected var commas:Vector.<FlipNumberComma>;
		
		protected var targetValues:Array;
		protected var value:Number;
		
		
		public function SpinNumberSlide(slideData:InfographicSlideData) {
			
			// parse xml
			var graphStateXML:XML;
			
			for each (graphStateXML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
			
			
			commas = new Vector.<FlipNumberComma>();
			slots = new Vector.<SpinNumberSlot>();
			
			
			// build featured text panel
			featuredTextPanel = new Sprite();
			
			featuredTextPanel.x = -512;
			featuredTextPanel.y = ENTRY_HEIGHT * 0.5;
			addChild(featuredTextPanel);
			
			
			// add entries
			featuredTextEntries = new Vector.<FeaturedTextEntry>();
			
			for each (graphStateXML in graphStatesXML) {
	
				var featuredTextEntry:FeaturedTextEntry = new FeaturedTextEntry(); 			
				featuredTextEntry.textField.text = graphStateXML.@featuredText;
			
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
			alphaShadingLayer.graphics.drawRect(-512, (-BoxesMain.STAGE_HEIGHT*0.5)-98, 1024, 100);
			alphaShadingLayer.graphics.endFill();
			
			alphaShadingLayer.graphics.beginFill(slideData.backgroundColor, 1.0);
			alphaShadingLayer.graphics.drawRect(-512, (BoxesMain.STAGE_HEIGHT*0.5)-2, 1024, 100);
			alphaShadingLayer.graphics.endFill();
			

			
			
			loadGraphState(0);
		}

		
		
		public function animateOn():void {
			
			// todo: start spinning numbers
			
			TweenMax.fromTo(colorLine, 1.0, { x: -1024 }, { x:0, immediateRender:true, onComplete:rollUpText } );
		}
		
		
		
		protected function rollUpText():void {
			
			// note: this text is supposed to scroll up with the list on the left
			// we'll need to get the text from all graphstates at first to populate this?
						

			
			TweenMax.fromTo(featuredTextPanel, 0.3, { y: featuredTextPanel.y }, { y:featuredTextPanel.y - ENTRY_HEIGHT, immediateRender:true } );
		}
		
		
		
		public function animateOff(callback:Function):void {
			
			callback(this);
			
		}
		
		

		
		public function initForNumber(value:Number):void {
			var i:int;
								
			targetValues = value.toString().split("");

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
					
			
			// move the alpha thing back to the top
			addChild(alphaShadingLayer);
		}
		
				
		
		
		protected function repositionSlots():void {
			// finalize placement of slots
			
			var totalWidth:Number = 0;
			
			
			// make sure we have the right number of commas
			var comma:FlipNumberComma;
				
			var numCommasRequired:int = Math.ceil(targetValues.length / 3) - 1;
			
			while (commas.length < numCommasRequired) {			
				comma = new FlipNumberComma();
				commas.push(comma);
				addChild(comma);
			}
			
			while (commas.length > numCommasRequired) {
				comma = commas.pop();
				removeChild(comma);
			}
							
			var commaIndex:int = commas.length - 1;
			
			
			for (var i:int = slots.length - 1; i >= 0; i--) {
				
				var slot:SpinNumberSlot = slots[i];
				
				// now we start with the least significant digit, and place digits leftwards from the origin
				// this is to make it easier to insert the comma in the right position
				var significantDigitIndex:int = ((slots.length - 1) - i);
				
				
				if ((significantDigitIndex != 0) && ((significantDigitIndex % 3) == 0)) {
					// insert comma here
					commas[commaIndex].x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth + 15;
					totalWidth += 26;
					commaIndex--;
				}				
								
				slot.x = 512 - RIGHT_EDGE_SLOT_OFFSET - totalWidth;

				if (i == 0)		totalWidth += 50;
				else			totalWidth += SLOT_GAP_X;
				
			}
	
			// place dollar sign correctly
			// todo
			
// 			dollarSign

			
			
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
			
			for each (var slot:SpinNumberSlot in slots) {
				slot.startSpinning();
			}
			
//			flipNumber.flipToNumber(value);
		
			/*
			// tween on the text fields
			featuredField.visible = true;				
			TweenMax.fromTo(featuredField, TEXT_SLIDE_ON_DURATION_SEC, { y:normalFeaturedFieldY + Y_ANIM_OFFSET_BOTTOM }, { y:normalFeaturedFieldY, immediateRender:true, delay:TEXT_SLIDE_ON_DELAY_SEC } );		
						
			topField.visible = true;

			// don't animate on top text field if its the same as the last one
			if (topString != prevTopString) {
				TweenMax.fromTo(topField, TEXT_SLIDE_ON_DURATION_SEC, { y:normalTopFieldY + Y_ANIM_OFFSET_TOP }, { y:normalTopFieldY, immediateRender:true, delay:TEXT_SLIDE_ON_DELAY_SEC } );
			} else {
				topField.y = normalTopFieldY;
			}
			
			// set listeners to tween them off
//			TweenMax.fromTo(topField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalTopFieldY }, { y:normalTopFieldY + Y_OFFSET, delay:NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_ON_DELAY_SEC } );
//			TweenMax.fromTo(featuredField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalFeaturedFieldY }, { y:normalFeaturedFieldY - Y_OFFSET, delay: NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_ON_DELAY_SEC } );		
			
			
			TweenMax.to(this, NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_OFF_DURATION_SEC, { onComplete:animateOffText } );
			*/
			
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