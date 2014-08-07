package med.animation {
	import com.gskinner.utils.Rndm;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.display.Box;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;
	import med.story.Story;

	public class FloatingAnimationData extends AnimationData {
		
		protected static const TYPE_INDEX:int = AnimationType.getIndex(AnimationType.FLOATING);
		
		static public var COLORS:Vector.<uint>;
		
		public function FloatingAnimationData() {
		}
		
		public static function generate(story:Story, animationInfo:AnimationInfo, homeRect:Rectangle):FloatingAnimationData {
			var data:FloatingAnimationData = new FloatingAnimationData();

			var len:int = Math.max(1, story.contentInfos.length);
			
			var MAX_TRIES:int = 50;
			
			
			
			var total:Number = 0;
			for each(var placement:BoxPlacement in animationInfo.placements) {
				total += placement.getBounds().width;
			}
			
			//var bounds:Rectangle = new Rectangle(0, 0, Math.min(700, total * 0.7), Math.min(400, total * 0.7));			
			//var centreDistance:Number = bounds.width * 0.9;// 1.05;
			
			var bounds:Rectangle = new Rectangle(0, 0, total * 0.7, Math.max(400, total * 0.3));// , total * 0.4));
			var centreDistance:Number =  50 + bounds.width * 0.5;// 200 + bounds.width * 0.5;

			var mid:Point = Point.polar(centreDistance, animationInfo.direction);
			
			bounds.x = mid.x - bounds.width / 2;
			bounds.y = mid.y - bounds.height / 2;
			
			for (var tries:int = MAX_TRIES; tries > 0; tries--) {
				generateBoxStates(story, animationInfo, data, bounds);
				if (validatePositions(story, animationInfo, data)) break;
			}
			
			var time:Number = 300;
			var lastZ:Number = 0;
			for (var i:int = 0; i < story.contentInfos.length; i++) {
				var state:BoxState = data.boxEndStates[i]
				var info:ContentInfo = story.contentInfos[i];
				placement = animationInfo.placements[i];
				
				if (placement.offset) {
					state.zMoveFactor = lastZ;
				} else {
					lastZ = Rndm.random();
					state.zMoveFactor = lastZ
				}

				state.startTime = time;
				state.endTime = state.startTime + 1300 + Rndm.random() * 400;
				data.totalTime = state.endTime;
				time += 250 + Rndm.random() * 50;
			}
			
			data.generateBoxBounds(story, animationInfo, TYPE_INDEX);
			generateFocus(data, story, homeRect);
			
			return data;
		}
		
		
		protected static function generateBoxStates(story:Story, animationInfo:AnimationInfo, data:FloatingAnimationData, area:Rectangle):void {
			var i:int;
			var len:int = story.contentInfos.length;
			var SIZE:Number = Box.SIZE;
			var HALF:Number = SIZE * 0.5;
			data.boxEndStates.length = 0;
			var xTotal:Number = 0;
			var yTotal:Number = 0;

			var estimatedHeaderSize:Number = Box.SIZE * 2;
			var gridOffset:Number = (estimatedHeaderSize / 2) % (Box.SIZE / 6);
			
			var scaleMin:Number = 1;// 0.8;
			var scaleMax:Number = 1;// 1.3;
			var scaleSpread:Number = (scaleMax - scaleMin) / len;
			
			var xPool:Array = [];
			var yPool:Array = [];
			var scalePool:Array = [];
			for (i = 0; i < len; i++) {
				xPool.push((i + 0.5) / len);
				yPool.push((i + 0.5) / len);
				scalePool.push(scaleMin + i * scaleSpread + Rndm.random() * scaleSpread);
			}
			
			var lastY:Number = area.top;
			for (i = 0; i < len; i++) {
				var state:BoxState = new BoxState();
				var info:ContentInfo = story.contentInfos[i];
				var placement:BoxPlacement = animationInfo.placements[i];
				
				var scaleIndex:int = int(Rndm.random() * scalePool.length);
				state.scale = scalePool[scaleIndex];
				scalePool.splice(scaleIndex, 1);
				
				var bounds:Rectangle = placement.getBounds(state.scale);

				if (placement.position) {
					state.x = placement.position.x;
					state.y = placement.position.y;
				} else if (placement.offset) {
					var offsetState:BoxState = data.boxEndStates[Math.max(0, i - 1)];
					state.x = offsetState.x + placement.offset.x;
					state.y = offsetState.y + placement.offset.y;
				} else {
					var xIndex:int = 0;// int(Rndm.random() * xPool.length);
					var yIndex:int = int(Rndm.random() * yPool.length);
					state.x = roundCoordinate(area.x + area.width * xPool[xIndex], bounds.width, gridOffset);
					//state.y = roundCoordinate(area.y + area.height * yPool[yIndex], bounds.height, gridOffset);
					var top:Number;
					var bottom:Number;
					if (lastY > area.y + area.height / 2) {
						top = area.top + bounds.height / 2;
						bottom = lastY - bounds.height;
					} else {
						top = lastY + bounds.height;
						bottom = area.bottom - bounds.height / 2;
					}
					lastY = state.y = roundCoordinate(top + Rndm.random() * (bottom - top), bounds.height, gridOffset);
					xPool.splice(xIndex, 1);
					yPool.splice(yIndex, 1);
				}
				
				state.startRotation = -(360 * (0.6 + Rndm.random() * 0.1));
				
				data.boxEndStates.push(state);
				xTotal += state.x;
				yTotal += state.y;
			}
			
		}
		
		protected static function generateFocus(data:FloatingAnimationData, story:Story, homeRect:Rectangle):void {
			if (data.boxEndStates.length == 0) {
				data.focus = new Point(0, 0);
				data.focusTime = 500;
				return;
			}
			
			var bounds:Rectangle = data.bounds.clone();
			var mid:Point = new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
			if (Math.abs(mid.x) > Math.abs(mid.y)) {
				if (mid.x > 0) data.originVector = new Point(1, 0);
				else data.originVector = new Point(-1, 0);
				//if (mid.x > 0) bounds.left = -headerSize/ 2;
				//else bounds.right = headerSize / 2;
			} else {
				if (mid.y > 0) data.originVector = new Point(0, 1);
				else data.originVector = new Point(0, -1);
				//if (mid.y > 0) bounds.top = -headerSize / 2;
				//else bounds.bottom = headerSize / 2;
			}
			
			var BUFFER:Number = Box.SIZE / 6;
			data.homePoint = new Point(mid.x * 2, mid.y * 2);
			//data.endPoint = new Point(mid.x * 2, mid.y * 2);
			if (Math.abs(mid.x) > Math.abs(mid.y)) {
				if (mid.x > 0) {
					//data.endPoint.x = bounds.right;
					data.homePoint.x = bounds.right + (BUFFER - homeRect.left);
				} else {
					//data.endPoint.x = bounds.left;
					data.homePoint.x = bounds.left - (BUFFER + homeRect.right);
				}
			} else {
				if (mid.y > 0) {
					//data.endPoint.y = bounds.bottom;
					data.homePoint.y = bounds.bottom + (BUFFER - homeRect.top);
				} else {
					//data.endPoint.y = bounds.top;
					data.homePoint.y = bounds.top - (BUFFER + homeRect.bottom);
				}
			}
			
			data.endPoint = data.homePoint.clone();
			
			data.focus = new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
			data.focus.normalize(Math.min(400, data.focus.length));
			data.focusTime = 600 + data.boxEndStates.length * 100;			
			
		}
		
		
		protected static function validatePositions(story:Story, animationInfo:AnimationInfo, data:FloatingAnimationData):Boolean {
			var len:int = data.boxEndStates.length;
			var SIZE:Number = Box.SIZE;
			for (var n1:int = 0; n1 < len; n1++) {
				var i1:ContentInfo = story.contentInfos[n1];
				var p1:BoxPlacement = animationInfo.placements[n1];
				var s1:BoxState = data.boxEndStates[n1];
				var r1:Rectangle = p1.getBounds();
				r1.x += s1.x;
				r1.y += s1.y;
				for (var n2:int = n1 + 1; n2 < len; n2++) {
					var i2:ContentInfo = story.contentInfos[n2];
					var p2:BoxPlacement = animationInfo.placements[n2];
					var s2:BoxState = data.boxEndStates[n2];
					var r2:Rectangle = p2.getBounds();
					r2.x += s2.x;
					r2.y += s2.y;
					if (r1.intersects(r2)) {
						return false;
					}
				}
			}
			return true;
		}
				
	}

}
