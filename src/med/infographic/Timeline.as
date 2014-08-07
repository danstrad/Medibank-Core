package med.infographic {
	import com.garin.Text;
	import com.greensock.easing.SineInOut;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class Timeline extends _Timeline {

		
		protected static const LINE_HEIGHT_NORMAL:Number 		= 21.35;
		protected static const LINE_HEIGHT_ENTRY:Number 		= 37.35;
		protected static const LINE_HEIGHT_MARKER:Number 		= 32;
		protected static const LINE_HEIGHT_MARKER_ENTRY:Number 	= 48.05;

		protected static const LINE_HEIGHT_CURRENT:Number 		= 111.45;
		
		protected static const LINE_WIDTH:Number = 2.65;
		
		
//		protected static const LINE_HORIZONTAL_SPACING:Number 		= 22;
//		protected static const LINE_HORIZONTAL_SPACING_WIDE:Number 	= 63;
		
		protected var horizontalSpacing:Number = 22;
		
		
		protected var lines:Vector.<Shape>;
		
		protected var scrollingLayer:Sprite;
		
		protected var entryIndex:int;		// the index of the most recent entry
		
		protected var slideData:InfographicSlideData;
		
		
		protected var startYear:int;
		protected var endYear:int;		
		protected var numYears:int;
	
		protected var targetIndex:int;		
		public var isScrolling:Boolean;
			
		public var callbackOnReachEntry:Function;
		public var callbackOnLastEntryPassed:Function;
	
		protected static const SCROLL_SPEED_PER_SECOND:Number = 200;
		
				
		protected var alwaysShowYear:Boolean;
		
		
		public function Timeline(slideData:InfographicSlideData, markerFrequency:int, callbackOnReachEntry:Function, alwaysShowYear:Boolean, horizontalSpacing:Number) {
			this.callbackOnReachEntry = callbackOnReachEntry;
			this.horizontalSpacing = horizontalSpacing;
			this.alwaysShowYear = alwaysShowYear;
			this.slideData = slideData;
			
			
			scrollingLayer = new Sprite();
			addChild(scrollingLayer);
			
			lines = new Vector.<Shape>();
			
			// parse all the graphstates
			// this is a slow way to do it

			var YEAR_EDGE_BUFFER:int = 10;	
			
			startYear = int(slideData.xml.graphstate[0].@value) - YEAR_EDGE_BUFFER;
			endYear = int(slideData.xml.graphstate[slideData.xml.graphstate.length()-1].@value) + YEAR_EDGE_BUFFER;
			
			numYears = (endYear-startYear);
			
			
			
			for (var i:int = 0; i < numYears; i++) {
			
				var isEntry:Boolean = isThereAnEntryForYear(startYear + i);
				
				
				var line:Shape = new Shape();
				
				var lineHeight:Number;
				
				if (markerFrequency && (((startYear + i) % markerFrequency) == 0)) {
					// 'decade' marker
					if (isEntry) {
						lineHeight = LINE_HEIGHT_MARKER_ENTRY;
					} else {
						lineHeight = LINE_HEIGHT_MARKER;
					}
				
				} else {
					if (isEntry) {
						lineHeight = LINE_HEIGHT_ENTRY;
					} else {
						lineHeight = LINE_HEIGHT_NORMAL;
					}
				}
				
				var alpha:Number;
				
				if (isEntry)	alpha = 1.0;
				else			alpha = 0.4;
				
				line.graphics.beginFill(0xFFFFFF, alpha);
				
				line.graphics.drawRect(-LINE_WIDTH * 0.5, -lineHeight, LINE_WIDTH, lineHeight);
				line.graphics.endFill();
				
				line.x = i * horizontalSpacing;
				line.y = 0;
				
				scrollingLayer.addChild(line);
				lines.push(line);
			}

			
//			jumpToLineIndex(YEAR_EDGE_BUFFER);
			
			entryIndex = -1;
			
			
			indexOffsetToGetOffScreen = Math.ceil(500 / horizontalSpacing);
			jumpToLineIndex(-indexOffsetToGetOffScreen);
			
			updateYearField();
		}

		
		protected var indexOffsetToGetOffScreen:int = 22;

		
		
		protected function isThereAnEntryForYear(year:int):Boolean {		
			return (getEntryDataForYear(year) != null);
		}
		
		
		protected function getEntryDataForYear(year:int):XML {
			for (var i:int = 0; i < slideData.xml.graphstate.length(); i++) {
				var stateXML:XML = slideData.xml.graphstate[i];
				
				/*
				<graphstate value="1976" bottomText="1976" featuredText="Medibank established." />
				*/	
				if (int(stateXML.@value) == year)	return stateXML;
			}			
			return null;
		}
		
		
		
		
		public function jumpToLineIndex(index:int):void {
			var targetX:Number = index * horizontalSpacing;
			
			// jump
			scrollingLayer.x = -targetX;
		}
		
		
		
		
		
		public function advanceToNextEntry():void {
			
			entryIndex++;

			if (entryIndex >= slideData.xml.graphstate.length()) {
				// no more entries! just advance to )past) the end
				targetIndex = numYears + indexOffsetToGetOffScreen;
				isScrolling = true;
				TweenMax.to(yearText, 0.5, { delay:1.0, alpha:0 } );
				
				if (callbackOnLastEntryPassed != null) {
					callbackOnLastEntryPassed();
				}				
				return;
			}
			
			var stateXML:XML = slideData.xml.graphstate[entryIndex];
				
			targetIndex = int(stateXML.@value) - startYear;
			isScrolling = true;
		}
		
		

		protected function get currentIndex():int {
			return -(Math.floor(scrollingLayer.x / horizontalSpacing));
		}
		
		
		public function animate(dTime:Number):void {
			var oldIndex:int = currentIndex;
			
			if (isScrolling && (targetIndex != -1)) {
				
				var toMove:Number = dTime * (SCROLL_SPEED_PER_SECOND * 0.001);
				scrollingLayer.x -= toMove;
					
				if (currentIndex > oldIndex) {
					updateYearField();
					
					if ((oldIndex >= 0) && (oldIndex < numYears) && lines[oldIndex]) {
						// little 'bounce'
//						TweenMax.to(lines[oldIndex], 0.25, { y: -5, repeat:1, yoyo:true, ease:SineInOut.ease } );
					}
				}			
								
				if ((targetIndex < numYears) && (scrollingLayer.x <= -lines[targetIndex].x)) {
					scrollingLayer.x = -lines[targetIndex].x;
					isScrolling = false;
					targetIndex = -1;
					finishedAdvance();
				}
				
			}
			
		}
		
		
		
		
		public static const REACHED_ENTRY_ANIMATION_DURATION_SECONDS:Number = 0.5;
		
		
		public var expandEntryLineWhenReached:Boolean = true;
		
		
		public function finishedAdvance():void {			
			
			var featuredString:String = "";
			
			var entryXML:XML = getEntryDataForYear(startYear + currentIndex);
			
			trace("attempted to get entryXML: ", startYear, currentIndex, startYear + currentIndex);
			
			if (entryXML) {
				featuredString = entryXML.@featuredText;

				if (expandEntryLineWhenReached) {					
					var centerLine:Shape = lines[currentIndex];			
					var repeatDelay:Number = TimelineSlide.FEATURED_TEXT_DISPLAY_TIME_SECONDS - (2 * Timeline.REACHED_ENTRY_ANIMATION_DURATION_SECONDS);

					TweenMax.to(centerLine, REACHED_ENTRY_ANIMATION_DURATION_SECONDS, { y:20, height: LINE_HEIGHT_CURRENT, repeat:1, yoyo:true, repeatDelay:repeatDelay, ease:Strong.easeInOut } );
				}
				
			}
			
			callbackOnReachEntry(featuredString);
			
			updateYearField(true);
		}
		
		
		
		
		protected function updateYearField(atEntry:Boolean=false):void {
			
			if ((alwaysShowYear == false) && (atEntry == false)) {
				yearText.visible = false;
				return;
			}
			
			if (currentIndex < 0) {
				yearText.visible = false;
				return;
					
			} else if (currentIndex == 0) {	
				TweenMax.fromTo(yearText, 0.5, { alpha:0 }, {alpha:1.0, immediateRender:true} );
			}
			
			
			
			var string:String;
			
			if (atEntry) {
				var entryXML:XML = getEntryDataForYear(startYear + currentIndex);
			
				if (entryXML != null) {
					// find text to display for entry					
					string = TextUtils.safeText(entryXML.@bottomText);
				}
			}
			
			if (string == null) {
				// or find closest year
				string = String(startYear + currentIndex); 
			}

			yearText.visible = true;
			
			yearText.text = string;
			
			Text.boldText(yearText);
			Text.setTextSpacing(yearText, -0.3);
			
			
//			debugField.text = String(currentIndex);
			
		}
		
		
	}

}