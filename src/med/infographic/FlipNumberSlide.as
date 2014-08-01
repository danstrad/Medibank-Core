package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;
	import flash.display.Shape;

	public class FlipNumberSlide extends _FlipNumberSlide implements ISlide {

		
		protected var flipNumber:FlipNumber;
		
		protected var graphStateIndex:int = 0;
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
		
		public static const ANIMATE_ON_TIME_SEC:Number = 0.75;
		public static const NUMBER_DISPLAYED_DURATION_SEC:Number = 4.0;
		
		protected static const TEXT_SLIDE_ON_DURATION_SEC:Number = 0.5;
		protected static const TEXT_SLIDE_OFF_DURATION_SEC:Number = 0.5;
		
		protected static const TEXT_SLIDE_ON_DELAY_SEC:Number = 0.3;
			
		
		
		protected var value:int;
		
		protected var normalTopFieldY:Number;
		protected var normalFeaturedFieldY:Number;
			
		
		
		public function FlipNumberSlide(slideData:InfographicSlideData) {
				
			for each (var graphStateXML:XML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
										
			flipNumber = new FlipNumber();
			flipNumber.x = 0;
			flipNumber.y = -10;
			addChild(flipNumber);			

			normalTopFieldY = topField.y;
			normalFeaturedFieldY = featuredField.y;
			
			
			
			// set up masks for the textfields
			/*
			var topFieldMask:Shape = new Shape();
			topFieldMask.graphics.beginFill(0x00FF00);
			topFieldMask.graphics.drawRect();
			topFieldMask.graphics.endFill();
			addChild(topFieldMask);			
			*/
			topField.mask = topFieldMask;
			
			/*
			var featuredFieldMask:Shape = new Shape();
			featuredFieldMask.graphics.beginFill(0x00FF00);
			featuredFieldMask.graphics.drawRect();
			featuredFieldMask.graphics.endFill();
			addChild(featuredFieldMask);
			*/
			featuredField.mask = featuredFieldMask;
			
			
			// load initial graph state. we need this before animateOn() so we know how many numerals need to appear
			loadGraphState(0);
			
		}

		
		
		public function animateOn():void {
			
			flipNumber.slideOn();
					
			topField.visible = false;
			featuredField.visible = false;
			
			TweenMax.to(this, FlipNumberNumeral.SLIDE_IN_DURATION_SECS, { onComplete:flipToTargetValue } );
		}
		
		
		
		public function animateOff(callback:Function):void {
			callback(this);
		}
		
		
		protected static const Y_ANIM_OFFSET_TOP:Number = 50;
		protected static const Y_ANIM_OFFSET_BOTTOM:Number = -100;
	
	
		protected function flipToTargetValue():void {
			flipNumber.flipToNumber(value);
		
			
			// tween on the text fields
			topField.visible = true;
			featuredField.visible = true;	
			
			
			TweenMax.fromTo(topField, TEXT_SLIDE_ON_DURATION_SEC, { y:normalTopFieldY + Y_ANIM_OFFSET_TOP }, { y:normalTopFieldY, immediateRender:true, delay:TEXT_SLIDE_ON_DELAY_SEC } );
			TweenMax.fromTo(featuredField, TEXT_SLIDE_ON_DURATION_SEC, { y:normalFeaturedFieldY + Y_ANIM_OFFSET_BOTTOM }, { y:normalFeaturedFieldY, immediateRender:true, delay:TEXT_SLIDE_ON_DELAY_SEC } );		
						
			// set listeners to tween them off
//			TweenMax.fromTo(topField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalTopFieldY }, { y:normalTopFieldY + Y_OFFSET, delay:NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_ON_DELAY_SEC } );
//			TweenMax.fromTo(featuredField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalFeaturedFieldY }, { y:normalFeaturedFieldY - Y_OFFSET, delay: NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_ON_DELAY_SEC } );		
			
			
			TweenMax.to(this, NUMBER_DISPLAYED_DURATION_SEC - TEXT_SLIDE_OFF_DURATION_SEC, { onComplete:animateOffText } );
			
		}
		

		protected function animateOffText():void {
						
			TweenMax.fromTo(topField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalTopFieldY }, { y:normalTopFieldY + Y_ANIM_OFFSET_TOP, immediateRender:true } );
			TweenMax.fromTo(featuredField, TEXT_SLIDE_OFF_DURATION_SEC, { y:normalFeaturedFieldY }, { y:normalFeaturedFieldY + Y_ANIM_OFFSET_BOTTOM, immediateRender:true } );	
			
			waitThenAdvance(TEXT_SLIDE_OFF_DURATION_SEC);
		}
		
		
		
		protected function waitThenAdvance(delaySeconds:Number):void {
			TweenMax.to(this, delaySeconds, { onComplete:nextGraphState } );
		}
		
		
		protected function nextGraphState():void {
			loadGraphState(graphStateIndex + 1);
		}
		
		
		
		protected function loadGraphState(stateIndex:int):void {
			
			this.graphStateIndex = stateIndex;
						
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
				flipNumber.slideOff();
				return;
			}
			
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];

			// Example XML
//			<graphstate value="80" featuredText="Psychology and psychiatry consultations take place each month." topText="About" />			


			value = int(graphStateXML.@value);
				
			
			// set text
			var topString:String = graphStateXML.@topText;
			var featuredString:String = graphStateXML.@featuredText;
			
			topField.text = topString;
			Text.boldText(topField);
			Text.setTextSpacing(topField, -0.2);
			
			featuredField.text = featuredString;
			Text.boldText(featuredField);
			Text.setTextSpacing(featuredField, -0.3);
			
			
			if (graphStateIndex != 0) {
				// for index 0, we need to wait for the animateOn() call to complete before we start flipping
				// otherwise, we can start it immediately
				flipToTargetValue();
			
			} else {
			
				flipNumber.initForNumber(value);

			}
			
		}
		
		
	}

}