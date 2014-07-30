package med.infographic {
	import com.garin.ColorMatrix;
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
		
		
		
		public function PeopleGraph() {
			var i:int;
			
			// todo: move this somewhere better (it's  one-time init)
			TweenPlugin.activate([ColorTransformPlugin]);
			
			
			if (people == null) {
				// create vector for the first time
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
			
		}
		
		
		public function animateOff(callback:Function):void {
//			TweenMax.fromTo(box, ANIMATE_ON_TIME, { scaleX:1, scaleY:1 }, { scaleX:0, scaleY:0, immediateRender:true, onComplete:callback, onCompleteParams:[this] } );	
			callback(this);
		}
		
		
		
		public function animateToGraphState(numTargetPeopleOnLeft:int, leftSideIsWhite:Boolean):void {
			// move the dots and change their color until we have the correct number of colored dots on each side
			
			var i:int;
			var person:PeopleGraphPerson;
			
			// figure out how many in each row are currently on each side (or neutral)
			var rowCountsLeft:Array = [];
			var rowCountsRight:Array = [];	
			
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
			
			var targetRowCountsLeft:Array = [];
			var targetRowCountsRight:Array = [];
		
			for (i = 0; i < numTargetPeopleOnRight; i++) {				
				// on the the right, they fill up from the top
				targetRowCountsRight[i % 10]++;
			}
			
			// we can infer the other side because there always ten people per row
			for (i = 0; i < 10; i++) {
				targetRowCountsLeft[i] = 10 - targetRowCountsLeft[i];                                                                                
			}
			
			
			var rndm:Rndm = new Rndm(50);
			
			
			// now nominate which people will move across
			for (var row:int = 0; row < 10; row++) {
				
				for (i = 0; i < 10; i++) { 
					var finalX:Number;
					var tintColor:uint;
					
					person = people[(row * 10) + i];
					
					var delay:Number = rndm.integer(0, 500) * 0.001;
					
					
					if (i < targetRowCountsLeft[row]) {
						
						if (person.state != PeopleGraphPerson.STATE_LEFT) {
							
							person.state = PeopleGraphPerson.STATE_LEFT;
							
							// set animation to move to left side						
							// change color
							
							finalX = LEFTMOST_X_POSITION + (i * PEOPLE_SPACING);
							
							tintColor = 0xFFFFFF;
							
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay, colorTransform:{tint:tintColor, tintAmount:1.0} } );
						
						}
							
							
					} else {
						
						// it needs to go to the right
						if (person.state != PeopleGraphPerson.STATE_RIGHT) {
							
							person.state = PeopleGraphPerson.STATE_RIGHT;
															
							// set animation to move to right side						
							// change color
							
							finalX = RIGHTMOST_X_POSITION - (i * PEOPLE_SPACING);
							
							tintColor = 0xFF9330;
							
							TweenMax.to(person, PEOPLE_TRANSITION_TIME_SEC, { x:finalX, delay:delay, colorTransform:{tintColor:tintColor, tintAmount:1.0} } );
						
						}

					}
				}
			}
			
			
		}

		
		
	}

}