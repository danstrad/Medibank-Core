package med.animation {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;
	import med.story.Story;

	public class AnimationData {

		private static const CHAPTER_MARGIN:Number = 210;// 250;
		private static const STORY_MARGIN:Number = 25;// 100;
		protected static const FRAMING_CHAPTER:Rectangle = new Rectangle( -Camera.WIDTH / 2 + CHAPTER_MARGIN, -Camera.HEIGHT / 2 + CHAPTER_MARGIN, Camera.WIDTH - CHAPTER_MARGIN * 2, Camera.HEIGHT - CHAPTER_MARGIN * 2);
		protected static const FRAMING_STORY:Rectangle = new Rectangle( -Camera.WIDTH / 2 + STORY_MARGIN, -Camera.HEIGHT / 2 + STORY_MARGIN, Camera.WIDTH - STORY_MARGIN * 2, Camera.HEIGHT - STORY_MARGIN * 2);
		//protected static const FRAMING_CHAPTER:Rectangle = new Rectangle(-CHAPTER_MARGIN, -CHAPTER_MARGIN, CHAPTER_MARGIN * 2, CHAPTER_MARGIN * 2);
		//protected static const FRAMING_STORY:Rectangle = new Rectangle(-STORY_MARGIN, -STORY_MARGIN, STORY_MARGIN * 2, STORY_MARGIN * 2);
		
		public var originVector:Point;
		
		public var focus:Point;
		public var focusTime:Number;
		
		public var totalTime:Number;
		
		public var boxEndStates:Vector.<BoxState>;
		public var endPoint:Point;
		public var homePoint:Point;
		public var bounds:Rectangle;
		
		public function AnimationData() {			
			boxEndStates = new Vector.<BoxState>();			
		}
		
		public function generateBoxBounds(story:Story, animationInfo:AnimationInfo, typeIndex:int):void {
			bounds = null;
			var len:int = boxEndStates.length;
			for (var i:int = 0; i < len; i++) {
				var info:ContentInfo = story.contentInfos[i];
				var state:BoxState = boxEndStates[i];
				var placement:BoxPlacement = animationInfo.placements[i];
				var stateBounds:Rectangle = placement.getBounds(state.scale);
				stateBounds.offset(state.x, state.y);
				if (bounds) bounds = bounds.union(stateBounds);
				else bounds = stateBounds;
			}
		}
		
		
		protected static const SIXTH:Number = Box.SIZE / 6
		static protected function roundCoordinate(n:Number, centering:Number, gridOffset:Number):Number {
			//return Math.round((n - centering / 2 + gridOffset) / SIXTH) * SIXTH + centering / 2 - gridOffset;
			return n;
		}
		
		public function frameFocus(isChapter:Boolean):void {
			var framing:Rectangle = isChapter ? FRAMING_CHAPTER : FRAMING_STORY;
			framing = framing.clone();
			var estimatedHeaderSize:Number = Box.SIZE * 2;
			framing.inflate( -Math.min(framing.width / 2, estimatedHeaderSize / 2), -Math.min(framing.height / 2, estimatedHeaderSize / 2));
			var framingGradient:Number = framing.height / framing.width;
			var focusGradient:Number = Math.abs(focus.y / focus.x);
			var multiplier:Number;
			if (focusGradient > framingGradient) { // out top/bottom
				multiplier = framing.bottom / Math.abs(focus.y);
			} else { // out sides				
				multiplier = framing.right / Math.abs(focus.x);
			}
			//if (multiplier < 1) {
				focus.x *= multiplier;
				focus.y *= multiplier;
			//}
		}
		
		
		public function getOriginOffsetFor(box:Box):Point {
			return new Point(originVector.x * box.widthAsHeader / 2, originVector.y * box.heightAsHeader / 2);
		}
		
		

	}

}