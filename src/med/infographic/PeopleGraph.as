package med.infographic {
	import com.garin.ColorMatrix;
	import com.garin.Text;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class PeopleGraph extends _PeopleGraph implements ISlide {

		// using a static array for this for performance / memory reasons
		protected static var people:Vector.<PeopleGraphPerson>;
				
		protected var extraPeople:Vector.<PeopleGraphPerson>;
		
		protected static const PEOPLE_SPACING:Number = 43;
		
		protected static const LEFTMOST_X_POSITION:Number = -415;
		protected static const RIGHTMOST_X_POSITION:Number = 415;
		protected static const RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT:Number = 205;
				
		protected static const START_X_POSITION:Number = -192;
		protected static const START_Y_POSITION:Number = -189;		
		
		protected static const BOTTOM_TEXT_LOWER_BOUND:Number = 490;
		
		protected static const PEOPLE_TRANSITION_TIME_SEC:Number = 1.0; 
		protected static const PEOPLE_COLOR_CHANGE_TIME_SEC:Number = 0.5;
		
		
		protected static const MIN_TEXT_ANIMATE_ON_DELAY:Number = 1.4;
		
		protected static const TEXT_SLIDE_DURATION_SEC:Number = 0.3;
		
		protected static const TEXT_ANIMATE_OFFSET_LEFT:Number = -300;
		protected static const TEXT_ANIMATE_OFFSET_RIGHT:Number = 300;
		
		public static const GRAPH_STATE_DURATION_MIN_SEC:Number = 3.5;		
		
		public static const ANIMATE_ON_DURATION_SEC:Number = 1.5;
		public static const ANIMATE_OFF_DURATION_SEC:Number = 1.5;
		
		
		
		
		public var isInNeutralState:Boolean;
		
		
		public var slideData:InfographicSlideData;
		
		
		protected var graphStateIndex:int = 0;
		
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
				
		protected var textPanelMask:Shape;
		

		
		public function PeopleGraph(slideData:InfographicSlideData) {
			var i:int;
			
			this.slideData = slideData;
			
			for each (var graphStateXML:XML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
				
			graphStateIndex = -1;
			

			if (people == null) {
				// create vector for graphical representation of people for the first time
				people = new Vector.<PeopleGraphPerson>();
				
				for (i = 0; i < 100; i++) {
					var person:PeopleGraphPerson = new PeopleGraphPerson(slideData.currentBoxColor);
					people.push(person);	 
				}
			}
			
			// reset the graph to the "start" position
			
			for (i = 0; i < 100; i++) {
				var xIndex:int = i % 10;
				var yIndex:int = Math.floor(i / 10);

				people[i].rowIndex = yIndex;
				people[i].columnIndex = xIndex; 
				
				people[i].x = START_X_POSITION + (xIndex * PEOPLE_SPACING);
				people[i].y = START_Y_POSITION + (yIndex * PEOPLE_SPACING);
				
				people[i].state = PeopleGraphPerson.STATE_NEUTRAL;
				
				people[i].visible = false;
				people[i].drawColor = slideData.currentBoxColor;
				people[i].reset();
				
				if (people[i].parent) {
					people[i].parent.removeChild(people[i]);
				}
				
				addChild(people[i]);
			}
			
			
			isInNeutralState = true;
			
			
			textPanelMask = new Shape();
			
			textPanelMask.graphics.beginFill(0x00FF00, 0.5);
			textPanelMask.graphics.drawRect(-30, 0, 300, 600); 
			textPanelMask.graphics.endFill();
			
			textPanelMask.x = textPanel.x;
			textPanelMask.y = textPanel.y;
			textPanel.mask = textPanelMask;
			addChild(textPanelMask);
			
			// hide text
			textPanel.visible = false;
		}


		
		public function animate(dTime:Number):void {
			
			if (isAnimatingOn) {
			
				for each (var person:PeopleGraphPerson in people) {
					person.animate(dTime);
				}
			
			}			
		}
		
		
		protected var isAnimatingOn:Boolean = false;
		
		
		public function animateOn():void {
			// have the circles gradually appear in the neutral position
			
			// we want to stagger their appearance
			var rndm:Rndm = new Rndm();
			
			for each (var person:PeopleGraphPerson in people) {
				var animationDelayMsec:Number = Number(rndm.integer(0, 400));
				person.animateOnPerson(animationDelayMsec);
			}
					
			isAnimatingOn = true;
			
			// wait until this finishes, then advance to the next (first) graph state
			waitThenAdvance(ANIMATE_ON_DURATION_SEC);
		}
		
		
		protected function waitThenAdvance(delaySeconds:Number):void {
			TweenMax.to(this, delaySeconds, { onComplete:nextGraphState } );
		}
		
		
		protected static const ANIMATE_PEOPLE_ON_OFF_OFFSET_X:Number = 512;
		
		
		public function animateOff(callback:Function):void {
							
			var delayBase:Number = 0;
			
			if (extraPeople && extraPeople.length) {
				delayBase = PEOPLE_DELAY_CONSTANT * Math.min(numExtraColumnsAllowed, extraPeople.length / 10);
			}
			
			for each (var person:PeopleGraphPerson in people) {
				
				var targetX:Number;
				var delay:Number = 0;
				
				if (person.state == PeopleGraphPerson.STATE_RIGHT) {
					targetX = person.x + ANIMATE_PEOPLE_ON_OFF_OFFSET_X;
					delay = ((10 - person.columnIndex) * PEOPLE_DELAY_CONSTANT);
				} else {
					targetX = person.x - ANIMATE_PEOPLE_ON_OFF_OFFSET_X;
					delay = (person.columnIndex * PEOPLE_DELAY_CONSTANT);
				}
				
				TweenMax.to(person, 1.25, { x:targetX, delay:delayBase + delay, ease:Strong.easeIn } );
			}
			
			
			// remove extra people (if any)
			flyOffExtraDots();
		
			// wait, then callback
			TweenMax.to(this, ANIMATE_OFF_DURATION_SEC, { onComplete:callback, onCompleteParams:[this] });
			
		}

		
		protected function flyOffExtraDots():void {
			// remove extra people (if any)
			
			for each (var person:PeopleGraphPerson in extraPeople) {				
				var targetX:Number;				
				var delay:Number;
				
				if (person.state == PeopleGraphPerson.STATE_RIGHT) {
					targetX = person.x + ANIMATE_PEOPLE_ON_OFF_OFFSET_X;
					delay = (((10 + numExtraColumnsAllowed) - person.columnIndex) * PEOPLE_DELAY_CONSTANT);
					
				} else {
					targetX = person.x - ANIMATE_PEOPLE_ON_OFF_OFFSET_X;
					delay = ((person.columnIndex + numExtraColumnsAllowed) * PEOPLE_DELAY_CONSTANT);
				}	
				
				TweenMax.to(person, 1.25, { x:targetX, delay:delay, ease:Strong.easeIn, onComplete:person.remove } );				
			}		
			
			extraPeople = new Vector.<PeopleGraphPerson>();
		}

		
		
		protected var textLength:int;
		
		
		
		public function nextGraphState():void {
			
			graphStateIndex++;
			
			isAnimatingOn = false;
			
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
				return;
			}
			
			if (extraPeople && extraPeople.length) {
				flyOffExtraDots();
			}
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];
			
			// Example XML
			//<graphstate value="33" featuredText="1 in 3" usePercentage="false" topText="" bottomText="Consultations for patients up to the age of 15 are for dermatology." />

			var value:int = int(graphStateXML.@value);			
			var isWhiteOnLeft:Boolean = ((graphStateIndex % 2) == 0);			
			var isTextOnRightEdge:Boolean = (graphStateXML.@textOnRightEdge == "true");			
						
			
			// sanity checking on value
			var extraDotsRequired:int = Math.max(0, value-100);
			
			value = Math.min(value, 100);
			value = Math.max(value, 0);
									
			
			// animate people
			animateToGraphState(value, isWhiteOnLeft, isTextOnRightEdge);
			
			
			if (extraDotsRequired > 0) {
				flyOnExtraDots(extraDotsRequired, isWhiteOnLeft, isTextOnRightEdge);
			}
			
			
			// set up text	
			textPanel.visible = true;
			
				// textpanel alignment
			var textAnimationStartOffset:Number = 0;
			
			if (isTextOnRightEdge) {
				// some graph states have the text data all the way on the right edge of the screen, with both groups of people to its left
				textPanel.x = RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT + 48;
				textAnimationStartOffset = TEXT_ANIMATE_OFFSET_LEFT;
				
			} else if (isWhiteOnLeft) {
				textPanel.x = LEFTMOST_X_POSITION + (Math.floor(value / 10) * PEOPLE_SPACING) + 50;	
				textAnimationStartOffset = TEXT_ANIMATE_OFFSET_LEFT;

			} else {
				textPanel.x = (RIGHTMOST_X_POSITION - (Math.floor(value / 10) * PEOPLE_SPACING)) - 280;	
				textAnimationStartOffset = TEXT_ANIMATE_OFFSET_RIGHT;
			}
				
			
			textPanelMask.x = textPanel.x;

			// text panels contents and animation
			var bottomTextString:String = TextUtils.safeText(graphStateXML.@bottomText);
			var topTextString:String = TextUtils.safeText(graphStateXML.@topText);			
			var featuredTextString:String = TextUtils.safeText(graphStateXML.@featuredText);
			var usePercentage:Boolean = (graphStateXML.@usePercentage == "true");
			
				
			textLength = topTextString.length + bottomTextString.length + featuredTextString.length;
							
			
			
			if (topTextString.length) {
				
				textPanel.topField.x = 0;
				textPanel.topField.text = topTextString;
				textPanel.topField.visible = true;
				Text.boldText(textPanel.topField);
				Text.setTextSpacing(textPanel.topField, -0.6);
				
				slideTextOn(textPanel.topField, MIN_TEXT_ANIMATE_ON_DELAY + 0.1, textAnimationStartOffset);
				slideTextOff(textPanel.topField, currentStateDisplayDurationSeconds - TEXT_SLIDE_DURATION_SEC - 0.1, textAnimationStartOffset);				
				
			} else {
				textPanel.topField.visible = false;
				
			}			

			if (usePercentage && (topTextString.length == 0)) {
				// if there's no top-text, move the percentage up
				textPanel.percentageField.y = 47;
				textPanel.percentageSignField.y = 61;					
			
			} else {
				// move these back to their normal positions
				textPanel.percentageField.y = 91;
				textPanel.percentageSignField.y = 105;
			}
				
			
			
			
			if (usePercentage) {
				
				textPanel.percentageField.x = 0;
				
				textPanel.percentageField.text = featuredTextString;
				Text.boldText(textPanel.percentageField);
				Text.setTextSpacing(textPanel.percentageField, -7);	
				textPanel.percentageField.autoSize = TextFieldAutoSize.LEFT;				
				textPanel.percentageField.visible = true;

				textPanel.percentageSignField.visible = true;
				textPanel.percentageSignField.x = textPanel.percentageField.x + textPanel.percentageField.width + 1;
				
				
				textPanel.featuredField.visible = false;
				
				slideTextOn(textPanel.percentageField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.percentageField, currentStateDisplayDurationSeconds - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				

				slideTextOn(textPanel.percentageSignField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.percentageSignField, currentStateDisplayDurationSeconds - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				
				
				
			} else {
				
				textPanel.featuredField.x = -10;
				
				textPanel.featuredField.text = featuredTextString;
				Text.boldText(textPanel.featuredField);
				Text.setTextSpacing(textPanel.featuredField, -2);
				textPanel.featuredField.visible = true;
				
				textPanel.percentageField.visible = false;
				textPanel.percentageSignField.visible = false;
				
				slideTextOn(textPanel.featuredField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.featuredField, currentStateDisplayDurationSeconds - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				

			}
			
			
			if (bottomTextString.length) {

				textPanel.bottomField.x = 0;
				textPanel.bottomField.visible = true;

				textPanel.bottomField.text = bottomTextString;
				Text.boldText(textPanel.bottomField);
				Text.setTextSpacing(textPanel.bottomField, -0.6);
				textPanel.bottomField.autoSize = TextFieldAutoSize.LEFT;

				textPanel.bottomField.y = (BOTTOM_TEXT_LOWER_BOUND - textPanel.bottomField.height) + 12;
				
			
				slideTextOn(textPanel.bottomField, MIN_TEXT_ANIMATE_ON_DELAY + 0.2, textAnimationStartOffset + 0.35);
				slideTextOff(textPanel.bottomField, currentStateDisplayDurationSeconds - TEXT_SLIDE_DURATION_SEC - 0.1, textAnimationStartOffset);				
				
			} else {
				textPanel.bottomField.visible = false;
			}
			
			
			waitThenAdvance(currentStateDisplayDurationSeconds);
			
		}
		
		
		
		protected static function slideTextOn(textField:TextField, delay:Number, xOffset:Number):void {			
			TweenMax.fromTo(textField, TEXT_SLIDE_DURATION_SEC, { x: xOffset }, { x:textField.x, immediateRender:true, delay:delay } );
		}
		
		
		
		protected static function slideTextOff(textField:TextField, delay:Number, xOffset:Number):void {
			TweenMax.to(textField, TEXT_SLIDE_DURATION_SEC, { x: xOffset, delay:delay, overwrite:5 } );
		}		
		

		
		protected var previousStateWasOffsetFromRightEdge:Boolean = false;
		
		
		protected static const PEOPLE_DELAY_CONSTANT:Number = 0.025;

		

		public function animateToGraphState(value:int, leftSideIsWhite:Boolean, isTextOnRightEdge:Boolean):void {
			// move the dots and change their color until we have the correct number of colored dots on each side
			
			var i:int;
			var person:PeopleGraphPerson;
			

			// figure out how many in each row are currently on each side (or neutral)
			var rowCountsLeft:Array = [];
			var rowCountsRight:Array = [];	
			
			var targetRowCountsLeft:Array = [];
			var targetRowCountsRight:Array = [];
		
			// init working arrays
			for (var j:int = 0; j < 10; j++) {
				targetRowCountsLeft[j] = 0;
				targetRowCountsRight[j] = 0;
				rowCountsLeft[j] = 0;
				rowCountsRight[j] = 0;
			}
			
			
			if (isInNeutralState == false) {
				// this stuff is only necessary if we're figuring out how to move from graph-to-graph, not from a neutral position
				for each (person in people) {					
					if (person.state == PeopleGraphPerson.STATE_LEFT) {
						rowCountsLeft[person.rowIndex]++;
					} else if (person.state == PeopleGraphPerson.STATE_RIGHT) {
						rowCountsRight[person.rowIndex]++;
					}
				}
			
			}
			
			
			
			
			// determine how many in each row SHOULD NEXT be on each side
			var numTargetPeopleOnLeft:int;
			var numTargetPeopleOnRight:int;
			
			// the 'value' parameter is how many white dots there should be
			// so we need to assign that either to the right or left, depending on which is white
			if (leftSideIsWhite) {
				numTargetPeopleOnLeft = value;
				numTargetPeopleOnRight = 100 - value;			
			} else {
				numTargetPeopleOnRight = value;
				numTargetPeopleOnLeft = 100 - value;				
			}
				
			
			
			for (i = 0; i < numTargetPeopleOnRight; i++) {				
				// on the the right, they fill up from the top
				targetRowCountsRight[i % 10]++;
			}
			
			// we can infer the other side because there always ten people per row
			for (i = 0; i < 10; i++) {
				targetRowCountsLeft[i] = 10 - targetRowCountsRight[i];                                                                                
			}
			
			
			// new: if the white is on the right side, we vertically swap all of the target arrays so that the left gap moves
			if (leftSideIsWhite == false) {
				targetRowCountsLeft = targetRowCountsLeft.reverse();
				targetRowCountsRight = targetRowCountsRight.reverse();
			}
			
			
			var rndm:Rndm = new Rndm();
			
			
			
			
			// now nominate which people will move across
			for (var row:int = 0; row < 10; row++) {
				
				var rowDelay:Number = rndm.integer(0, 50) * 0.001;
				
				
				for (i = 0; i < 10; i++) { 
					var finalX:Number;
					
					person = people[(row * 10) + i];
					
					var delay:Number = rowDelay + rndm.integer(0, 25) * 0.001;
					
					
					if (i < targetRowCountsLeft[row]) {
					
						// when moving left, the leftmost dots should have the smallest delay
						delay += (i * PEOPLE_DELAY_CONSTANT); 
						
						if (person.state != PeopleGraphPerson.STATE_LEFT) {
							
							person.state = PeopleGraphPerson.STATE_LEFT;
							
							// set animation to move to left side						
							// change color
							
							finalX = LEFTMOST_X_POSITION + (i * PEOPLE_SPACING);
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay, ease:Strong.easeIn });
						
						}
							
						
							
					} else {
						
						// it needs to go to the right
						if ((person.state != PeopleGraphPerson.STATE_RIGHT) || isTextOnRightEdge || previousStateWasOffsetFromRightEdge) {
							
							// when moving left, the rightmost dots should have the smallest delay
							delay += ((10-i) * PEOPLE_DELAY_CONSTANT); 
								
							person.state = PeopleGraphPerson.STATE_RIGHT;
															
							// set animation to move to right side						
							// change color
							
							if (isTextOnRightEdge) {
								finalX = RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT - ((9 - i) * PEOPLE_SPACING);		
							} else {
								finalX = RIGHTMOST_X_POSITION - ((9 - i) * PEOPLE_SPACING);		
							}
							
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay, ease:Strong.easeIn});
						
						}

					}
					
						
					// add color-changing tween
					var tintColor:uint;

					if (leftSideIsWhite) {
						if (person.state == PeopleGraphPerson.STATE_LEFT)		tintColor = 0xFFFFFF;
						else													tintColor = slideData.currentBoxColor;
					
					} else {
						if (person.state == PeopleGraphPerson.STATE_LEFT)		tintColor = slideData.currentBoxColor;
						else													tintColor = 0xFFFFFF;

					}
					
					TweenMax.to(person, PEOPLE_COLOR_CHANGE_TIME_SEC, { delay:delay, colorTransform:{tint:tintColor, tintAmount:1.0}, ease:Strong.easeIn } );
					
					
				}
			}
			
			
			this.previousStateWasOffsetFromRightEdge = isTextOnRightEdge;
		}

		
		
		protected var numExtraRowsAllowed:int = 2;
		protected var numExtraColumnsAllowed:int = 2;
		
		
		protected function flyOnExtraDots(extraDotCount:int, leftSideIsWhite:Boolean, isTextOnRightEdge:Boolean):void {
			var i:int, j:int;
			var point:Point;
			var person:PeopleGraphPerson;
			
			// create array of positions, then iterate through it as far as we need to
			var newPeoplePositions:Vector.<Point> = new Vector.<Point>();
			
			var newTopPositions:Vector.<Point> = new Vector.<Point>();
			var newBottomPositions:Vector.<Point> = new Vector.<Point>();
			var newSidePositions:Vector.<Point> = new Vector.<Point>();
			
			var newStartPositions:Vector.<Point> = new Vector.<Point>();
	
			const START_POSITION_OFFSET:Number = 300;
			
			
			extraPeople = new Vector.<PeopleGraphPerson>();
			
			
			if (Infographic.HEIGHT > 576) {
				// if we're in feature, we have more room
				numExtraRowsAllowed = 3;
			}
		
			/*
			if (Infographic.WIDTH > 1024) {
				numExtraColumnsAllowed = 3;
			}
			*/
			
			var rightMostX:Number = RIGHTMOST_X_POSITION;
			
			
			
			if (leftSideIsWhite) {
			
				
				// two rows at side 
				for (i = 1; i <= numExtraColumnsAllowed; i++) {
					for (j = 0; j < 10; j++) {
						newSidePositions.push(new Point(LEFTMOST_X_POSITION - (PEOPLE_SPACING * i), START_Y_POSITION + (j * PEOPLE_SPACING)));
					}
				}				
				
				// two rows at top, two at bottom
				for (i = 1; i <= numExtraRowsAllowed; i++) {
					for (j = 0; j < 9 + numExtraColumnsAllowed + 1; j++) {
						newTopPositions.push(new Point(LEFTMOST_X_POSITION + (PEOPLE_SPACING * (j - numExtraColumnsAllowed)), START_Y_POSITION - (i * PEOPLE_SPACING)));
						newBottomPositions.push(new Point(LEFTMOST_X_POSITION + (PEOPLE_SPACING * (j - numExtraColumnsAllowed)), START_Y_POSITION + ((9 + i) * PEOPLE_SPACING)));
					}
				}

				
			} else {	
					
				if (isTextOnRightEdge) {
					rightMostX = RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT;		
				} 
				
				// two rows at side
				for (i = 1; i <= numExtraColumnsAllowed; i++) {
					for (j = 0; j < 10; j++) {
						newSidePositions.push(new Point(rightMostX + (PEOPLE_SPACING * i), START_Y_POSITION + (j * PEOPLE_SPACING)));
					}
				}
				
				
				// two rows at top, two at bottom
				for (i = 1; i <= numExtraRowsAllowed; i++) {
					for (j = 0; j < 9 + numExtraColumnsAllowed + 1; j++) {
						newTopPositions.push(new Point(rightMostX - (PEOPLE_SPACING * (j - numExtraColumnsAllowed)), START_Y_POSITION - (i * PEOPLE_SPACING)));
						newBottomPositions.push(new Point(rightMostX - (PEOPLE_SPACING * (j - numExtraColumnsAllowed)), START_Y_POSITION + ((9 + i) * PEOPLE_SPACING)));
					}
				}
				
								
				
				
			}

			
			if (leftSideIsWhite) {
				for each (point in newSidePositions) 	newStartPositions.push(new Point(point.x - START_POSITION_OFFSET, point.y)); 
			} else {
				for each (point in newSidePositions) 	newStartPositions.push(new Point(point.x + START_POSITION_OFFSET, point.y)); 
			}
		
			for each (point in newTopPositions) 		newStartPositions.push(new Point(point.x, point.y - START_POSITION_OFFSET)); 
			for each (point in newBottomPositions) 		newStartPositions.push(new Point(point.x, point.y + START_POSITION_OFFSET)); 
			
			
			
			// put them together in the preferred order
			newPeoplePositions = newSidePositions.concat(newTopPositions).concat(newBottomPositions);
							
			
			for (var k:int = 0; k < Math.min(extraDotCount, newPeoplePositions.length); k++) {
				
				// animate on each dot
				var startPoint:Point = newStartPositions[k];
				var endPoint:Point = newPeoplePositions[k];
				
				// they're always white.. right?
				person = new PeopleGraphPerson(0xFFFFFF);
				
				if (leftSideIsWhite) {
					person.state = PeopleGraphPerson.STATE_LEFT
					person.columnIndex = Math.floor((endPoint.x - LEFTMOST_X_POSITION) / PEOPLE_SPACING);

				} else {
					person.state = PeopleGraphPerson.STATE_RIGHT;
					person.columnIndex = Math.floor(Math.abs(endPoint.x - (rightMostX - (10 * PEOPLE_SPACING))) / PEOPLE_SPACING);
				}
				
				
				
				
				person.drawFull();
				
				extraPeople.push(person);
				addChild(person);
				
				var delay:Number = Rndm.integer(0, 50) * 0.001;
				
				TweenMax.fromTo(person, PEOPLE_TRANSITION_TIME_SEC, { x:startPoint.x, y:startPoint.y }, { x:endPoint.x, y:endPoint.y, delay:delay, ease:Strong.easeIn });
			}
		
			
		}
		
				
		
		
		public static function getTotalMSecDurationFromXML(xml:XML):Number {
			var duration:Number = PeopleGraph.ANIMATE_ON_DURATION_SEC;
			
			for (var i:int = 0; i < xml.graphstate.length(); i++) {
				var graphStateXML:XML = xml.graphstate[i];
				
				var bottomTextString:String = TextUtils.safeText(graphStateXML.@bottomText);
				var topTextString:String = TextUtils.safeText(graphStateXML.@topText);
				var featuredTextString:String = TextUtils.safeText(graphStateXML.@featuredText);

				var textLength:int = topTextString.length + bottomTextString.length + featuredTextString.length;
				
				duration += getStateDurationFromTextLength(textLength);
			}
			
			return duration * 1000;
		}
		
		
		public static function getStateDurationFromTextLength(length:int):Number {
			var duration:Number = GRAPH_STATE_DURATION_MIN_SEC;	
			duration += (length * DISPLAY_TIME_EXTRA_PER_CHARACTER);
			return duration;			
		}
		

		protected static const DISPLAY_TIME_EXTRA_PER_CHARACTER:Number = 0.032;
		
		
		public function get currentStateDisplayDurationSeconds():Number {
			// new: now we try to dynamically adjust the length of time the state is shown for
			return getStateDurationFromTextLength(textLength);
		}
				
		
	}

}