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
			
			slideSprites = [];
			
			this.mouseChildren = false;
			
			// load first slide		
			initSlide(0);

		}
		
		
		protected function end():void {
			// End of sequence reached. Handling passed off to subclass
		}
		
		
		
		
		protected var slideSprites:Array;
		
		
		protected function removePreviousSlides():void {
			for each (var oldSlideSprite:Sprite in slideSprites) {
				
				// todo: different slide types will have different removal animations
//				TweenMax.to(oldSlideSprite, 0.5, { alpha:0, scaleX:0, scaleY:0, onComplete:removeSlideSpriteFromStage, onCompleteParams:[oldSlideSprite]});
				
				removeSlideSpriteFromStage(oldSlideSprite);
				
				slideSprites.splice(slideSprites.indexOf(oldSlideSprite), 1);
			}
						
		}
		
		
		protected function initSlide(slideIndex:int):void {
		
			// make sure any previous slides are being removed
			removePreviousSlides();
			
			
			if ((slideIndex >= 0) && (slideIndex < data.slides.length) && (data.slides[slideIndex] != null)) {
				
				currentSlideTime = 0;
				
				this.currentSlideIndex = slideIndex;
				
				var slideData:InfographicSlideData = data.slides[slideIndex];
				
				// get some info on what (if any) the previous slide was
				var previousSlideData:InfographicSlideData;				
				if (slideIndex > 0)		previousSlideData = data.slides[slideIndex - 1];
				
				
				// this is a placeholder approach
				switch (slideData.type) {
					
					case InfographicSlideData.PEOPLE_GRAPH:	
						
						// for debug
						background.showColor(0xFF0000);
						
						var graph:PeopleGraph = new PeopleGraph();
						addChild(graph);
						
						graph.animateOn();
						
						break;
	
						
					
					case InfographicSlideData.CENTER_TEXT_BOX:
						
						var box:InfographicCenterBox = new InfographicCenterBox(slideData);						
						addChild(box);
						slideSprites.push(box);
						
						if (previousSlideData && (previousSlideData.type == InfographicSlideData.CENTER_TEXT_BOX)) {
							box.animateOnRotate(previousSlideData.boxColor);
						} else {
							box.animateOn();
						}
						
						
						if (slideData.backgroundColor != background.getColor()) {
							background.fadeToColor(slideData.backgroundColor, BACKGROUND_COLOR_TRANSITION_TIME);
						}
						
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
		

		
		protected function removeSlideSpriteFromStage(sprite:Sprite):void {
			if (sprite)  removeChild(sprite);
		}
		

		
		// number of msec the current slide has been displayed (we count this up in animate())
		protected var currentSlideTime:Number = 0;
		

		public function animate(dTime:Number):void {
			
			// check whether we've exceeded the amount of time to show this slide
			currentSlideTime += dTime;
			
			if (data.slides[currentSlideIndex] && (currentSlideTime >= data.slides[currentSlideIndex].displayTimeMsec)) { 
				
				if (currentSlideIndex < (data.slides.length-1)) {
					// next slide
					initSlide(currentSlideIndex + 1);
				
				} else {
					removePreviousSlides();
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