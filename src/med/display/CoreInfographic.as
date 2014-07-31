package med.display {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import med.display.Background;
	import med.infographic.Infographic;
	import med.infographic.InfographicData;

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
		
		public var finished:Boolean;
		
		
		public function CoreInfographic(data:InfographicData, mover:Sprite, backgroundImageLayer:Sprite, background:Background) {			
			this.mover = mover;
			this.backgroundImageLayer = backgroundImageLayer;
			super(data, background);
		
			moverOrigin = new Point(mover.x, mover.y);
						
			mainScrollingOff = true;
			mainScrollOffTime = 0;
			
			
		}
		
		override protected function end():void {
			super.end();
			
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
				mainScrollOnTime = Math.min(mainScrollOnTime + dTime, SCROLL_ON_TIME);
				f = mainScrollOnTime / SCROLL_ON_TIME;
				eased = Utils.easeIn(f);
				mover.x = moverOrigin.x + (1 - eased) * SCROLL_DISTANCE;
				backgroundImageLayer.alpha = eased;
				
				if (f >= 1) {
					mainScrollingOn = false;
					finished = true;
				}
			} else {
				
			}
			
			super.animate(dTime);
		}
		
		
	}

}