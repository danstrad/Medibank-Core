package med.infographic {
	import com.garin.ArrayFunctions;
	import com.garin.Drawing;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	import com.gskinner.utils.Rndm;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	
	
	public class FloatingBoxesSlide extends _FloatingBoxesSlide implements ISlide {

		
		protected var slideData:InfographicSlideData;
		
		protected var boxes:Vector.<FloatingBox>;
				
		protected var showingBoxIndex:int;
		
		
		protected static const BOX_ANIMATE_ON_DURATION_SECONDS:Number = 2.0;	

		protected static const ANIMATE_ON_DURATION_SECONDS:Number = 3.0;
		protected static const ANIMATE_OFF_DURATION_SECONDS:Number = 3.0;
				
		public static const BOX_DISPLAY_TIME_SECONDS:Number = 4.0;
		
		
		protected var hasFeatureText:Boolean;
		
		
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
			
			hasFeatureText = (featuredString != "");
			
			featuredText.text = featuredString;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, 0.4);

			boxes = new Vector.<FloatingBox>();
			
			
			// work out bounds for boxes
			// we need to bear in mind their size once expanded		
			const EDGE_BUFFER:Number = 10;
			
			var topBorder:Number = -288 + EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5);
			var boundsHeight:Number = 576 - ((EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5)) * 2);
			var boundsWidth:Number = (512 + 140) - EDGE_BUFFER - (FloatingBox.BOX_SIZE * 0.5);
				
			var leftBoxBounds:Rectangle = new Rectangle(-140, topBorder, boundsWidth / 2, boundsHeight);
			var rightBoxBounds:Rectangle = new Rectangle(leftBoxBounds.left + (boundsWidth * 0.5), topBorder, boundsWidth / 2, boundsHeight);			
			
			if (hasFeatureText == false) {
				// with no featured string, we increase the bounds. our usable area is larger when we don't have to worry about overlapping the text
				boundsWidth = 512 - EDGE_BUFFER - (FloatingBox.BOX_SIZE * 0.5);
				
				leftBoxBounds = new Rectangle(-512 + EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5), topBorder, boundsWidth, boundsHeight);
				rightBoxBounds = new Rectangle(0, topBorder, boundsWidth, boundsHeight);			
			}
			
			
			// draw for debug
			/*
			this.graphics.lineStyle(1, 0x000000, 0.7);
			Drawing.drawRectangle(this.graphics, leftBoxBounds);
			Drawing.drawRectangle(this.graphics, rightBoxBounds);
			*/
			
			// new: align to invisible grid
			var gridLineCount:int = 3;
			var gridSize:Number = Math.floor(boundsWidth / (gridLineCount + 2));
	
			var gridPositionsOnLeft:Array = [];
			var gridPositionsOnRight:Array = [];
			
						
			for (var j:int = 0; j < gridLineCount * gridLineCount; j++ ) {
				gridPositionsOnLeft.push(j);
				gridPositionsOnRight.push(j);	
			}

			
			gridPositionsOnLeft = ArrayFunctions.shuffle(gridPositionsOnLeft);
			gridPositionsOnRight = ArrayFunctions.shuffle(gridPositionsOnRight);
					
			
			

			
			
			for (var i:int = 0; i < slideData.xml.box.length(); i++) {
				var boxXML:XML = slideData.xml.box[i];
				
				var showNumber:Boolean = boxXML.hasOwnProperty("@value");
				
				var box:FloatingBox = new FloatingBox(int(boxXML.@value), showNumber, boxXML.@text, boxXML.@topText, slideData.boxColor, slideData.textColor, (boxXML.@largeBox == "true"));
				boxes.push(box);
				
				
				// figure out box positions								
				// mostly we want them to alternate l->r->l			
				
				
				
				var gridPosition:int;
				
				
				if ((i % 2) == 0) {
					// even -> right
					
					gridPosition = gridPositionsOnRight.pop();
					
					box.x = rightBoxBounds.x + (gridSize * 0.5) + ((gridPosition % gridLineCount) * gridSize) + Rndm.integer((gridSize * -0.2), (gridSize * 0.2));
					box.y = rightBoxBounds.y + (gridSize * 0.5) + (Math.floor(gridPosition / gridLineCount) * gridSize) + Rndm.integer((gridSize * -0.2), (gridSize * 0.2));
					
//					box.x = rightBoxBounds.x + Rndm.integer(0, rightBoxBounds.width);
//					box.y = rightBoxBounds.y + Rndm.integer(0, rightBoxBounds.height);

				} else {
					// odd -> left
					gridPosition = gridPositionsOnLeft.pop();

					box.x = leftBoxBounds.x + (gridSize * 0.5) + ((gridPosition % gridLineCount) * gridSize) + Rndm.integer((gridSize * -0.2), (gridSize * 0.2));
					box.y = leftBoxBounds.y + (gridSize * 0.5) + (Math.floor(gridPosition / gridLineCount) * gridSize) + Rndm.integer((gridSize * -0.2), (gridSize * 0.2));
					
//					box.x = leftBoxBounds.x + Rndm.integer(0, leftBoxBounds.width);
//					box.y = leftBoxBounds.y + Rndm.integer(0, leftBoxBounds.height);				
									
				}
				
				addChild(box);
				
			}
							
			// find dummy boxes
			findDummyBoxes();
			
			
			showingBoxIndex = -1;
		}

		
		protected var dummyBoxes:Vector.<DisplayObject>;
		
		
		protected function findDummyBoxes():void {
		
			dummyBoxes = new Vector.<DisplayObject>();
			
			for (var i:int = 0; i < this.numChildren; i++) {
				var childObject:DisplayObject = getChildAt(i);
				if (childObject is _DummyFloatingBox) {
					dummyBoxes.push(childObject);
				}
			}
		}
		
		
		
		protected function showNextBox():void {
			
			if ((showingBoxIndex + 1) >= boxes.length) {
				// don't have another one to show
				return;
			}
			
			bringBoxToFront(showingBoxIndex + 1);
			
			// timer
			TweenMax.to(this, BOX_DISPLAY_TIME_SECONDS + 0.4, { onComplete:showNextBox } );
		}
		

		
		protected function bringBoxToFront(boxIndex:int):void {
			this.showingBoxIndex = boxIndex;
					
			// boxes send themselves back now
			var box:FloatingBox = boxes[boxIndex];			
			box.bringForward();
			addChild(box);
			
		}
		
		

		public function animateOn():void {
			var delay:Number;
			
			for each (var box:FloatingBox in boxes) {
				delay = (Rndm.integer(0, 500) * 0.001);
				if (hasFeatureText) delay += 0.5;
				
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:-1000 }, { x:box.x, immediateRender:true, delay:delay, ease:Strong.easeIn } );
			}
					
			
			var blurFilter:BlurFilter = new BlurFilter(FloatingBox.BACK_BOX_BLUR, FloatingBox.BACK_BOX_BLUR, FloatingBox.BLUR_QUALITY);	
				
			
			for each (var dummyBox:DisplayObject in dummyBoxes) {
				delay = (Rndm.integer(0, 500) * 0.001);
				if (hasFeatureText) delay += 0.5;

				dummyBox.filters = [blurFilter];
				
				TweenMax.fromTo(dummyBox, BOX_ANIMATE_ON_DURATION_SECONDS, { x:-1000 }, { x:dummyBox.x, immediateRender:true, delay:delay, ease:Strong.easeIn, onComplete:initDummyBox, onCompleteParams:[dummyBox] } );
			}
			
			
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x: -800 }, { x: featuredText.x, immediateRender:true, ease:Strong.easeOut } );
			
			TweenMax.to(this, ANIMATE_ON_DURATION_SECONDS + 0.3, { onComplete:showNextBox } );
		}
		
		
		
		protected function initDummyBox(dummyBox:DisplayObject):void {
			var targetAlpha:Number = Math.max(0.1, dummyBox.alpha - (Rndm.integer(0, 15) * 0.01));
			var delay:Number = Rndm.integer(0, 100) * 0.001;
			var duration:Number = 1.0 + (Rndm.integer(0, 500) * 0.001);			
			TweenMax.to(dummyBox, duration, { alpha: targetAlpha, repeat: -1, yoyo:true, delay:0 } );
		}
		
		
		
		public function animateOff(callback:Function):void {		
			var delay:Number;
		
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x:featuredText.x }, { x:-800, immediateRender:true, ease:Strong.easeIn } );
			
			for each (var box:FloatingBox in boxes) {
				delay = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:box.x }, { x:1000, immediateRender:true, delay:delay, ease:Strong.easeOut } );
			}
			
			for each (var dummyBox:DisplayObject in dummyBoxes) {
				delay = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(dummyBox, BOX_ANIMATE_ON_DURATION_SECONDS, { x:dummyBox.x }, { x:1000, immediateRender:true, delay:delay, ease:Strong.easeOut } );
			
			}
				
			// tween for timer
			TweenMax.to(this, ANIMATE_OFF_DURATION_SECONDS, { onComplete:callback, onCompleteParams:[this] } );
			
		}
	
		
		
		public function animate(dTime:Number):void {
					
			for each (var box:FloatingBox in boxes) {
				box.animate(dTime);
			}
			
		}
		
	}

}