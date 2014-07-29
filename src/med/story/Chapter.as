package med.story {
	import med.animation.HomeAnimationData;

	public class Chapter {
	
		public var id:int;

		public var title:String;
		public var bgColor:uint;
		
		public var storyID:String;
		public function get baseStory():Story { return StorySet.getStory(storyID); }
		
		public function Chapter(id:int) {
			this.id = id;			
		}

	}

}