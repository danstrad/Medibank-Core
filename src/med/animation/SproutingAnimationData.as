package med.animation {
	import com.gskinner.utils.Rndm;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.display.Box;
	import med.display.HomeBox;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;
	import med.story.Story;

	public class SproutingAnimationData extends AnimationData {
		
		protected static const TYPE_INDEX:int = AnimationType.getIndex(AnimationType.SPROUTING);

		static public const COLORS:Vector.<uint> = Vector.<uint>([0xff9e45, 0xffa95a]);
		
		public function SproutingAnimationData() {
		}

		public static function generate(story:Story, animationInfo:AnimationInfo, homeRect:Rectangle):SproutingAnimationData {
			var data:SproutingAnimationData = new SproutingAnimationData();
			
			var contentInfos:Vector.<ContentInfo>  = story.contentInfos;
			var direction:Number = animationInfo.direction

			var estimatedHeaderSize:Number = Box.SIZE * 2;
			var gridOffset:Number = (estimatedHeaderSize / 2) % (Box.SIZE / 6);
			
			var i:int;
			var len:int = contentInfos.length;
			var currentDir:uint;
			var currentW:Number = 0;
			var currentH:Number = 0;
			var x:Number = 0;
			var y:Number = 0;
			var time:Number = 600;
			var lastPlacedState:BoxState;
			var lastPlacedBounds:Rectangle;
			
			var exactDir:Number = ((direction * 8 / (Math.PI * 2)) + 8) % 8;
			var lowerDir:int = Math.floor(exactDir);
			var higherDir:int = Math.ceil(exactDir) % 8;
			var templateCount:int = 3;
			var highCount:int = Math.round((exactDir - lowerDir) * templateCount);
			var dirsTemplate:Array = [];
			for (i = 0; i < highCount; i++) dirsTemplate.push(higherDir);
			for (i = 0; i < (templateCount - highCount); i++) dirsTemplate.push(lowerDir);
			
			var dirPool:Array = [];
			for (i = 0; i < len; i++) {

				if (dirPool.length <= 0) dirPool = dirsTemplate.concat();
				var index:int = int(dirPool.length * Rndm.random());
				currentDir = dirPool[index];
				dirPool.splice(index, 1);
				
				var state:BoxState = new BoxState();
				var info:ContentInfo = contentInfos[i];
				var placement:BoxPlacement = animationInfo.placements[i];
				var bounds:Rectangle = placement.getBounds();
				if (placement.position) {
					state.x = placement.position.x;
					state.y = placement.position.y;
				} else if (placement.offset) {
					var offsetState:BoxState = data.boxEndStates[Math.max(0, i - 1)];
					state.x = offsetState.x + placement.offset.x;
					state.y = offsetState.y + placement.offset.y;
				} else {
					var w:Number = bounds.width;
					var h:Number = bounds.height;					
					var X_EDGE:Number = 0.5;
					var Y_EDGE:Number = 0.5;
					var rnd:Number = Rndm.random();
					var X_SLIDE:Number = (0.1 + rnd * 0.3);
					var Y_SLIDE:Number = (0.1 + rnd * 0.3);
					var dx:Number = 0;
					var dy:Number = 0;
					switch(currentDir) {
						case 0:
							state.source = "tl";
							dx = X_EDGE;
							dy = Y_SLIDE;
							break;
						case 1:
							state.source = "tl";
							dx = X_SLIDE;
							dy = Y_EDGE;
							break;
						case 2:
							state.source = "tr";
							dx = -X_SLIDE;
							dy = Y_EDGE;
							break;
						case 3:
							state.source = "tr";
							dx = -X_EDGE;
							dy = Y_SLIDE;
							break;
						case 4:
							state.source = "br";
							dx = -X_EDGE;
							dy = -Y_SLIDE;
							break;
						case 5:
							state.source = "br";
							dx = -X_SLIDE;
							dy = -Y_EDGE;
							break;
						case 6:
							state.source = "bl";
							dx = X_SLIDE;
							dy = -Y_EDGE;
							break;
						case 7:
							state.source = "bl";
							dx = X_EDGE;
							dy = -Y_SLIDE;
							break;
					}
					x += dx * (currentW + w);
					y += dy * (currentH + h);
					x = roundCoordinate(x, w, gridOffset);
					y = roundCoordinate(y, h, gridOffset);
					state.x = x;
					state.y = y;
					lastPlacedState = state;
					lastPlacedBounds = bounds;
					if (!data.originVector) data.originVector = new Point(dx * 2, dy * 2);
				}
				state.startTime = time;
				state.endTime = state.startTime + 60 + 80 * Math.sqrt(Math.pow(bounds.width, 2) + Math.pow(bounds.height, 2)) / Box.SIZE;
				data.totalTime = state.endTime;
				time = state.endTime - (state.endTime - state.startTime) * 0.25;
				currentW = w;
				currentH = h;
				data.boxEndStates.push(state);
				
				/*
				dirCount--;
				if (dirCount <= 0) {
					dirCount = Math.round(1 + Rndm.random() * 2);
					var dir:int = currentDir;
					if (Rndm.random() > 0.1) {
						if (Rndm.random() > 0.5) dir++;
						else dir--;
					}
					var dif:int = dir - startDir;
					while (dif < -1) dif += 8;
					if (dif <= 1) currentDir = dir;
				}
				*/
			}
			
			data.generateBoxBounds(story, animationInfo, TYPE_INDEX);

			if (!lastPlacedState) {
				lastPlacedState = state;
				lastPlacedBounds = bounds;
			}
			if (lastPlacedState) {
				var offset:Number;
				switch(lastPlacedState.source) {
					case "tl":
					case "bl":
						//offset = Box.SIZE * 1; //-homeRect.left;
						offset = -homeRect.left;
						data.homePoint = new Point(lastPlacedState.x + lastPlacedBounds.width / 2 + offset, lastPlacedState.y);
						break;
					case "tr":
					case "br":
						//offset = -Box.SIZE * 1; //-homeRect.right;
						offset = -homeRect.right;
						data.homePoint = new Point(lastPlacedState.x - lastPlacedBounds.width / 2 + offset, lastPlacedState.y);
						break;
				}
				//data.endPoint = new Point(lastPlacedState.x, lastPlacedState.y);
			}
			if (!data.homePoint) {
				data.homePoint = new Point(x, y);
				data.homePoint.normalize(data.homePoint.length + Box.SIZE * 2);
				//data.endPoint = new Point(x, y);
				//data.endPoint.normalize(data.endPoint.length + Box.SIZE * 1);
			}
			data.endPoint = data.homePoint.clone();

			data.generateFocus(homeRect);
			
			return data;
		}
				
		public function generateFocus(homeRect:Rectangle):void {
			var last:BoxState = boxEndStates[boxEndStates.length - 1];
			var x:Number = last.x;
			var y:Number = last.y;
			var xLimit:Number = BoxesMain.STAGE_WIDTH / 2 - 60; //160
			var yLimit:Number = BoxesMain.STAGE_HEIGHT / 2 - 60; //160
			focus = new Point(x / 2, y / 2);
			focus.x = Math.max(-xLimit, Math.min(xLimit, focus.x));
			focus.y = Math.max(-yLimit, Math.min(yLimit, focus.y));
			focusTime = 500 + focus.length * 3;
		}
		
		public function generateWrapFocus():void {
			var last:BoxState = boxEndStates[boxEndStates.length - 1];
			var x:Number = last.x;
			var y:Number = last.y;

			const BORDER:int = 200;
			
			x = Math.max(x - BORDER, Math.min(x + BORDER, x * 0.8));
			y = Math.max(y - BORDER, Math.min(y + BORDER, y * 0.8));
			focus = new Point(x, y);
			
			focusTime = 500 + focus.length * 3;
		}
		
		
	}

}