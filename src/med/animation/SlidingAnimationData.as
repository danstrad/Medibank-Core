package med.animation {
	import com.gskinner.utils.Rndm;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.display.Box;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;
	import med.story.Story;

	public class SlidingAnimationData extends AnimationData {

		protected static const TYPE_INDEX:int = AnimationType.getIndex(AnimationType.SLIDING);
		
		static public var COLORS:Vector.<uint>;
		
		public var totalLaneWidth:Number;
		
		public function SlidingAnimationData() {
		}

		public static function generate(story:Story, animationInfo:AnimationInfo, homeRect:Rectangle):SlidingAnimationData {
			var data:SlidingAnimationData = new SlidingAnimationData();
			
			var contentInfos:Vector.<ContentInfo> = story.contentInfos;
			var direction:Number = animationInfo.direction
			var totalLaneWidth:Number = data.totalLaneWidth = (animationInfo.param || 2) * Box.SIZE;
						
			var len:int = contentInfos.length;
			var SIZE:Number = Box.SIZE;
			var time:Number = 600;
			data.totalTime = time;
			var a1:Number = 0.16;
			var a2:Number = 0.24;
			var currentLane:Number = 0;
			var currentExpand:Number = 0;
			var currentLaneWidth:Number = 0;
			var maxExpandIncrease:Number = 0;
			
			var laneXMultiplier:Number = 0;
			var laneYMultiplier:Number = 0;
			var expandXMultiplier:Number = 0;
			var expandYMultiplier:Number = 0;
			var dir:int = Math.round((direction + Math.PI / 4) / (Math.PI / 2)) % 4;
			switch(dir) {
				case 0:
					laneXMultiplier = 1;
					expandYMultiplier = -1;
					break;
				case 1:
					expandXMultiplier = 1;
					laneYMultiplier = 1;
					break;
				case 2:
					laneXMultiplier = 1;
					expandYMultiplier = 1;
					break;
				case 3:
					expandXMultiplier = -1;
					laneYMultiplier = 1;
					break;
			}
			data.originVector = new Point(expandXMultiplier, expandYMultiplier);
			
			var laneBoxes:Vector.<BoxState> = new Vector.<BoxState>();
			for (var i:int = 0; i < len; i++ ) {
				var state:BoxState = new BoxState();
				var info:ContentInfo = contentInfos[i];
				var placement:BoxPlacement = animationInfo.placements[i];
				var bounds:Rectangle = placement.getBounds();
				var endLane:Boolean = (i == len - 1);
				state.dir = dir;
				if (placement.position) {
					state.x = placement.position.x;
					state.y = placement.position.y;
				} else if (placement.offset) {
					var offsetState:BoxState = data.boxEndStates[Math.max(0, i - 1)];
					state.x = offsetState.x + placement.offset.x;
					state.y = offsetState.y + placement.offset.y;
				} else {
					//var expandPos:Number = (1.5 + currentExpand + (scale - 1) / 2);
					//var lanePos:Number = (currentLane - totalLaneWidth / 2 + scale / 2);
					//maxExpandIncrease = Math.max(maxExpandIncrease, scale);
					var expandIncrease:Number = (expandXMultiplier * bounds.width) + (expandYMultiplier * bounds.height);
					var laneIncrease:Number = (laneXMultiplier * bounds.width) + (laneYMultiplier * bounds.height);
					maxExpandIncrease = Math.max(maxExpandIncrease, expandIncrease);
					var expandPos:Number = currentExpand + expandIncrease / 2;
					var lanePos:Number = currentLane + laneIncrease / 2;
					currentLaneWidth += laneIncrease;
					laneBoxes.push(state);
					state.x = roundCoordinate(expandPos * expandXMultiplier + lanePos * laneXMultiplier, bounds.width, 0);
					state.y = roundCoordinate(expandPos * expandYMultiplier + lanePos * laneYMultiplier, bounds.height, 0);
					currentLane += laneIncrease;
					if (currentLane >= totalLaneWidth) endLane = true;
					
					if (endLane) {
						var laneMove:Number = -(currentLaneWidth / 2);
						for each(state in laneBoxes) {
							state.x += laneMove * laneXMultiplier;
							state.y += laneMove * laneYMultiplier;
						}
						laneBoxes.length = 0;
						currentLaneWidth = 0;
						currentLane = 0;
						currentExpand += maxExpandIncrease;
						maxExpandIncrease = 0;
					}
				}
				state.startTime = time;
				state.endTime = time + ((expandIncrease || SIZE) / SIZE) * 150;
				data.totalTime = Math.max(data.totalTime, state.endTime);
				if (endLane) time = data.totalTime - ((maxExpandIncrease || SIZE) / SIZE) * 50;
				data.boxEndStates.push(state);
			}

			data.generateBoxBounds(story, animationInfo, TYPE_INDEX);
			
			
			data.homePoint = new Point(0, 0);
			data.homePoint.x += (-totalLaneWidth / 2 + Box.SIZE * 0.5) * laneXMultiplier;
			data.homePoint.y += (-totalLaneWidth / 2 + Box.SIZE * 0.5) * laneYMultiplier;
			data.homePoint.x += (currentExpand + Box.SIZE * 0.5) * expandXMultiplier;
			data.homePoint.y += (currentExpand + Box.SIZE * 0.5) * expandYMultiplier;
			data.endPoint = new Point(0, 0);
			data.endPoint.x += (currentExpand + Box.SIZE * 0.5) * expandXMultiplier;
			data.endPoint.y += (currentExpand + Box.SIZE * 0.5) * expandYMultiplier;

			data.focus = new Point(currentExpand * expandXMultiplier / 2, currentExpand * expandYMultiplier / 2);
			data.focusTime = 500 + currentExpand * 3;
			
			return data;
		}
		
		
	}

}
