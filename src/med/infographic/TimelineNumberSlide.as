package med.infographic {
	import com.garin.Text;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.BounceIn;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	
	
	public class TimelineNumberSlide extends TimelineSlide implements ISlide {

		
		protected var flipNumber:FlipNumber;

		
		public function TimelineNumberSlide(slideData:InfographicSlideData) {
			super(slideData);
			
			// overwrite the timeline's callback for reaching an entry
			timeline.callbackOnReachEntry = changeFlipNumber;
			
			timeline.callbackOnLastEntryPassed = flipNumberFinished;
			
			timeline.expandEntryLineWhenReached = false;
			
			flipNumber = new FlipNumber(slideData.backgroundColor);
			flipNumber.y = -10;
			addChild(flipNumber);

			
			
			flipNumber.setStartingValue(0, 2);
			
			var topString:String = slideData.xml.featuredText;
			
			if (topString != "") {
				topText.visible = true;
				topText.text = topString;
				Text.boldText(topText);
				Text.setTextSpacing(topText, -0.3);
			
				TweenMax.fromTo(topText, 0.5, {y:topText.y+50, alpha:0}, { y:topText.y, alpha:1, delay:0.5, immediateRender:true, ease:Strong.easeInOut } ); 				
				
			} else {
				topText.visible = false;
			}
			
		}
		
		
		public function flipNumberFinished():void {
			TweenMax.to(this, 1.5, { onComplete:flipToBlank } );
		}
		
		protected function flipToBlank():void {
			flipNumber.flipToBlank(null, null);
		}
		
		
		public function changeFlipNumber(string:String):void {
			
			var value:int = parseInt(string, 10);
			
			flipNumber.initForNumber(value);
			flipNumber.flipToNumber(value);
			
			TweenMax.to(this, FEATURED_TEXT_DISPLAY_TIME_SECONDS, { onComplete:advance } );			
		}
		
		
		/*
		override public function showFeaturedText(string:String):void {
			
			featuredText.text = TextUtils.safeText(string); 
			
			featuredText.visible = true;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, -1.4);
		
			featuredText.autoSize = TextFieldAutoSize.CENTER;
			
			
			// animate on
			var targetY:Number = -33 - featuredText.height;
			var repeatDelay:Number = FEATURED_TEXT_DISPLAY_TIME_SECONDS - (2 * Timeline.REACHED_ENTRY_ANIMATION_DURATION_SECONDS);
			
			TweenMax.fromTo(featuredText, Timeline.REACHED_ENTRY_ANIMATION_DURATION_SECONDS, {y:targetY+50, alpha:0}, { y:targetY, alpha:1, repeat:1, yoyo:true, repeatDelay:repeatDelay, immediateRender:true, ease:Strong.easeInOut } ); 
			
			
			// timer to remove text
			TweenMax.to(this, FEATURED_TEXT_DISPLAY_TIME_SECONDS, { onComplete:advance } );			
		}	
		*/
		
		
	}

}