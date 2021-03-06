package med.infographic {
	import com.garin.ArrayFunctions;
	import com.garin.Drawing;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	import com.gskinner.utils.Rndm;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	
	public class FloatingBoxesSlide extends _FloatingBoxesSlide implements ISlide {

		
		protected var slideData:InfographicSlideData;
		
		protected var boxes:Vector.<FloatingBox>;
				
		protected var showingBoxIndex:int;
		
		
		protected static const BOX_ANIMATE_ON_DURATION_SECONDS:Number = 2.0;	

		protected static const ANIMATE_ON_DURATION_SECONDS:Number = 3.0;
		protected static const ANIMATE_OFF_DURATION_SECONDS:Number = 3.0;
				
		
		
		protected var hasFeatureText:Boolean;
		protected var finishedCallback:Function;
		
		
		public function FloatingBoxesSlide(slideData:InfographicSlideData, finishedCallback:Function) {
			this.finishedCallback = finishedCallback;
			this.slideData = slideData;
	
			/*
				<slide type="floating_boxes" duration="10000">
					<appearance textColor="#FFFFFF" backgroundColor="#E4002B" boxColor="#ff9330"/>
					<featuredText>The service is offered across Australia in:</featuredText>	
					<box value="500" text="GP practices" />
					<box value="100" text="Aged care facilities" />
				</slide>
			*/
			
			var featuredString:String = TextUtils.safeText(slideData.xml.featuredText);
			
			hasFeatureText = (featuredString != "");
			
			featuredText.text = featuredString;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, -0.4);

			featuredText.autoSize = TextFieldAutoSize.LEFT;
			featuredText.y = 0 - (featuredText.height * 0.5) 
			
			boxes = new Vector.<FloatingBox>();
			
			
			// work out bounds for boxes
			// we need to bear in mind their size once expanded		
			const EDGE_BUFFER:Number = 10;
			const GAP_BETWEEN_LEFT_AND_RIGHT:Number = 0;
			
			var topBorder:Number = -288 + EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5);
			var boundsHeight:Number = 576 - ((EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5)) * 2);
			
			// this has changed to be the width of EACH bounding box
			var boundsWidth:Number = 512 - 160 - (GAP_BETWEEN_LEFT_AND_RIGHT * 0.5) - EDGE_BUFFER - (FloatingBox.BOX_SIZE * 0.5);
				
			
			var rightBoxBounds:Rectangle = new Rectangle(512 - boundsWidth - EDGE_BUFFER - (FloatingBox.BOX_SIZE * 0.5), topBorder, boundsWidth, boundsHeight);			
			var leftBoxBounds:Rectangle = new Rectangle((rightBoxBounds.left - GAP_BETWEEN_LEFT_AND_RIGHT) - boundsWidth, topBorder, boundsWidth, boundsHeight);

			
			if (hasFeatureText == false) {
				// with no featured string, we increase the bounds. our usable area is larger when we don't have to worry about overlapping the text
				// new: not any more
				/*
				boundsWidth = 512 - EDGE_BUFFER - (FloatingBox.BOX_SIZE * 0.5);
				
				leftBoxBounds = new Rectangle(-512 + EDGE_BUFFER + (FloatingBox.BOX_SIZE * 0.5), topBorder, boundsWidth, boundsHeight);
				rightBoxBounds = new Rectangle(0, topBorder, boundsWidth, boundsHeight);
				*/
			}
			
			
			// draw for debug
			/*
			this.graphics.lineStyle(1, 0x000000, 0.7);
			Drawing.drawRectangle(this.graphics, leftBoxBounds);
			Drawing.drawRectangle(this.graphics, rightBoxBounds);
			*/
			
			// new: align to invisible grid
			var gridLineCount:int = 3;

			var gridSizeX:Number = Math.floor(boundsWidth / gridLineCount);
			var gridSizeY:Number = Math.floor(boundsHeight / gridLineCount);
	
			var gridPositionsOnLeft:Array = [];
			var gridPositionsOnRight:Array = [];
			
						
			for (var j:int = 0; j < gridLineCount * gridLineCount; j++ ) {
				gridPositionsOnLeft.push(j);
				gridPositionsOnRight.push(j);
				
				// draw for debug
				/*
				var rightX:Number = rightBoxBounds.x + (gridSizeX * 0.5) + ((j % gridLineCount) * gridSizeX);
				var rightY:Number = rightBoxBounds.y + (gridSizeY * 0.5) + (Math.floor(j / gridLineCount) * gridSizeY);

				var leftX:Number = leftBoxBounds.x + (gridSizeX * 0.5) + ((j % gridLineCount) * gridSizeX);
				var leftY:Number = leftBoxBounds.y + (gridSizeY * 0.5) + (Math.floor(j / gridLineCount) * gridSizeY);
					
				this.graphics.lineStyle(2, 0x0000FF, 0.7);
				this.graphics.drawEllipse(rightX - (gridSizeX * 0.5 * 0.4), rightY - (gridSizeY * 0.5 * 0.4), gridSizeX * 2 * 0.2, gridSizeY * 2 * 0.2);
				
				this.graphics.lineStyle(2, 0x00FF00, 0.7);
				this.graphics.drawEllipse(leftX - (gridSizeX * 0.5 * 0.4), leftY - (gridSizeY * 0.5 * 0.4), gridSizeX * 2 * 0.2, gridSizeY * 2 * 0.2);
				*/
			}

			
			gridPositionsOnLeft = ArrayFunctions.shuffle(gridPositionsOnLeft);
			gridPositionsOnRight = ArrayFunctions.shuffle(gridPositionsOnRight);
					
			
			
			
			
			for (var i:int = 0; i < slideData.xml.box.length(); i++) {
				var boxXML:XML = slideData.xml.box[i];
				
				var showNumber:Boolean = boxXML.hasOwnProperty("@value");
				
				var box:FloatingBox = new FloatingBox(int(boxXML.@value), showNumber, boxXML.@text, boxXML.@topText, slideData.currentBoxColor, slideData.currentTextColor);
				boxes.push(box);
				
				
				// figure out box positions								
				// mostly we want them to alternate l->r->l			
				var gridPosition:int;
				
				
				if ((i % 2) == 0) {
					// even -> right					
					gridPosition = gridPositionsOnRight.pop();
					
					box.x = rightBoxBounds.x + (gridSizeX * 0.5) + ((gridPosition % gridLineCount) * gridSizeX) + Rndm.integer((gridSizeX * -0.2), (gridSizeX * 0.2));
					box.y = rightBoxBounds.y + (gridSizeY * 0.5) + (Math.floor(gridPosition / gridLineCount) * gridSizeY) + Rndm.integer((gridSizeY * -0.2), (gridSizeY * 0.2));
					
				} else {
					// odd -> left
					gridPosition = gridPositionsOnLeft.pop();
					
					box.x = leftBoxBounds.x + (gridSizeX * 0.5) + ((gridPosition % gridLineCount) * gridSizeX) + Rndm.integer((gridSizeX * -0.2), (gridSizeX * 0.2));
					box.y = leftBoxBounds.y + (gridSizeY * 0.5) + (Math.floor(gridPosition / gridLineCount) * gridSizeY) + Rndm.integer((gridSizeY * -0.2), (gridSizeY * 0.2));
					
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
				// we want to animate off, then call finishedCallback
				// but we want to allow time for the current box to move to the background
				TweenMax.to(this, FloatingBox.BOX_ANIM_TIME_SECONDS, { onComplete:animateOff, onCompleteParams:[finishedCallback] } );
//				animateOff(finishedCallback);
				return;
			}
			
			
			
			var newFrontBox:FloatingBox = bringBoxToFront(showingBoxIndex + 1);
			
			
			// timer
			TweenMax.to(this, newFrontBox.displayDurationSeconds - 0.25, { onComplete:showNextBox } );
		}
		

		
		protected function bringBoxToFront(boxIndex:int):FloatingBox {
			this.showingBoxIndex = boxIndex;
					
			// boxes send themselves back now
			var box:FloatingBox = boxes[boxIndex];			
			box.bringForward();
			addChild(box);
			
			return box;
		}
		
		

		public function animateOn():void {
			var delay:Number;
			
			for each (var box:FloatingBox in boxes) {
				delay = (Rndm.integer(0, 500) * 0.001);
//				if (hasFeatureText) delay += 0.5;
				
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:-600 }, { x:box.x, immediateRender:true, delay:delay, ease:Strong.easeIn, onComplete:box.addBlur } );
			}
					
			
			var blurFilter:BlurFilter = new BlurFilter(FloatingBox.BACK_BOX_BLUR, FloatingBox.BACK_BOX_BLUR, FloatingBox.BLUR_QUALITY);	
				
			
			for each (var dummyBox:DisplayObject in dummyBoxes) {
				delay = (Rndm.integer(0, 500) * 0.001);
//				if (hasFeatureText) delay += 0.5;

//				dummyBox.filters = [blurFilter];
				
				TweenMax.fromTo(dummyBox, BOX_ANIMATE_ON_DURATION_SECONDS, { x:-600 }, { x:dummyBox.x, immediateRender:true, delay:delay, ease:Strong.easeIn, onComplete:initDummyBox, onCompleteParams:[dummyBox] } );
			}
			
			
			// feature text
			TweenMax.fromTo(featuredText, 0.7, { x: -800 }, { x: featuredText.x, immediateRender:true, ease:Strong.easeOut } );
			
			TweenMax.to(this, ANIMATE_ON_DURATION_SECONDS + 0.3, { onComplete:showNextBox } );
		}
		
		
		
		protected function initDummyBox(dummyBox:DisplayObject):void {
			var targetAlpha:Number = Math.max(0.1, dummyBox.alpha - (Rndm.integer(0, 15) * 0.01));
			var delay:Number = Rndm.integer(0, 100) * 0.001;
			var duration:Number = 1.0 + (Rndm.integer(0, 500) * 0.001);			
			TweenMax.to(dummyBox, duration, { alpha: targetAlpha, repeat: -1, yoyo:true, delay:0 } );
			
			TweenMax.to(dummyBox, 0.5, {  blurFilter: { blurX:FloatingBox.BACK_BOX_BLUR, blurY:FloatingBox.BACK_BOX_BLUR, quality:FloatingBox.BLUR_QUALITY }, delay:0.3 } );
//			dummyBox.filters = [blurFilter];
		}
		
		
		
		public function animateOff(callback:Function):void {		
			var delay:Number;
		
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x:featuredText.x }, { x:-800, immediateRender:true, ease:Strong.easeIn } );
			
			for each (var box:FloatingBox in boxes) {
				delay = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:box.x }, { x:700, immediateRender:true, delay:delay, ease:Strong.easeOut } );
				TweenMax.to(box, 0.5, {  blurFilter: { blurX:0, blurY:0, quality:FloatingBox.BLUR_QUALITY } } );
			}
			
			for each (var dummyBox:DisplayObject in dummyBoxes) {
				delay = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(dummyBox, BOX_ANIMATE_ON_DURATION_SECONDS, { x:dummyBox.x }, { x:700, immediateRender:true, delay:delay, ease:Strong.easeOut } );
				TweenMax.to(dummyBox, 0.5, {  blurFilter: { blurX:0, blurY:0, quality:FloatingBox.BLUR_QUALITY } } );
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