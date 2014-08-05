package med.story {
	import flash.geom.Point;
	import med.animation.AnimationData;
	import med.animation.AnimationInfo;

	public class Story {
		
		public var id:String;
		
		//public var parent:Story;

		public var backgroundImageName:String;
		
		public var contentInfos:Vector.<ContentInfo>
		
		public var animationInfos:Array;
		public var smallAnimationInfos:Array;
		
		public var continueStoryID:String; // for 'Continue' button
		public var continueInfographicID:String;
		
		public function Story() {
			contentInfos = new Vector.<ContentInfo>();
			animationInfos = new Array();
			smallAnimationInfos = new Array();
		}
		
	}

}