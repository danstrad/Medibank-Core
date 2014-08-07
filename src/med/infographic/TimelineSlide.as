package med.infographic {
	import com.garin.Text;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.BounceIn;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;

	public class TimelineSlide extends _TimelineSlide implements ISlide {

		protected var slideData:InfographicSlideData;
		
		protected var timeline:Timeline;
		
		
		public function TimelineSlide(slideData:InfographicSlideData) {
			this.slideData = slideData;
						
			// change color of fade
			var colorTransform:ColorTransform = fade.transform.colorTransform;
			colorTransform.color = slideData.backgroundColor;
			fade.transform.colorTransform = colorTransform;
			
			
			var markerFrequency:int = int(slideData.xml.@markerFrequency);
			if (markerFrequency <= 1)	markerFrequency = 10;
			
			var alwaysShowYear:Boolean = (slideData.xml.@alwaysShowYear == "true");
			var horizontalSpacing:Number = Number(slideData.xml.@lineSpacing);
			var fadeAtScreenEdges:Boolean = (slideData.xml.@fadeAtScreenEdges == "true");

			
			fade.visible = fadeAtScreenEdges;
			
			topText.visible = false;
			
			featuredText.visible = false;
						
			timeline = new Timeline(slideData, markerFrequency, showFeaturedText, alwaysShowYear, horizontalSpacing);
			timeline.y = 118;
			addChild(timeline);
			
			// fade goes above timeline, but below feature text
			addChild(fade);			
			addChild(featuredText);
			
		}
		
		public static const FEATURED_TEXT_DISPLAY_TIME_SECONDS:Number = 3.0;
		
		
		public function showFeaturedText(string:String):void {
			
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
		
		
		
		
		public function animate(dTime:Number):void {
			if (timeline) {
				timeline.animate(dTime);
			}
		}
		
		
		public function animateOn():void {
			advance();
		}
		
		
		protected function advance():void {
			featuredText.visible = false;
			timeline.advanceToNextEntry();
		}
		
		
		public function animateOff(callback:Function):void {
			callback(this);
		}

		
	}

}