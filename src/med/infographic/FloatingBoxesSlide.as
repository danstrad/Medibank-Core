package med.infographic {
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	import flash.filters.BlurFilter;
	
	
	public class FloatingBoxesSlide extends _FloatingBoxesSlide implements ISlide {

		
		protected var slideData:InfographicSlideData;
		
		protected var boxes:Vector.<FloatingBox>;
				
		protected var showingBoxIndex:int;
		
		
		protected static const BACK_BOX_SCALE:Number = 0.25;
		protected static const BACK_BOX_ALPHA:Number = 0.5;		
		protected static const BACK_BOX_BLUR:Number = 4;
		
		
		
		public function FloatingBoxesSlide(slideData:InfographicSlideData) {
			this.slideData = slideData;
	
			/*
				<slide type="floating_boxes" duration="10000">
					<appearance textColor="#FFFFFF" backgroundColor="#E4002B" boxColor="#ff9330"/>
					<featuredText>The service is offered across Australia in:</featuredText>	
					<box value="500" text="GP practices" />
					<box value="100" text="Aged care facilities" />
				</slide>
			*/
			
			var featuredString:String = slideData.xml.featuredText;
			
			featuredText.text = featuredString;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, 0.4);

			boxes = new Vector.<FloatingBox>();
			
			for (var i:int = 0; i < slideData.xml.box.length(); i++) {
				var boxXML:XML = slideData.xml.box[i];
				
				var box:FloatingBox = new FloatingBox(boxXML.@value, boxXML.@text, slideData.boxColor, slideData.textColor);
				boxes.push(box);
				
				box.x = i * 300;
				box.y = 0;
				
				addChild(box);
				
				// set it to background state
				box.alpha = BACK_BOX_ALPHA;
				box.scaleX = box.scaleY = BACK_BOX_SCALE;
				box.filters.push(new BlurFilter(BACK_BOX_BLUR, BACK_BOX_BLUR, 1));
				
			}
						
			
			showingBoxIndex = -1;
		}

		
		
		protected function showNextBox():void {
			
			if ((showingBoxIndex + 1) >= boxes.length) {
				// don't have another one to show
				return;
			}
			
			bringBoxToFront(showingBoxIndex + 1);
			
			// timer
			TweenMax.to(this, 4.0, { onComplete:showNextBox } );
		}
		
		
		
		protected const BOX_ANIM_TIME_SECONDS:Number = 0.75;
		
		
		
		protected function bringBoxToFront(boxIndex:int):void {
			this.showingBoxIndex = boxIndex;
						
			for each (var box:FloatingBox in boxes) {
				
				if (box == boxes[boxIndex]) {
					// bring target box forward
					TweenMax.to(box, BOX_ANIM_TIME_SECONDS, { scaleX:1.0, scaleY:1.0, alpha:1.0, blurFilter: { blurX:0, blurY:0 }, ease:SineIn.ease}); 					
				
				} else {
					// send all other boxes back
					TweenMax.to(box, BOX_ANIM_TIME_SECONDS, { scaleX:BACK_BOX_SCALE, scaleY:BACK_BOX_SCALE, alpha:BACK_BOX_ALPHA, blurFilter:{ blurX:BACK_BOX_BLUR, blurY:BACK_BOX_BLUR }, ease:SineOut.ease}); 
				}
				
			}
				
		}
		
		
		
		
		public function animateOn():void {
			
			/*
			for each (var tag:SlidingTag in tags) {
				var delay:Number = Rndm.integer(0, 100) * 0.001;
				TweenMax.fromTo(tag, TAGS_ANIMATE_ON_DURATION_SECONDS, { x:-2000 }, { x:tag.startX, immediateRender:true, delay:delay, onComplete:tag.startSway } );
			}
			*/
			
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x: -800 }, { x: featuredText.x, immediateRender:true, ease:Strong.easeOut } );
			
			showNextBox();
		}
		
		
		public function animateOff(callback:Function):void {		
		
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x:featuredText.x }, { x:-800, immediateRender:true, ease:Strong.easeIn } );
			
			// tween for timer
			TweenMax.to(this, 2.0, { onComplete:callback, onCompleteParams:[this] } );
			
		}
	
		
		public function animate(dTime:Number):void {
			
			/*
			for each (var box:FloatingBox in boxes) {
				box.animate();
			}
			*/
			
		}
		
	}

}