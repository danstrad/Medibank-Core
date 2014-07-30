package med.infographic {
	import com.garin.Text;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import med.display.Background;
	import flash.text.TextFieldAutoSize;


	public class Infographic extends Sprite {
		
		protected static const BACKGROUND_COLOR_TRANSITION_TIME:Number = 500;
		
		
		public var data:InfographicData;		
		protected var background:Background;
		
		public var currentSlideIndex:int = 0;
		
		protected var initialBackgroundColor:uint;
		
		
		public function Infographic(data:InfographicData, background:Background) {
			this.data = data;
			this.background = background;

			// we store this so we can return to it when we're done with the infographic
			initialBackgroundColor = background.getColor();
			
			slideSprites = [];
			
			this.mouseChildren = false;
			
			// load first slide		
			initSlide(0);
			
		}
		
		protected function end():void {
			// End of sequence reached. Handling passed off to subclass
		}
		
		
		
		public static const CENTER_BOX_WIDTH:Number = 464.1;
		public static const CENTER_BOX_HEIGHT:Number = 443;
		
		
		protected var slideSprites:Array;
		
		
		protected function removePreviousSlides():void {
			for each (var oldSlideSprite:Sprite in slideSprites) {
				
				// todo: different slide types will have different removal animations
				TweenMax.to(oldSlideSprite, 0.5, { alpha:0, scaleX:0, scaleY:0, onComplete:removeSlideSpriteFromStage, onCompleteParams:[oldSlideSprite]});
				
				slideSprites.splice(slideSprites.indexOf(oldSlideSprite), 1);
			}
						
		}
		
		
		protected function initSlide(slideIndex:int):void {
		
			// make sure any previous slides are being removed
			removePreviousSlides();
			
			
			if ((slideIndex >= 0) && (slideIndex < data.slides.length) && (data.slides[slideIndex] != null)) {
				
				this.currentSlideIndex = slideIndex;
				
				var slideData:InfographicSlideData = data.slides[slideIndex];
				
				var box:Sprite;
				
				
				// this is a placeholder approach
				switch (slideData.type) {
					
					case InfographicSlideData.PEOPLE_GRAPH:	
						
						// for debug
						background.showColor(0xFF0000);
						
						var graph:PeopleGraph = new PeopleGraph();
						addChild(graph);
						
						graph.animateOn();
						
						break;
	
						
					
					case InfographicSlideData.CENTER_TEXT_BOX:
						
						box = new InfographicCenterBox();
						
						box.graphics.clear();
						box.graphics.beginFill(slideData.boxColor);
						box.graphics.drawRect(-CENTER_BOX_WIDTH * 0.5, -CENTER_BOX_HEIGHT * 0.5, CENTER_BOX_WIDTH, CENTER_BOX_HEIGHT);
						box.graphics.endFill();
						
						// set text
						InfographicCenterBox(box).textField.htmlText = "<font color='#" + slideData.textColor.toString(16) + "'>" + slideData.featuredText + "</font>";
						
						InfographicCenterBox(box).textField.autoSize = TextFieldAutoSize.CENTER;						
						InfographicCenterBox(box).textField.y = 0 - (InfographicCenterBox(box).textField.height * 0.5);
						
						addChild(box);
						slideSprites.push(box);
						
						TweenMax.fromTo(box, 0.5, { alpha:0, scaleX:0, scaleY:0 }, { alpha:1, scaleX:1, scaleY:1, immediateRender:true } );
						
						
						if (slideData.backgroundColor != background.getColor()) {
							background.fadeToColor(slideData.backgroundColor, BACKGROUND_COLOR_TRANSITION_TIME);
						}
						
						break;
					
						
					default:
						end();
						break;
				}
				
				
			} else {
				// invalid slide index
				trace("attempted to load an invalid slide index. exiting early");
				end();
			}
		}
		

		
		protected function removeSlideSpriteFromStage(sprite:Sprite):void {
			if (sprite)  removeChild(sprite);
		}
		


		public function animate(dTime:Number):void {
			
		}
		
		
		
		protected function handleMouseDown(event:MouseEvent):void {

			if (currentSlideIndex < (data.slides.length-1)) {
				initSlide(currentSlideIndex + 1);
			} else {
				removePreviousSlides();
				end();
			}
			
		}
		
		
		

	}

}