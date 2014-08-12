package med.infographic {
	import com.garin.Text;
	import com.greensock.loading.data.VideoLoaderVars;
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
		
		public static var WIDTH:Number = 1024;
		public static var HEIGHT:Number = 576;

		static public const DEFAULT_COLORS:Vector.<uint> = Vector.<uint>([
			0xe4002b, 0xFFFFFF, 0xEC4D6B, 0xf93257, 0xec244a, 0xffafbe
		]);
			
		
		public var data:InfographicData;		
		protected var background:Background;
		
		protected var initialBackgroundColor:uint;
		protected var colors:Vector.<uint>;

		public var currentSlideIndex:int = 0;
		protected var currentSlideTime:Number; // number of msec the current slide has been displayed (we count this up in animate())
		protected var slideSprite:Sprite;
		protected var previousSlideSprite:Sprite;
		protected var slideAnimatingOff:Boolean;
		
		
		protected var inputVars:Object;
		
		protected var launchRect:Rectangle;
		
		protected var endCallback:Function;

		
		protected var paused:Boolean = false;

		
		public function get isOnLastFrame():Boolean { return (currentSlideIndex == data.slides.length - 1); }
		
		
		
		public function Infographic(data:InfographicData, background:Background, colors:Vector.<uint>, launchRect:Rectangle = null) {
			this.launchRect = launchRect;
			this.data = data;
			this.background = background;
			this.colors = colors;
			
			// we store this so we can return to it when we're done with the infographic
			if (background) initialBackgroundColor = background.getTargetColor();
			
			begin();
		}
		
		protected function begin():void {
			// any user inputted data that needs to persist between slides, passed in to slides that may need it
			inputVars = { }
						
			// load first slide	
			slideAnimatingOff = false;
			currentSlideTime = 0;
			currentSlideIndex = -1;
			nextSlide();
		}
		
		public function reset():void {
			if (slideSprite) {
				if (slideSprite.parent) slideSprite.parent.removeChild(slideSprite);
				slideSprite = null;
			}
			begin();
		}
		
		
		protected function lastFrameReached():void {
			// End of sequence reached. Handling passed off to subclass
		}
		
		
		
		
		
		protected function animateSlideOff():void {
			if (slideSprite == null)	return;
			
			var nextSlideData:InfographicSlideData;				
			if (currentSlideIndex < data.slides.length - 1) {
				nextSlideData = data.slides[currentSlideIndex + 1];
			}
			
			slideAnimatingOff = true;
			
			if (slideSprite is InfographicCenterBox) {
				
				switch (data.slides[currentSlideIndex].animateOff) {
					
					case "zoomIn":
						InfographicCenterBox(slideSprite).animateOffZoom(onSlideFinished);
						break;
						
					case "squash":
						InfographicCenterBox(slideSprite).animateOffSquash(onSlideFinished);
						break;
						
					case "ignore":
						InfographicCenterBox(slideSprite).animateOffIgnore(onSlideFinished);
						break;
				
					default:	
					case "none":
						ISlide(slideSprite).animateOff(onSlideFinished);
						break;
				}
				
				
			} else if (slideSprite is ISlide) {
				// under normal circumstances, trust the ISlide to animate itself off
				ISlide(slideSprite).animateOff(onSlideFinished);
			
			} else {
				// not sure what this thing is. just get rid of it
				onSlideFinished(slideSprite);
			}

			
			
		}
		
		
		
		
		protected function forceLoadLastSlide():void {
			if (slideSprite) 	onSlideFinished(slideSprite);
			var lastSlideIndex:int = data.slides.length - 1;
			loadSlide(lastSlideIndex);
		}
			
		
		
		protected function nextSlide():void {
			var slideIndex:int = currentSlideIndex + 1;
			loadSlide(slideIndex);
		}
		

		
		protected function loadSlide(slideIndex:int, forcedLoad:Boolean=false):void {
			
			if ((slideIndex >= 0) && (slideIndex < data.slides.length) && (data.slides[slideIndex] != null)) {
				
				this.currentSlideIndex = slideIndex;

				currentSlideTime = 0;
								
				var slideData:InfographicSlideData = data.slides[slideIndex];
				
				// get some info on what (if any) the previous slide was
				var previousSlideData:InfographicSlideData;				
				if (slideIndex > 0)		previousSlideData = data.slides[slideIndex - 1];
				
				
				// store color information on the slideData to pass to the ISlide
				slideData.currentColors = this.colors.slice();
				
				slideData.currentBackgroundColor = getBackgroundColor(slideData);
				slideData.currentTextColor = getTextColor(slideData);
				slideData.currentBoxColor = getBoxColor(slideData);
				slideData.currentGraphColor1 = getGraphColor1(slideData);
				slideData.currentGraphColor2 = getGraphColor2(slideData);
				slideData.currentSelectionColor = getSelectionColor(slideData);
				
				
				
				// change the background color, if we need to
				if (background && slideData.currentBackgroundColor && (slideData.currentBackgroundColor != background.getColor())) {
					background.showColor(slideData.currentBackgroundColor);
				}
						
				
				switch (slideData.type) {
					
					case InfographicSlideData.PEOPLE_GRAPH:							
						var graph:PeopleGraph = new PeopleGraph(slideData);
						addSlideSprite(graph);						
						graph.animateOn();						
						break;
	
						
					case InfographicSlideData.TIMELINE:
						var timeline:TimelineSlide = new TimelineSlide(slideData);
						addSlideSprite(timeline);
						timeline.animateOn();
						break;
						
						
					case InfographicSlideData.TIMELINE_NUMBER:
						var timelineNumber:TimelineNumberSlide = new TimelineNumberSlide(slideData);
						addSlideSprite(timelineNumber);
						timelineNumber.animateOn();
						break;	
						
						
					case InfographicSlideData.SLIDING_TAGS:						
						var slidingTagsSlide:SlidingTagsSlide = new SlidingTagsSlide(slideData);
						addSlideSprite(slidingTagsSlide);						
						slidingTagsSlide.animateOn();
						break;

						
					case InfographicSlideData.FLOATING_BOXES:			
						var floatingBoxesSlide:FloatingBoxesSlide = new FloatingBoxesSlide(slideData, onSlideFinished);
						addSlideSprite(floatingBoxesSlide);
						floatingBoxesSlide.animateOn();
						break;
						
						
					case InfographicSlideData.SPIN_NUMBER_STRIP:						
						var spinNumberSlide:SpinNumberSlide = new SpinNumberSlide(slideData);
						addSlideSprite(spinNumberSlide);						
						spinNumberSlide.animateOn();						
						break;
						
						
					case InfographicSlideData.FLIP_NUMBER:							
						var flipNumberSlide:FlipNumberSlide = new FlipNumberSlide(slideData, onSlideFinished);
						addSlideSprite(flipNumberSlide);						
						flipNumberSlide.animateOn();						
						break;
						
						
					
					case InfographicSlideData.CENTER_TEXT_BOX:
						
						var box:InfographicCenterBox = new InfographicCenterBox(slideData);						
						addSlideSprite(box);
						
						if (forcedLoad) {
							box.animateOn();
							break;
						}
						
						
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
									box.animateOnRotate(previousSlideData.currentBoxColor);
								} else {
									box.animateOnRotate(slideData.currentBoxColor);	// this is an unusual situation
								}
								break;
					
							case "slideLeft":
								box.animateOnSlide(-1);
								break;
							case "slideRight":
								box.animateOnSlide(1);
								break;
						}
						
						break;
					
						
					case InfographicSlideData.HOTSPOT:						
						var hotspotSlide:HotspotSlide = new HotspotSlide(slideData, initialBackgroundColor, onSlideFinished);
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
						
					case InfographicSlideData.CLOCK:						
						var clockSlide:ClockSlide = new ClockSlide(slideData, initialBackgroundColor, onSlideFinished);
						addSlideSprite(clockSlide);
						clockSlide.animateOn();						
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
						
					case InfographicSlideData.CHAPTER_SUMMARY:						
						var chapterSummary:ChapterSummarySlide = new ChapterSummarySlide(slideData, initialBackgroundColor, previousSlideSprite);
						addSlideSprite(chapterSummary);
						chapterSummary.animateOn();						
						break;
						
					case InfographicSlideData.PIE_GRAPH:						
						var pieGraph:PieGraphSlide = new PieGraphSlide(slideData, initialBackgroundColor);
						addSlideSprite(pieGraph);
						pieGraph.animateOn();						
						break;
						
					case InfographicSlideData.BAR_GRAPH:						
						var barGraph:BarGraphSlide = new BarGraphSlide(slideData, initialBackgroundColor, inputVars);
						addSlideSprite(barGraph);
						barGraph.animateOn();						
						break;
						
					case InfographicSlideData.DUAL_BAR_GRAPH:						
						var dualBarGraph:DualBarGraphSlide = new DualBarGraphSlide(slideData, initialBackgroundColor);
						addSlideSprite(dualBarGraph);
						dualBarGraph.animateOn();						
						break;
						
					case InfographicSlideData.VIDEO:
						
						var videoSlide:VideoSlide = new VideoSlide(slideData, initialBackgroundColor);
						addSlideSprite(videoSlide);
						videoSlide.animateOn();
						
						break;
						
					case InfographicSlideData.RESET:
						
						var resetSlide:ResetSlide = new ResetSlide(slideData, initialBackgroundColor, onSlideFinished);
						addSlideSprite(resetSlide);
						resetSlide.animateOn();
						
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
			if (sprite != slideSprite) return;
			
			var resetAfter:Boolean = false;
			if (slideSprite is ResetSlide) resetAfter = true;
			if (slideSprite is HotspotSlide) resetAfter = true;

			slideAnimatingOff = false;
			slideSprite = null;
			
			previousSlideSprite = sprite;
			if (sprite && sprite.parent)  sprite.parent.removeChild(sprite);
			slideSprite = null;
			if (resetAfter) {
				reset();
			} else if (endCallback != null) {
				endCallback(this)
			} else {
				nextSlide();
			}
		}
		
		
		protected function animateLastSlideOff(endCallback:Function):void {
			this.endCallback = endCallback;
			animateSlideOff();
		}
		
		

		
		public function animate(dTime:Number):void {
			
			// are we paused?
			if (paused)	return;
			
			// do we even have a slide?
			if (!slideSprite || slideAnimatingOff)	return;
						
			// check whether we've exceeded the amount of time to show this slide
			currentSlideTime += dTime;
			
			var slide:ISlide = slideSprite as ISlide;
			if (slide) slide.animate(dTime);
			
			if ((data.slides[currentSlideIndex].displayTimeMsec > 0) && data.slides[currentSlideIndex] && (currentSlideTime >= data.slides[currentSlideIndex].displayTimeMsec)) { 
				
				if (currentSlideIndex < (data.slides.length-1)) {
					// remove previous slide, wait for callback to start next slide
					animateSlideOff();
				
				} else {
					//removePreviousSlide();
					lastFrameReached(); // Don't remove last frame yet - Keep it on screen until told to exit
				}
				
			}
		}
		
				
		protected function handleMouseDown(event:MouseEvent):void {			
		}
			
		
		public function pauseMedia():void {
			if (!slideSprite) return;
			if (slideSprite is VideoSlide) {
				VideoSlide(slideSprite).pauseVideo();
			}
		}
		
		
		public function resumeMedia():void {
			if (slideSprite is VideoSlide) {
				VideoSlide(slideSprite).resumeVideo();
			}
		}		
		
	
		protected function getBackgroundColor(slideData:InfographicSlideData):uint {
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@backgroundColor")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@backgroundColor) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}
		}
		
		
		protected function getBoxColor(slideData:InfographicSlideData):uint {		
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@boxColor")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@boxColor) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}

		}
		
		
		protected function getTextColor(slideData:InfographicSlideData):uint {		
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@textColor")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@textColor) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}

		}		
		
		
		protected function getGraphColor1(slideData:InfographicSlideData):uint {		
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@graphColor1")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@graphColor1) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}

		}
		
		
		protected function getGraphColor2(slideData:InfographicSlideData):uint {		
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@graphColor2")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@graphColor2) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}

		}
		
		
		protected function getSelectionColor(slideData:InfographicSlideData):uint {		
			if (slideData.xml.hasOwnProperty("appearance") && slideData.xml.appearance.hasOwnProperty("@selectionColor")) {
				var colorIndex:int = Math.max(0, int(slideData.xml.appearance.@selectionColor) - 1);
				return colors[colorIndex];
			} else {
				return 0;
			}

		}
		
		

	}

}