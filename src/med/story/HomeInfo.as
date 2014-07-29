package med.story {
	import flash.geom.ColorTransform;
	public class HomeInfo {

		public var chapterID:int;
		
		public var width:Number;
		public var height:Number;

		public var text:String;
		
		public var imageURL:String;
		
		public var videoURL:String;
		
		public var defaultColorTransform:ColorTransform;
		
		
		public function HomeInfo(chapterID:int) {
			this.chapterID = chapterID;
			width = 1;
			height = 1;
		}
				
	}

}