package med.animation {
	import flash.geom.Point;
	import med.story.BoxPlacement;

	public class AnimationInfo {

		public var type:String;
		public var small:Boolean;
		public var direction:Number;
		public var seed:int;
		public var param:Number;
		public var cameraOverride:Point;

		public var data:AnimationData;		
		public var placements:Vector.<BoxPlacement>;
		
		public function get typeIndex():int { return AnimationType.getIndex(type); }
		
		public function AnimationInfo() {
			placements = new Vector.<BoxPlacement>();
		}

	}

}