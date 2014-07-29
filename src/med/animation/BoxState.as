package med.animation {

	public class BoxState {
		
		public var x:Number;
		public var y:Number;
		public var scale:Number;
		
		public var dir:int;

		public var startTime:Number;
		public var endTime:Number;
		public function get animLength():Number { return endTime - startTime; }
		
		public var startRotation:Number;
		public var alpha:Number;
		public var inverted:Boolean;

		public var source:String;		

		public var zMoveFactor:Number;
		
		
		public function BoxState() {
			scale = 1;
			zMoveFactor = 1;
		}
		
		static public function forHeader(x:Number, y:Number, inverted:Boolean, scale:Number):BoxState {
			var state:BoxState = new BoxState();
			state.x = x;
			state.y = y;
			state.inverted = inverted;
			state.scale = scale;
			return state;			
		}
		
	}
	
}