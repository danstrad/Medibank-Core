package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;

	public class FlipNumberSlide extends _FlipNumberSlide implements ISlide {

		
		protected var flipNumber:FlipNumber;
		
		protected var graphStateIndex:int = 0;
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
		
		
		public static const ANIMATE_ON_TIME_SEC:Number = 0.75;
		
		protected var value:int;
		
		
		public function FlipNumberSlide(slideData:InfographicSlideData) {
				
			for each (var graphStateXML:XML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
										
			flipNumber = new FlipNumber();
			flipNumber.x = 0;
			flipNumber.y = -10;
			addChild(flipNumber);			
	
			graphStateIndex = -1;
			loadNextGraphState();
			
		}

		
		
		public function animateOn():void {
			
			flipNumber.slideOn();
		
//			waitThenAdvance(FlipNumberNumeral.SLIDE_IN_DURATION_SECS + 0.1);
			
			topField.visible = false;
			featuredField.visible = false;
			
			TweenMax.to(this, FlipNumberNumeral.SLIDE_IN_DURATION_SECS, { onComplete:flipToTargetValue } );
		}
		
		
		
		public function animateOff(callback:Function):void {
			callback(this);
		}
		
		
		
		
		protected function flipToTargetValue():void {
			flipNumber.flipToNumber(value);
			
			topField.visible = true;
			featuredField.visible = true;			
		}
		
		
		protected function waitThenAdvance(delaySeconds:Number):void {
//			TweenMax.to(this, delaySeconds, { onComplete:nextGraphState } );
		}
				
		
		
		public function loadNextGraphState():void {
			
			graphStateIndex++;
						
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
				return;
			}
			
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];

			// Example XML
//			<graphstate value="80" featuredText="Psychology and psychiatry consultations take place each month." topText="About" />			


			value = int(graphStateXML.@value);
				
			
			flipNumber.initForNumber(value);
			
			
	
			// set text
			var topString:String = graphStateXML.@topText;
			var featuredString:String = graphStateXML.@featuredText;
			
			topField.text = topString;
			Text.boldText(topField);
			Text.setTextSpacing(topField, -0.2);
			
			featuredField.text = featuredString;
			Text.boldText(featuredField);
			Text.setTextSpacing(featuredField, -0.3);
			
		}
		
		
	}

}