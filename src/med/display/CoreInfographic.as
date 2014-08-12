package med.display {
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Background;
	import med.infographic.*;
	import med.story.Chapter;

	
	public class CoreInfographic extends Infographic {

		protected static const SCROLL_OFF_TIME:Number = 1400;
		protected static const SCROLL_ON_TIME:Number = 1400;
		protected static const SCROLL_DISTANCE:Number = 6000;

		protected var backgroundImageLayer:Sprite;
		protected var mover:Sprite;

		protected var moverOrigin:Point;
		protected var mainScrollingOff:Boolean;
		protected var mainScrollOffTime:Number;
		protected var mainScrollingOn:Boolean;
		protected var mainScrollOnTime:Number;
		
		protected var backgroundHitArea:Shape;
		
		public var finished:Boolean;
		protected var ending:Boolean;
		public var ended:Boolean;
		
		public var endedEarly:Boolean = false;
		
		
		public function CoreInfographic(data:InfographicData, mover:Sprite, launchRect:Rectangle, backgroundImageLayer:Sprite, background:Background, chapter:Chapter) {			
			this.mover = mover;
			this.backgroundImageLayer = backgroundImageLayer;
			
			
			// get the infographicColors from the relevant Chapter, then pass them to our superclass
			var infographicColors:Vector.<uint>;
			if (chapter) infographicColors = chapter.getInfographicColors();
			else infographicColors = Infographic.DEFAULT_COLORS;
			
			super(data, background, infographicColors, launchRect);
		
			
			moverOrigin = new Point(mover.x, mover.y);
						
			mainScrollingOff = true;
			mainScrollOffTime = 0;
			
			// we need to add an invisible hitlayer to the background, so we can intercept touch events properly
			backgroundHitArea = new Shape();
			backgroundHitArea.graphics.beginFill(0xFFFFFF, 0);
			backgroundHitArea.graphics.drawRect(Infographic.WIDTH * -0.5, Infographic.HEIGHT * -0.5, Infographic.WIDTH, Infographic.HEIGHT);
			backgroundHitArea.graphics.endFill();
			backgroundHitArea.cacheAsBitmap = true;
			addChildAt(backgroundHitArea, 0);
			
		}
		
		
		override protected function lastFrameReached():void {
			super.lastFrameReached();
			
			mainScrollingOff = false;
			mainScrollingOn = true;
			mainScrollOnTime = 0;

			mover.visible = true;
			backgroundImageLayer.visible = true;
			
			if (initialBackgroundColor != background.getColor()) {
				background.fadeToColor(initialBackgroundColor, 1.0);
			}
			
			//finished = true;
			disable();
		}

		public function enable():void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		protected function disable():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		override public function animate(dTime:Number):void {
			var f:Number, eased:Number;
			
			if (mainScrollingOff) {
				mainScrollOffTime = Math.min(mainScrollOffTime + dTime, SCROLL_OFF_TIME);
				f = mainScrollOffTime / SCROLL_OFF_TIME;
				eased = Utils.easeIn(f);
				mover.x = moverOrigin.x - eased * SCROLL_DISTANCE;
				backgroundImageLayer.alpha = 1 - eased;
				if (f >= 1) {
					mainScrollingOff = false;
					mover.visible = false;
					backgroundImageLayer.visible = false;
				}
				
			} else if (mainScrollingOn) {
				/*
				mainScrollOnTime = Math.min(mainScrollOnTime + dTime, SCROLL_ON_TIME);
				f = mainScrollOnTime / SCROLL_ON_TIME;
				eased = Utils.easeIn(f);
				mover.x = moverOrigin.x + (1 - eased) * SCROLL_DISTANCE;
				backgroundImageLayer.alpha = eased;
				
				if (f >= 1) {
				*/
					mainScrollingOn = false;
					finished = true;
				//}
			} else {
				
			}
			
			super.animate(dTime);
		}
		
		public function animateOff():void {
			ending = true;
			animateLastSlideOff(lastSlideEnded);
		}
		
		protected function lastSlideEnded(infographic:Infographic):void {
			ended = true;
		}
		
		
		override protected function addSlideSprite(sprite:Sprite):void {
			super.addSlideSprite(sprite);
			
			// we don't need touch interaction with slides in core.
			// this is disabled so we can use the pause menu instead
			sprite.mouseEnabled = false;
		}
		
		
		
		
		override protected function handleMouseDown(event:MouseEvent):void {

			// add a pause overlay
			var pauseOverlay:PauseOverlay = new PauseOverlay(returnFromPauseOverlay, exitInfographic, pauseAll);
			
			addChild(pauseOverlay);
			
			// disable ourself so we don't continue to spawn pause overlays
			disable();
						
		}		
		
		
		protected function pauseAll():void {
			this.paused = true;
			pauseMedia();
			TweenMax.pauseAll();			
		}
		
		
		protected function resumeAll():void {
			this.paused = false;
			resumeMedia();
			TweenMax.resumeAll();			
		}
		
		
		protected function returnFromPauseOverlay():void {		
			// resume
			resumeAll();	
			
			// back to normal
			enable();
		}
		
		
		protected function exitInfographic():void {
//			animateOff();

			this.endedEarly = true;
//			forceLoadLastSlide();			
			lastFrameReached();
		}
		
		
	}

}