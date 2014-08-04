package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Background;
	import flash.text.TextFieldAutoSize;


	public class Infographic extends Sprite {
		
		
		public var data:InfographicData;		
		protected var background:Background;
		
		public var currentSlideIndex:int = 0;
		
		protected var initialBackgroundColor:uint;
		
		protected var inputVars:Object;
		
		protected var launchRect:Rectangle;
		
		protected var endCallback:Function;

		
		public function Infographic(data:InfographicData, background:Background, launchRect:Rectangle = null) {
			this.launchRect = launchRect;
			this.data = data;
			this.background = background;

			// we store this so we can return to it when we're done with the infographic
			initialBackgroundColor = background.getColor();
			
			// any user inputted data that needs to persist between slides, passed in to slides that may need it
			inputVars = { }
			
			// load first slide	
			currentSlideIndex = -1;
			nextSlide();

		}
		
		
		protected function lastFrameReached():void {
			// End of sequence reached. Handling passed off to subclass
		}
		
		
		
		
		protected var slideSprite:Sprite;
		
		
		protected function removePreviousSlide():void {		
			if (slideSprite == null)	return;
			
			trace("removePreviousSprite");
			
			var oldSlideSprite:Sprite = slideSprite;
			slideSprite = null;
			
			var nextSlideData:InfographicSlideData;				
			if (currentSlideIndex < data.slides.length - 1) {
				nextSlideData = data.slides[currentSlideIndex + 1];
			}
				
			if (oldSlideSprite is InfographicCenterBox) {
				
				switch (data.slides[currentSlideIndex].animateOff) {
					
					case "zoomIn":
						InfographicCenterBox(oldSlideSprite).animateOffZoom(onSlideFinished);
						break;
						
					case "squash":
						InfographicCenterBox(oldSlideSprite).animateOffSquash(onSlideFinished);
						break;
						
					default:	
					case "none":
						ISlide(oldSlideSprite).animateOff(onSlideFinished);
						break;
				
				}
				
				
			} else if (oldSlideSprite is ISlide) {
				// under normal circumstances, trust the ISlide to animate itself off
				ISlide(oldSlideSprite).animateOff(onSlideFinished);
			
			} else {
				// not sure what this thing is. just get rid of it
				onSlideFinished(oldSlideSprite);
			}

			
			
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
				
				
				if (slideData.backgroundColor && (slideData.backgroundColor != background.getColor())) {
					background.showColor(slideData.backgroundColor);
				}
						
				
				// this is a placeholder approach
				switch (slideData.type) {
					
					case InfographicSlideData.PEOPLE_GRAPH:	
						
						var graph:PeopleGraph = new PeopleGraph(slideData);
						addSlideSprite(graph);
						
						graph.animateOn();
						
						break;
	
						
					case InfographicSlideData.SPIN_NUMBER_STRIP:
						
						var spinNumberSlide:SpinNumberSlide = new SpinNumberSlide(slideData);
						addSlideSprite(spinNumberSlide);
						
						spinNumberSlide.animateOn();
						
						break;
						
						
					case InfographicSlideData.FLIP_NUMBER:
							
						var flipNumberSlide:FlipNumberSlide = new FlipNumberSlide(slideData);
						addSlideSprite(flipNumberSlide);
						
						flipNumberSlide.animateOn();
						
						break;
						
						
					
					case InfographicSlideData.CENTER_TEXT_BOX:
						
						var box:InfographicCenterBox = new InfographicCenterBox(slideData);						
						addSlideSprite(box);
						
						
						switch (data.slides[currentSlideIndex].animateOn) {
							
							
							case "launch":
								box.animateOnLaunch(launchRect || new Rectangle(0, 0, 0, 0));
								break;
							
							case "none":
								box.animateOnNone();
								break;
							
							default:	
							case "squash":
								box.animateOn();
								break;
								
							case "zoom":
								box.animateOnZoom();
								break;
								
							case "rotate":
								if (previousSlideData && (previousSlideData.type == InfographicSlideData.CENTER_TEXT_BOX)) {
									box.animateOnRotate(previousSlideData.boxColor);
								} else {
									box.animateOnRotate(slideData.boxColor);	// this is an unusual situation
								}
								break;
					
						}
						
						break;
					
						
					case InfographicSlideData.HOTSPOT:
						
						var hotspotSlide:HotspotSlide = new HotspotSlide(slideData, initialBackgroundColor);
						addSlideSprite(hotspotSlide);
						hotspotSlide.animateOn();
						
						break;
						
					case InfographicSlideData.SPLASH_TEXT:
						
						var splashSlide:SplashTextSlide = new SplashTextSlide(slideData, initialBackgroundColor);
						addSlideSprite(splashSlide);
						splashSlide.animateOn();
						
						break;
						
					case InfographicSlideData.TIME_DIALS:
						
						var dialsSlide:TimeDialsSlide = new TimeDialsSlide(slideData, initialBackgroundColor, inputVars, onSlideFinished);
						addSlideSprite(dialsSlide);
						dialsSlide.animateOn();
						
						break;
						
					case InfographicSlideData.PICK3_INPUT:
						
						var pick3InputSlide:Pick3InputSlide = new Pick3InputSlide(slideData, initialBackgroundColor, inputVars, onSlideFinished);
						addSlideSprite(pick3InputSlide);
						pick3InputSlide.animateOn();
						
						break;
						
					case InfographicSlideData.PICK3_RESULTS:
						
						var pick3ResultsSlide:Pick3ResultsSlide = new Pick3ResultsSlide(slideData, initialBackgroundColor, inputVars, onSlideFinished);
						addSlideSprite(pick3ResultsSlide);
						pick3ResultsSlide.animateOn();
						
						break;
						
					default:
						lastFrameReached();
						break;
				}
				
				
			} else {
				// invalid slide index
				trace("attempted to load an invalid slide index. exiting early");
				lastFrameReached();
			}
		}
		

		
		protected function addSlideSprite(sprite:Sprite):void {
			this.slideSprite = sprite;
			addChild(sprite);
		}
		
		
		
		protected function onSlideFinished(sprite:Sprite):void {
			if (sprite && sprite.parent)  sprite.parent.removeChild(sprite);
			slideSprite = null;
			if (endCallback != null) {
				endCallback(this)
			} else {
				nextSlide();
			}
		}
		
		protected function animateLastSlideOff(endCallback:Function):void {
			this.endCallback = endCallback;
			removePreviousSlide();			
		}
		
		

		
		// number of msec the current slide has been displayed (we count this up in animate())
		protected var currentSlideTime:Number = 0;
		

		public function animate(dTime:Number):void {
			
			// do we even have a slide?
			if (!slideSprite)	return;
			
			
			// check whether we've exceeded the amount of time to show this slide
			currentSlideTime += dTime;
			
			var slide:ISlide = slideSprite as ISlide;
			if (slide) slide.animate(dTime);
			
			if ((data.slides[currentSlideIndex].displayTimeMsec > 0) && data.slides[currentSlideIndex] && (currentSlideTime >= data.slides[currentSlideIndex].displayTimeMsec)) { 
				
					if (currentSlideIndex < (data.slides.length-1)) {
					// remove previous slide, wait for callback to start next slide
					removePreviousSlide();
				
				} else {
					//removePreviousSlide();
					lastFrameReached(); // Don't remove last frame yet - Keep it on screen until told to exit
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