package med.infographic {
	import com.garin.particles.ParticleBurstHorizontal;
	import com.greensock.TweenMax;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	
	public class PeopleGraphPerson extends _PeopleGraphPerson {

		
		public static const RADIUS:Number = 11.35; // 13.35;
		
		public static const STATE_NEUTRAL:uint 	= 1;
		public static const STATE_LEFT:uint 	= 2;
		public static const STATE_RIGHT:uint 	= 3;
		
		
		public var rowIndex:int = -1;
		public var columnIndex:int = -1;
		
		public var state:uint;
		public var drawColor:uint;		
		
		// animation constants
		private static const ANIMATE_ON_EXPAND_TIME:Number = 0.5;
		private static const ANIMATE_ON_FILL_TIME:Number = 0.5;
				
		
		protected var interior:Shape;
		protected var exterior:Shape;

		
		
		public function PeopleGraphPerson(drawColor:uint) {
			this.drawColor = drawColor;
			
			interior = new Shape();
			addChild(interior);
			
			exterior = new Shape();
			addChild(exterior);

			reset();
		}

		
		public function reset():void {
								
			exterior.graphics.clear();
			exterior.graphics.lineStyle(5, drawColor, 1);
			exterior.graphics.drawCircle(0, 0, RADIUS);
			
			interior.graphics.clear();			
			
			this.filters = null;
			
			this.transform.colorTransform = new ColorTransform();
			
		}
		
		
		
		
		public function animateOnPerson(delayMsec:Number=0):void {
			
			// scale up as outline, then fill in the center			
			this.filters = null;
			
			this.visible = true;
			
			interior.visible = false;
			exterior.visible = true;
			
			// scale up the exterior
			TweenMax.fromTo(this, ANIMATE_ON_EXPAND_TIME, { scaleX:0, scaleY:0 }, { delay:delayMsec * 0.001, scaleX:1, scaleY:1, immediateRender:true, onComplete:animateOnFill } );

		}
		

		protected var fillingTimeMsec:Number;
		
		
		public function animate(dTime:Number):void {
			if (!filling)	return;
			
			fillingTimeMsec += dTime;
									
			var frac:Number = Math.min(1.0, (fillingTimeMsec * 0.001) / ANIMATE_ON_FILL_TIME);
			
			var drawRadius:Number = RADIUS * (1.0 - frac);
			
			interior.graphics.lineStyle(5, drawColor, 1);
			interior.graphics.drawCircle(0, 0, drawRadius);
			
			if (frac == 1.0) {
				filling = false;
			}
			
		}
		
		
		public var filling:Boolean = false;
		
		
		private function animateOnFill():void {
			// second phase of animating on- expand the interior fill
			filling = true;
			fillingTimeMsec = 0;		
			interior.visible = true;
		}
		
		
		
	}

}