package med.infographic {
	import com.garin.Text;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import med.animation.SlidingAnimationData;
	
	
	public class SlidingTagsSlide extends _SlidingTagsSlide implements ISlide {

		
		protected var slideData:InfographicSlideData;
		
		protected var tags:Vector.<SlidingTag>;
		
		public static const TAG_DISPLAY_TIME_SECONDS:Number = 7.0;
		protected static const TAGS_ANIMATE_ON_DURATION_SECONDS:Number = 1.5;		
		
		
		public function SlidingTagsSlide(slideData:InfographicSlideData) {
			this.slideData = slideData;
			
			// sample xml
			/*
			<slide type="sliding_tags" />
				<appearance textColor="#FFFFFF" backgroundColor="#E4002B" boxColor="#ff9330"/>
				<featuredText>Anywhere Healthcare connects regional communities with</featuredText>
				
				<tag size="small" startLeft="true">
					<tagstate text="Allergists" />
					<tagstate text="Gynaecologists and obstetricians" />
					<tagstate text="Neurologists" />
					<tagstate text="Psychiatrists" />				
				</tag>
			*/			
			
			var featuredString:String = slideData.xml.featuredText;
			
			featuredText.text = featuredString;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, 0.4);
		
			
			// create tags
			tags = new Vector.<SlidingTag>();
			
			for (var i:int = 0; i < slideData.xml.tag.length(); i++) {				
				var tagXML:XML = slideData.xml.tag[i];
				
				var tag:SlidingTag = new SlidingTag(tagXML, slideData.currentBoxColor, slideData.currentTextColor);
				
				tags.push(tag);
				addChild(tag);
				
				// set initial tag positions			
				
				
				// space the tags out evenly height-wise based on the number and size of tags
				tag.y = 60 + (i * ((576 - 20) / slideData.xml.tag.length())) - (576 * 0.5);

			}
			
			
			TweenMax.to(this, TAG_DISPLAY_TIME_SECONDS, {onComplete:flipTags});
		}

		
		
		protected function flipTags():void {
			
			for each (var tag:SlidingTag in tags) {
				tag.flip();
			}
			
			TweenMax.to(this, TAG_DISPLAY_TIME_SECONDS, {onComplete:flipTags});
		}
		
		
		
		public function animateOn():void {
			
			for each (var tag:SlidingTag in tags) {
				var delay:Number = Rndm.integer(0, 100) * 0.001;
				TweenMax.fromTo(tag, TAGS_ANIMATE_ON_DURATION_SECONDS, { x:-2000 }, { x:tag.startX, immediateRender:true, delay:delay, onComplete:tag.startSway } );
			}
			
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x: -800 }, { x: featuredText.x, immediateRender:true, ease:Strong.easeOut } );
			
		}
		
		
		public function animateOff(callback:Function):void {
			
			for each (var tag:SlidingTag in tags) {
				var delay:Number = Rndm.integer(0, 100) * 0.001;
				TweenMax.fromTo(tag, TAGS_ANIMATE_ON_DURATION_SECONDS, { x:tag.x }, { x:2000, immediateRender:true, delay:delay, overwrite:1 } );
			}			
			
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x:featuredText.x }, { x:-800, immediateRender:true, ease:Strong.easeIn } );
			
			// tween for timer
			TweenMax.to(this, TAGS_ANIMATE_ON_DURATION_SECONDS, { onComplete:callback, onCompleteParams:[this] } );
		}
		
		
		
		public function animate(dTime:Number):void {
			
		}
		
		
	}

}