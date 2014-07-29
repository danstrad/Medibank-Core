package med.animation {
	import com.gskinner.utils.Rndm;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.story.Story;

	public class AnimationType {

		public static const FLOATING:String = "floating";
		public static const SLIDING:String = "sliding";
		public static const SPROUTING:String = "sprouting";


		public static function generateData(story:Story, animationInfo:AnimationInfo, homeRect:Rectangle):AnimationData {
			Rndm.reset();
			Rndm.seed = animationInfo.seed;
			var data:AnimationData;
			switch(animationInfo.type) {
				case FLOATING: data = FloatingAnimationData.generate(story, animationInfo, homeRect); break;
				case SPROUTING: data = SproutingAnimationData.generate(story, animationInfo, homeRect); break;
				case SLIDING: data = SlidingAnimationData.generate(story, animationInfo, homeRect); break;
				default: data = null; break;
			}
			data.frameFocus(homeRect == null);
			if (animationInfo.cameraOverride) {
				data.focus = new Point(animationInfo.cameraOverride.x * Box.SIZE, animationInfo.cameraOverride.y * Box.SIZE);
			}
			return data;
		}
		
		static public function getIndex(type:String):int {
			switch(type) {
				default:
				case FLOATING: return 1;
				case SPROUTING: return 2;
				case SLIDING: return 3;
			}
		}

	}

}