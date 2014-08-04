package med.infographic {
	import com.garin.ColorMatrix;
	import com.garin.Text;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class PeopleGraph extends _PeopleGraph implements ISlide {

		// using a static array for this for performance / memory reasons
		protected static var people:Vector.<PeopleGraphPerson>;
				
		protected static const PEOPLE_SPACING:Number = 43;
		
		protected static const LEFTMOST_X_POSITION:Number = -415;
		protected static const RIGHTMOST_X_POSITION:Number = 415;
		protected static const RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT:Number = 205;
		
		protected static const BOTTOM_TEXT_LOWER_BOUND:Number = 490;
		
		protected static const PEOPLE_TRANSITION_TIME_SEC:Number = 1.0; 
		
		
		protected static const MIN_TEXT_ANIMATE_ON_DELAY:Number = 1.4;
		
		protected static const TEXT_SLIDE_DURATION_SEC:Number = 0.3;
		
		protected static const TEXT_ANIMATE_OFFSET_LEFT:Number = -300;
		protected static const TEXT_ANIMATE_OFFSET_RIGHT:Number = 300;
		
		public static const GRAPH_STATE_DURATION_SEC:Number = 5.0;		
		public static const ANIMATE_ON_DURATION_SEC:Number = 1.5;
		public static const ANIMATE_OFF_DURATION_SEC:Number = 1.5;
		
		
		
		
		public var isInNeutralState:Boolean;
		
		
		public var slideData:InfographicSlideData;
		
		
		protected var graphStateIndex:int = 0;
		
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
		
		
		protected var textPanelMask:Shape;
		
		
		
		public function PeopleGraph(slideData:InfographicSlideData) {
			var i:int;
			
						
			for each (var graphStateXML:XML in slideData.xml.graphstate) {
				graphStatesXML.push(graphStateXML);
			}
				
			graphStateIndex = -1;
			
			
			if (people == null) {
				// create vector for graphical representation of people for the first time
				people = new Vector.<PeopleGraphPerson>();
				
				for (i = 0; i < 100; i++) {
					var person:PeopleGraphPerson = new PeopleGraphPerson();
					people.push(person);	 
				}
			}
			
			// reset the graph to the "start" position
			var startX:int = -192;
			var startY:int = -189;
			
			for (i = 0; i < 100; i++) {
				var xIndex:int = i % 10;
				var yIndex:int = Math.floor(i / 10);

				people[i].rowIndex = yIndex;
				
				people[i].x = startX + (xIndex * PEOPLE_SPACING);
				people[i].y = startY + (yIndex * PEOPLE_SPACING);
				
				people[i].state = PeopleGraphPerson.STATE_NEUTRAL;
				
				people[i].visible = false;
				people[i].reset();
				
				if (people[i].parent) {
					people[i].parent.removeChild(people[i]);
				}
				
				addChild(people[i]);
			}
			
			isInNeutralState = true;
			
			
			textPanelMask = new Shape();
			
			textPanelMask.graphics.beginFill(0x00FF00, 0.5);
			textPanelMask.graphics.drawRect(-30, 0, 250, 600); 
			textPanelMask.graphics.endFill();
			
			textPanelMask.x = textPanel.x;
			textPanelMask.y = textPanel.y;
			textPanel.mask = textPanelMask;
			addChild(textPanelMask);
			
			// hide text
			textPanel.visible = false;
		}

		
		public function animateOn():void {
			// have the circles gradually appear in the neutral position
			
			// we want to stagger their appearance
			var rndm:Rndm = new Rndm();
			
			for each (var person:PeopleGraphPerson in people) {
				var animationDelayMsec:Number = Number(rndm.integer(0, 500));
				person.animateOnPerson(animationDelayMsec);
			}
						
			// wait until this finishes, then advance to the next (first) graph state
			waitThenAdvance(ANIMATE_ON_DURATION_SEC);
		}
		
		
		protected function waitThenAdvance(delaySeconds:Number):void {
			TweenMax.to(this, delaySeconds, { onComplete:nextGraphState } );
		}
		
		
		public function animateOff(callback:Function):void {
									
			for each (var person:PeopleGraphPerson in people) {
				
				var targetX:int = -800;
				
				if (person.state == PeopleGraphPerson.STATE_RIGHT) {
					targetX = 800;
				}
				
				TweenMax.to(person, 1.25, { x:targetX, delay:(Rndm.integer(0, 25) * 0.01) } );
			}
		
			// wait, then callback
			TweenMax.to(this, ANIMATE_OFF_DURATION_SEC, { onComplete:callback, onCompleteParams:[this] });
			
		}
		

		public function animate(dTime:Number):void { }
		
		
		
		public function nextGraphState():void {
			
			graphStateIndex++;
			
			
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
				return;
			}
			
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];
			
			// Example XML
			//<graphstate value="33" featuredText="1 in 3" usePercentage="false" topText="" bottomText="Consultations for patients up to the age of 15 are for dermatology." />

			var value:int = int(graphStateXML.@value);
			
			var isWhiteOnLeft:Boolean = ((graphStateIndex % 2) == 0);
			
			var isTextOnRightEdge:Boolean = (graphStateXML.@textOnRightEdge == "true");			
			
			
			// animate people
			animateToGraphState(value, isWhiteOnLeft, isTextOnRightEdge);
			
			
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
				textPanel.x = (RIGHTMOST_X_POSITION - (Math.floor((100 - value) / 10) * PEOPLE_SPACING)) - 254;	
				textAnimationStartOffset = TEXT_ANIMATE_OFFSET_RIGHT;
			}
				
			
			textPanelMask.x = textPanel.x;

			// text panels contents and animation
			var bottomTextString:String = graphStateXML.@bottomText;
			var topTextString:String = graphStateXML.@topText;
			
			var featuredTextString:String = graphStateXML.@featuredText;
			var usePercentage:Boolean = (graphStateXML.@usePercentage == "true");

			
			if (topTextString.length) {
				
				textPanel.topField.x = 0;
				textPanel.topField.text = topTextString;
				textPanel.topField.visible = true;
				Text.boldText(textPanel.topField);
				Text.setTextSpacing(textPanel.topField, -0.6);
				
				slideTextOn(textPanel.topField, MIN_TEXT_ANIMATE_ON_DELAY + 0.1, textAnimationStartOffset);
				slideTextOff(textPanel.topField, GRAPH_STATE_DURATION_SEC - TEXT_SLIDE_DURATION_SEC - 0.1, textAnimationStartOffset);				
				
			} else {
				textPanel.topField.visible = false;
			}			
			
			
			if (usePercentage) {
				
				textPanel.percentageField.x = 0;
				textPanel.percentageSignField.x = 118;
				
				textPanel.percentageField.text = featuredTextString;
				Text.boldText(textPanel.percentageField);
				Text.setTextSpacing(textPanel.percentageField, -7);				
				textPanel.percentageField.visible = true;
				textPanel.percentageSignField.visible = true;
				
				textPanel.featuredField.visible = false;
				
				slideTextOn(textPanel.percentageField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.percentageField, GRAPH_STATE_DURATION_SEC - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				

				slideTextOn(textPanel.percentageSignField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.percentageSignField, GRAPH_STATE_DURATION_SEC - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				
				
				
			} else {
				
				textPanel.featuredField.x = -10;
				
				textPanel.featuredField.text = featuredTextString;
				Text.boldText(textPanel.featuredField);
				Text.setTextSpacing(textPanel.featuredField, -2);
				textPanel.featuredField.visible = true;
				
				textPanel.percentageField.visible = false;
				textPanel.percentageSignField.visible = false;
				
				slideTextOn(textPanel.featuredField, MIN_TEXT_ANIMATE_ON_DELAY, textAnimationStartOffset);
				slideTextOff(textPanel.featuredField, GRAPH_STATE_DURATION_SEC - TEXT_SLIDE_DURATION_SEC, textAnimationStartOffset);				

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
				slideTextOff(textPanel.bottomField, GRAPH_STATE_DURATION_SEC - TEXT_SLIDE_DURATION_SEC - 0.1, textAnimationStartOffset);				
				
			} else {
				textPanel.bottomField.visible = false;
			}
			
			
			waitThenAdvance(GRAPH_STATE_DURATION_SEC);
			
		}
		
		
		
		protected static function slideTextOn(textField:TextField, delay:Number, xOffset:Number):void {			
			TweenMax.fromTo(textField, TEXT_SLIDE_DURATION_SEC, { x: xOffset }, { x:textField.x, immediateRender:true, delay:delay } );
		}
		
		
		
		protected static function slideTextOff(textField:TextField, delay:Number, xOffset:Number):void {
			TweenMax.to(textField, TEXT_SLIDE_DURATION_SEC, { x: xOffset, delay:delay, overwrite:5 } );
		}		
		
		
		public function animateToGraphState(numTargetPeopleOnLeft:int, leftSideIsWhite:Boolean, isTextOnRightEdge:Boolean):void {
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
			var numTargetPeopleOnRight:int = 100 - numTargetPeopleOnLeft;
			
			
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
			
			
			var rndm:Rndm = new Rndm(50);
			
			
			// now nominate which people will move across
			for (var row:int = 0; row < 10; row++) {
				
				for (i = 0; i < 10; i++) { 
					var finalX:Number;
					
					person = people[(row * 10) + i];
					
					var delay:Number = rndm.integer(0, 500) * 0.001;
					
					
					if (i < targetRowCountsLeft[row]) {
						
						if (person.state != PeopleGraphPerson.STATE_LEFT) {
							
							person.state = PeopleGraphPerson.STATE_LEFT;
							
							// set animation to move to left side						
							// change color
							
							finalX = LEFTMOST_X_POSITION + (i * PEOPLE_SPACING);
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay });
						
						}
							
						
							
					} else {
						
						// it needs to go to the right
						if ((person.state != PeopleGraphPerson.STATE_RIGHT) || isTextOnRightEdge) {
							
							person.state = PeopleGraphPerson.STATE_RIGHT;
															
							// set animation to move to right side						
							// change color
							
							if (isTextOnRightEdge) {
								finalX = RIGHTMOST_X_POSITION_WHEN_TEXT_ON_RIGHT - ((9 - i) * PEOPLE_SPACING);		
							} else {
								finalX = RIGHTMOST_X_POSITION - ((9 - i) * PEOPLE_SPACING);		
							}
							
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay});
						
						}

					}
					
						
					// add color-changing tween
					var tintColor:uint;

					if (leftSideIsWhite) {
						if (person.state == PeopleGraphPerson.STATE_LEFT)		tintColor = 0xFFFFFF;
						else													tintColor = 0xFF9330;
					
					} else {
						if (person.state == PeopleGraphPerson.STATE_LEFT)		tintColor = 0xFF9330;
						else													tintColor = 0xFFFFFF;

					}
					
					TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { delay:delay, colorTransform:{tint:tintColor, tintAmount:1.0} } );
					
					
				}
			}
			
			
		}

		
		
	}

}