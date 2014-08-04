package med.infographic {
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	
	public class PeopleGraphPerson extends _PeopleGraphPerson {

		protected var interior:Shape;

		public static const RADIUS:Number = 13.35;
		
		public static const STATE_NEUTRAL:uint 	= 1;
		public static const STATE_LEFT:uint 	= 2;
		public static const STATE_RIGHT:uint 	= 3;
		
		
		public var rowIndex:int = -1;
		public var state:uint;
		
		
		// animation constants
		private static const ANIMATE_ON_EXPAND_TIME:Number = 0.5;
		private static const ANIMATE_ON_FILL_TIME:Number = 0.5;
		
		
		
		public function PeopleGraphPerson() {
			
			// init interior
			interior = new Shape();
			addChild(interior);
			
//			interior.cacheAsBitmap = true;
			
		}

		
		public function reset():void {
			
			var color:uint = 0xff9330;
						
			interior.graphics.clear();
			
			interior.graphics.beginFill(color, 1);
			interior.graphics.drawCircle(0, 0, RADIUS);
			interior.graphics.endFill();
			
			this.filters = null;
			
			this.transform.colorTransform = new ColorTransform();
			
		}
		
		
		
		
		public function animateOnPerson(delayMsec:Number=0):void {
			
			// scale up as outline, then fill in the center			
			this.filters = null;
			
			this.visible = true;
			interior.visible = false;
			
			// scale up the exterior
			TweenMax.fromTo(this, ANIMATE_ON_EXPAND_TIME, { scaleX:0, scaleY:0 }, { delay:delayMsec * 0.001, scaleX:1, scaleY:1, immediateRender:true, onComplete:animateOnFill } );

		}
		
		
		private function animateOnFill():void {
			// second phase of animating on- expand the interior fill

			interior.visible = true;
			
			// scale up the interior
			TweenMax.fromTo(interior, ANIMATE_ON_FILL_TIME, { scaleX:0, scaleY:0 }, { scaleX:1, scaleY:1, immediateRender:true } );
			
		}
		
		
		
	}

}