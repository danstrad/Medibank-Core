package med.story {
	import flash.utils.Dictionary;
	import med.animation.HomeAnimationData;
	import med.infographic.InfographicData;

	public class StorySet {
		
		public static var bgColor:uint;
		public static var baseAnimationData:HomeAnimationData;
		public static var animationDatas:Array = new Array();
		
		public static var chapters:Vector.<Chapter> = new Vector.<Chapter>();
		public static var stories:Dictionary = new Dictionary();
		public static var infographics:Dictionary = new Dictionary();
		
		
		public static function getChapterById(chapterID:int):Chapter {
			for each(var chapter:Chapter in chapters) {
				if (chapter.id == chapterID) return chapter;
			}
			return null;
		}
		
		
		
		public static function addStory(story:Story):void {
			stories[story.id] = story;
		}
		
		
		public static function getStory(id:String):Story {
			return stories[id];
		}
		

		
		public static function addInfographic(data:InfographicData):void {
			infographics[data.id] = data;
		}
		
		public static function getInfographic(id:String):InfographicData {
			return infographics[id];
		}
		
		
	}

}