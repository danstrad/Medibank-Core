package med.infographic {
	import com.garin.ColorMatrix;
	import com.garin.Text;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	
	
	public class PeopleGraph extends _PeopleGraph implements ISlide {

		// using a static array for this for performance / memory reasons
		protected static var people:Vector.<PeopleGraphPerson>;
				
		protected static const PEOPLE_SPACING:Number = 43;
		
		protected static const LEFTMOST_X_POSITION:Number = -415;
		protected static const RIGHTMOST_X_POSITION:Number = 415;
		
		protected static const PEOPLE_TRANSITION_TIME_SEC:Number = 1.0; 
		
		
		public var isInNeutralState:Boolean;
		
		
		public var slideData:InfographicSlideData;
		
		
		protected var graphStateIndex:int = 0;
		
		protected var graphStatesXML:Vector.<XML> = new Vector.<XML>();
		
		
		
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
					addChild(person);
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
				
				people[i].visible = false;
			}
			
			isInNeutralState = true;
			
			// hide text
			textPanel.visible = false;
		}

		
		public function animateOn():void {
			// have the circles gradually appear in the neutral position
			
			// we want to stagger their appearance
			var rndm:Rndm = new Rndm(50);
			
			for each (var person:PeopleGraphPerson in people) {
				var animationDelayMsec:Number = Number(rndm.integer(0, 1000));
				person.animateOnPerson(animationDelayMsec);
			}
						
			// wait until this finishes, then advance to the next (first) graph state
			waitThenAdvance(2.0);
		}
		
		
		protected function waitThenAdvance(delaySeconds:Number):void {
			TweenMax.to(this, delaySeconds, { onComplete:nextGraphState } );
		}
		
		
		public function animateOff(callback:Function):void {
			

//			TweenMax.fromTo(box, ANIMATE_ON_TIME, { scaleX:1, scaleY:1 }, { scaleX:0, scaleY:0, immediateRender:true, onComplete:callback, onCompleteParams:[this] } );	
//			callback(this);
						
			for each (var person:PeopleGraphPerson in people) {
				
				var targetX:int = -1000;
				
				if (person.state == PeopleGraphPerson.STATE_RIGHT) {
					targetX = 1000;
				}
				
				TweenMax.to(person, 0.5, { x:targetX, delay:(Rndm.integer(0, 25) * 0.01) } );
			}
		
			// todo: don't just fade this out. it's slow right now to give us something to hang the callback on
			TweenMax.to(textPanel, 0.75, { alpha:0, onComplete:callback, onCompleteParams:[this] });
			
		}
		

		
		
		
		public function nextGraphState():void {
			
			graphStateIndex++;
			
			
			if (graphStateIndex >= graphStatesXML.length) {
				// there are no more!
				// just do nothing and wait for Infographic to remove us
				return;
			}
			
			
			var graphStateXML:XML = graphStatesXML[graphStateIndex];
			
			//<graphstate value="33" featuredText="1 in 3" usePercentage="false" topText="" bottomText="Consultations for patients up to the age of 15 are for dermatology." />

			var value:int = int(graphStateXML.@value);
			
			
			
			// animate people
			animateToGraphState(value, ((graphStateIndex % 2) == 0));
			
			
			// set up text	
			textPanel.visible = true;
			
			// the textpanel is (usually) aligned 30 pixels to the right of the rightmost left person
//			textPanel.x = LEFTMOST_X_POSITION + (Math.floor(value / 10) * PEOPLE_SPACING) + 30;
			
			var bottomTextString:String = graphStateXML.@bottomText;
			var topTextString:String = graphStateXML.@topText;
			
			var featuredTextString:String = graphStateXML.@featuredText;
			var usePercentage:Boolean = (graphStateXML.@usePercentage == "true");

			
			if (topTextString.length) {
				textPanel.topField.text = topTextString;
				textPanel.topField.visible = true;
				Text.boldText(textPanel.topField);
				Text.setTextSpacing(textPanel.topField, -0.6);
			} else {
				textPanel.topField.visible = false;
			}			
			
			
			if (usePercentage) {
				textPanel.percentageField.text = featuredTextString;
				Text.boldText(textPanel.percentageField);
				Text.setTextSpacing(textPanel.percentageField, -7);				
				textPanel.percentageField.visible = true;
				textPanel.percentageSignField.visible = true;
				
				textPanel.featuredField.visible = false;
				
			} else {
				textPanel.featuredField.text = featuredTextString;
				Text.boldText(textPanel.featuredField);
				Text.setTextSpacing(textPanel.featuredField, -2);
				textPanel.featuredField.visible = true;
				
				textPanel.percentageField.visible = false;
				textPanel.percentageSignField.visible = false;
			}
			
			
			if (bottomTextString.length) {
				textPanel.bottomField.text = bottomTextString;
				textPanel.bottomField.visible = true;
				Text.boldText(textPanel.bottomField);
				Text.setTextSpacing(textPanel.bottomField, -0.6);
			} else {
				textPanel.bottomField.visible = false;
			}
			
			
			waitThenAdvance(5.0);
			
		}
		
		
		
		public function animateToGraphState(numTargetPeopleOnLeft:int, leftSideIsWhite:Boolean):void {
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
						if (person.state != PeopleGraphPerson.STATE_RIGHT) {
							
							person.state = PeopleGraphPerson.STATE_RIGHT;
															
							// set animation to move to right side						
							// change color
							
							finalX = RIGHTMOST_X_POSITION - ((10-i) * PEOPLE_SPACING);					
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