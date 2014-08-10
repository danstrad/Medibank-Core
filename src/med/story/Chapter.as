package med.story {
	import med.animation.HomeAnimationData;
	import med.infographic.InfographicData;

	public class Chapter {
	
		public var id:int;

		public var title:String;
		public var bgColor:uint;
		
		public var baseStoryID:String;
		public var baseInfographicID:String;
		
		public var infographicColor1:uint;
		public var infographicColor2:uint;
		public var infographicColor3:uint;
		public var infographicColor4:uint;
		public var infographicColor5:uint;
		public var infographicColor6:uint;
		
		
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
		
		public function getInfographicColors():Vector.<uint> {
			var colors:Vector.<uint> = new Vector.<uint>();
			colors.push(infographicColor1);
			colors.push(infographicColor2);
			colors.push(infographicColor3);
			colors.push(infographicColor4);
			colors.push(infographicColor5);
			colors.push(infographicColor6);
			return colors;
		}

	}

}