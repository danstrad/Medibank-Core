package med.story {
	import med.animation.HomeAnimationData;
	import med.infographic.InfographicData;

	public class Chapter {
	
		public var id:int;

		public var title:String;
		public var bgColor:uint;
		

		public var baseStoryID:String;
		public var baseInfographicID:String;

		public function get baseStory():Story {
			if (baseStoryID) return StorySet.getStory(baseStoryID);
			else return null;
		}
		
		public function get baseInfographic():InfographicData {
			if (baseInfographicID) return StorySet.getInfographic(baseInfographicID);
			else return null;
		}

		
		public function Chapter(id:int) {
			this.id = id;			
		}

	}

}