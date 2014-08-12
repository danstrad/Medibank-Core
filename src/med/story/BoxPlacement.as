package med.story {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;

	public class BoxPlacement {

		public var parentID:String;
		public var branch:String; // direction it sprouts in when using Sprouting animation style

		public var position:Point;
		public var offset:Point;
		
		public var unitsWide:Number;
		public var unitsHigh:Number;
		
		public var color:uint;
		public var inverted:Boolean;
		
		
		
		public function BoxPlacement() {
			unitsWide = 1;
			unitsHigh = 1;			
		}

		public function getBounds(scaleMultiplier:Number = 1):Rectangle {
			var w:Number = Box.SIZE * unitsWide * scaleMultiplier;
			var h:Number = Box.SIZE * unitsHigh * scaleMultiplier;
			return new Rectangle( -w / 2, -h / 2, w, h);
		}
		
	}

}