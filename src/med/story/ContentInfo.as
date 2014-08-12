package med.story {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.infographic.InfographicData;
	import med.display.Box;

	public class ContentInfo {
		
		public var text:String;
		public var textType:String;
		public var textScale:Number;
		
		public var subtext:String;
		public var subtextScale:Number;
		
		public var imageURL:String;
		public var imageScrollMargin:Number;
		public var footerImageURL:String;
		public var footerSpace:Number;
		
		public var videoURL:String;
		
		public var infographicID:String;
		public var infographicScale:Number;

		public var linkedStoryID:String;
		public var linkedInfographicID:String;
		public var action:String;
		
		public function get linkedStory():Story {
			if (linkedStoryID) return StorySet.getStory(linkedStoryID);
			else return null;
		}
		
		public function get linkedInfographic():InfographicData {
			if (linkedInfographicID) return StorySet.getInfographic(linkedInfographicID);
			else return null;
		}
		
		
		
		public function ContentInfo() {
			textScale = 1;
			subtextScale = 1;
			imageScrollMargin = 20;
			infographicScale = 1;
			footerSpace = 0.5;
		}
		
		
	}

}