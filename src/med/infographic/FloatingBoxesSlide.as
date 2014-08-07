package med.infographic {
	import com.garin.Drawing;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	import com.gskinner.utils.Rndm;
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
			
			featuredText.text = featuredString;
			Text.boldText(featuredText);
			Text.setTextSpacing(featuredText, 0.4);

			boxes = new Vector.<FloatingBox>();
			
			
			// work out bounds for boxes
			// we need to bear in mind their size once expanded			
			var topBorder:Number = -288 + 10 + (FloatingBox.BOX_SIZE * 0.5);
			var boundsHeight:Number = 576 - ((10 + (FloatingBox.BOX_SIZE * 0.5)) * 2);
			var boundsWidth:Number = (512 + 150) - 10 - (FloatingBox.BOX_SIZE * 0.5);
				
			var leftBoxBounds:Rectangle = new Rectangle(-150, topBorder, boundsWidth / 2, boundsHeight);
			var rightBoxBounds:Rectangle = new Rectangle(leftBoxBounds.left + (boundsWidth * 0.5), topBorder, boundsWidth / 2, boundsHeight);			
			
			// draw for debug
			/*
			this.graphics.lineStyle(1, 0x000000, 0.7);
			Drawing.drawRectangle(this.graphics, leftBoxBounds);
			Drawing.drawRectangle(this.graphics, rightBoxBounds);
			*/
			
			for (var i:int = 0; i < slideData.xml.box.length(); i++) {
				var boxXML:XML = slideData.xml.box[i];
				
				var showNumber:Boolean = boxXML.hasOwnProperty("@value");
				
				var box:FloatingBox = new FloatingBox(int(boxXML.@value), showNumber, boxXML.@text, boxXML.@topText, slideData.boxColor, slideData.textColor);
				boxes.push(box);
				
				
				// figure out box positions								
				// mostly we want them to alternate l->r->l			
				
				if ((i % 2) == 0) {
					// even -> right
					box.x = rightBoxBounds.x + Rndm.integer(0, rightBoxBounds.width);
					box.y = rightBoxBounds.y + Rndm.integer(0, rightBoxBounds.height);

				} else {
					// odd -> left			
					box.x = leftBoxBounds.x + Rndm.integer(0, leftBoxBounds.width);
					box.y = leftBoxBounds.y + Rndm.integer(0, leftBoxBounds.height);				
									
				}
				
				addChild(box);
				
			}
									
			showingBoxIndex = -1;
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
						
			for each (var box:FloatingBox in boxes) {
				var delay:Number = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:-1000 }, { x:box.x, immediateRender:true, delay:delay, ease:Strong.easeIn } );
			}
						
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x: -800 }, { x: featuredText.x, immediateRender:true, ease:Strong.easeOut } );
			
			TweenMax.to(this, ANIMATE_ON_DURATION_SECONDS + 0.3, { onComplete:showNextBox } );
		}
		
		
		
		public function animateOff(callback:Function):void {		
		
			// feature text
			TweenMax.fromTo(featuredText, 1.0, { x:featuredText.x }, { x:-800, immediateRender:true, ease:Strong.easeIn } );
			
			for each (var box:FloatingBox in boxes) {
				var delay:Number = 0.5 + (Rndm.integer(0, 500) * 0.001);
				TweenMax.fromTo(box, BOX_ANIMATE_ON_DURATION_SECONDS, { x:box.x }, { x:1000, immediateRender:true, delay:delay, ease:Strong.easeOut } );
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