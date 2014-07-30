package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import med.display.Background;
	import flash.text.TextFieldAutoSize;


	public class Infographic extends Sprite {
		
		protected static const BACKGROUND_COLOR_TRANSITION_TIME:Number = 500;
		
		
		public var data:InfographicData;		
		protected var background:Background;
		
		public var currentSlideIndex:int = 0;
		
		protected var initialBackgroundColor:uint;
		
		
		public function Infographic(data:InfographicData, background:Background) {
			this.data = data;
			this.background = background;

			// we store this so we can return to it when we're done with the infographic
			initialBackgroundColor = background.getColor();
			
			// load first slide	
			currentSlideIndex = -1;
			nextSlide();

		}
		
		
		protected function end():void {
			// End of sequence reached. Handling passed off to subclass
		}
		
		
		
		
		protected var slideSprite:Sprite;
		
		
		protected function removePreviousSlide():void {		
			if (slideSprite == null)	return;
			
			trace("removePreviousSprite");
			
			var nextSlideData:InfographicSlideData;				
			if (currentSlideIndex < data.slides.length - 1) {
				nextSlideData = data.slides[currentSlideIndex + 1];
			}
				
			if (slideSprite is InfographicCenterBox) {
				
				if (!nextSlideData || (nextSlideData && (nextSlideData.type != InfographicSlideData.CENTER_TEXT_BOX))) {
					// if the next slide is NOT also a center box, we need to use a different exit animation (squash)
					InfographicCenterBox(slideSprite).animateOffSquash(removeSlideSpriteFromStage);
				} else {
					ISlide(slideSprite).animateOff(removeSlideSpriteFromStage);
				}
				
			} else if (slideSprite is ISlide) {
				// under normal circumstances, trust the ISlide to animate itself off
				ISlide(slideSprite).animateOff(removeSlideSpriteFromStage);
			
			} else {
				// not sure what this thing is. just get rid of it
				removeSlideSpriteFromStage(slideSprite);
			}

			slideSprite = null;
			
		}
		
		
		
		protected function nextSlide():void {
		
			// make sure previous slide is removed
			removePreviousSlide();
			
			var slideIndex:int = currentSlideIndex + 1;
			
			
			if ((slideIndex >= 0) && (slideIndex < data.slides.length) && (data.slides[slideIndex] != null)) {
				
				this.currentSlideIndex = slideIndex;

				currentSlideTime = 0;
								
				var slideData:InfographicSlideData = data.slides[slideIndex];
				
				// get some info on what (if any) the previous slide was
				var previousSlideData:InfographicSlideData;				
				if (slideIndex > 0)		previousSlideData = data.slides[slideIndex - 1];
				
				
				// this is a placeholder approach
				switch (slideData.type) {
					
					case InfographicSlideData.PEOPLE_GRAPH:	
						
						// for debug
						background.showColor(0xFF0000);
						
						var graph:PeopleGraph = new PeopleGraph(slideData);
						addSlideSprite(graph);
						
						graph.animateOn();
						
						break;
	
						
					
					case InfographicSlideData.CENTER_TEXT_BOX:
						
						var box:InfographicCenterBox = new InfographicCenterBox(slideData);						
						addSlideSprite(box);
						
						if (previousSlideData && (previousSlideData.type == InfographicSlideData.CENTER_TEXT_BOX)) {
							box.animateOnRotate(previousSlideData.boxColor);
						} else {
							box.animateOn();
						}
						
						
						if (slideData.backgroundColor != background.getColor()) {
							background.fadeToColor(slideData.backgroundColor, BACKGROUND_COLOR_TRANSITION_TIME);
						}
						
						break;
					
						
					case InfographicSlideData.HOTSPOT:
						
						var hotspotSlide:HotspotSlide = new HotspotSlide(slideData, initialBackgroundColor);
						addSlideSprite(hotspotSlide);
						hotspotSlide.animateOn();
						
						break;
						
					default:
						end();
						break;
				}
				
				
			} else {
				// invalid slide index
				trace("attempted to load an invalid slide index. exiting early");
				end();
			}
		}
		

		
		protected function addSlideSprite(sprite:Sprite):void {
			this.slideSprite = sprite;
			addChild(sprite);
		}
		
		
		
		protected function removeSlideSpriteFromStage(sprite:Sprite):void {
			if (sprite && sprite.parent)  sprite.parent.removeChild(sprite);
			nextSlide();
		}
		

		
		// number of msec the current slide has been displayed (we count this up in animate())
		protected var currentSlideTime:Number = 0;
		

		public function animate(dTime:Number):void {
			
			// check whether we've exceeded the amount of time to show this slide
			currentSlideTime += dTime;
			
			if (data.slides[currentSlideIndex] && (currentSlideTime >= data.slides[currentSlideIndex].displayTimeMsec)) { 
				
				if (currentSlideIndex < (data.slides.length-1)) {
					// remove previous slide, was for callback to start next slide
					removePreviousSlide();
				
				} else {
					removePreviousSlide();
					end();
				}
				
			}
		}
		
		
		
		protected function handleMouseDown(event:MouseEvent):void {

			/*
			if (currentSlideIndex < (data.slides.length-1)) {
				initSlide(currentSlideIndex + 1);
			} else {
				removePreviousSlides();
				end();
			}
			*/
			
		}
		
		
		

	}

}