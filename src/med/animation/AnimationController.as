package med.animation {
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.display.Box;
	import med.display.HomeBox;
	import med.display.SubstoryFlash;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;
	import med.story.Story;

	public class AnimationController {
		
		static public const ANIM_KEY:String = "anim";
		static public const IDLE_KEY:String = "idle";
		static public const Z_KEY:String = "z";
		
		static public const FLASH_TIME_PER_BOX:Number = SubstoryFlash.TIME * 5;

		protected static const ZERO_POINT:Point = new Point(0, 0);
		protected static const END_SPEED_MULTIPLIER:Number = 2;

		public var container:DisplayObjectContainer;
		protected var camera:Camera;
		public var parentBox:Box;
		public var currentParentPosition:Point;
		public var parentHighlightPosition:Point;

		public var story:Story;
		public var animationInfo:AnimationInfo;
		public var animationData:AnimationData;
		protected var isChapter:Boolean;

		public var contentBoxes:Vector.<Box>;
		public var flashBoxes:Vector.<Box>;
		public var currentFlashBoxList:Vector.<Box>;
		
		protected var highlightControllers:Vector.<HighlightController>;

		protected var bouncers:Vector.<Box>;
		protected var bounceTime:Number;
		protected var bounceBox:Box;
		protected var bounceOffset:Point;
		protected var bounceDir:int;
		protected var lastBounceIndex:int;
				
		public var finished:Boolean; // Finished initial animation
		protected var ending:Boolean;
		public var ended:Boolean;
		
		public var home:HomeAnimationController;

		protected var animationTime:Number;
		protected var waitTimeRemaining:Number;
		protected var endTimeRemaining:Number;
		protected var endTimeTotal:Number;
		protected var flashTimeRemaining:Number;
		protected var flashTimeTotal:Number;
		
		public var autoPanStart:Point;
		public var autoPanEnd:Point;
		

		public function AnimationController(story:Story, animationInfo:AnimationInfo, parentBox:Box, parentHighlightPosition:Point, container:DisplayObjectContainer, camera:Camera, isChapter:Boolean) {
			this.isChapter = isChapter;
			this.animationInfo = animationInfo;
			this.parentHighlightPosition = parentHighlightPosition;
			this.story = story;
			this.parentBox = parentBox;
			this.container = container;
			this.camera = camera;

			currentParentPosition = new Point(0, 0);
			
			animationData = animationInfo.data;

			home = parentBox.home;
			
			animationTime = 0;
			waitTimeRemaining = 0;
			
			highlightControllers = new Vector.<HighlightController>();
			
			var typeIndex:int = animationInfo.typeIndex;
			
			
			contentBoxes = new Vector.<Box>();
			flashBoxes = new Vector.<Box>();
			currentFlashBoxList = new Vector.<Box>();
			var toPlace:Vector.<Box> = new Vector.<Box>();
			var len:int = story.contentInfos.length;
			for (var i:int = 0; i < len; i++) {
				
				var info:ContentInfo = story.contentInfos[i];
				var placement:BoxPlacement = animationInfo.placements[i];

				var box:Box = new Box(placement.color);
				box.home = home;
				box.endState = animationData.boxEndStates[i];
				box.showContentInfo(info, placement);

				//if (info.substoryID) flashBoxes.push(box);
				if (box.substoryFlash) flashBoxes.push(box);
				
				switch(animationInfo.type) {
					case AnimationType.FLOATING:
					case AnimationType.SPROUTING:
						box.widthAsHeader = 2 * Box.SIZE;
						box.heightAsHeader = 2 * Box.SIZE;
						break;
					case AnimationType.SLIDING:
						box.widthAsHeader = 2.5 * Box.SIZE;
						box.heightAsHeader = placement.unitsHigh * Box.SIZE;
						break;
				}
				//box.widthAsHeader = placement.unitsWide * Box.SIZE;
				//box.heightAsHeader = placement.unitsHigh * Box.SIZE;
				
				contentBoxes.push(box);
				toPlace.push(box);
			}

			if (animationInfo.type == AnimationType.FLOATING) {
				toPlace.sort(compareZ);
			}
			
			for each(box in toPlace) {
				container.addChild(box);
			}
			
			flashTimeTotal = FLASH_TIME_PER_BOX / flashBoxes.length;
			flashTimeRemaining = flashTimeTotal;

			switch(animationInfo.type) {
				case AnimationType.FLOATING: startFloating(); break;
				case AnimationType.SLIDING: startSliding(); break;
				case AnimationType.SPROUTING: startSprouting(); break;
			}
			alignContainer();

			
		}
		protected function compareZ(a:Box, b:Box):int {
			if (a.endState.zMoveFactor > b.endState.zMoveFactor) return -1;
			if (a.endState.zMoveFactor < b.endState.zMoveFactor) return 1;
			return 0;
		}

		public function wait(time:Number):void {
			waitTimeRemaining += time;
		}
				
		public function continueAnimation(dTime:Number, isCurrent:Boolean, camFocus:Point):void {
			if (waitTimeRemaining > 0) {
				if (waitTimeRemaining > dTime) {
					waitTimeRemaining -= dTime;
					return;
				} else {
					dTime -= waitTimeRemaining;
					waitTimeRemaining = 0;
				}
			}

			animateHighlighControllers(dTime);
			
			if (!finished || ending) {
				var continueTime:Number = dTime;
				if (ending) continueTime = -dTime * END_SPEED_MULTIPLIER;
				switch(animationInfo.type) {
					case AnimationType.FLOATING: continueFloating(continueTime); moveFloatingZ(camFocus); break;
					case AnimationType.SLIDING: continueSliding(continueTime); break;
					case AnimationType.SPROUTING: continueSprouting(continueTime); break;
				}
			} else {				
				switch(animationInfo.type) {
					case AnimationType.FLOATING:
						idleFloating(dTime, isCurrent);
						moveFloatingZ(camFocus);
						break;
				}
			}
			
			continueFlashIdling(dTime);
			moveImageZ(camFocus);
			
			alignContainer();
			
			for each(var box:Box in contentBoxes) {
				box.animate(dTime);
			}
			

			if (ending) {
				endTimeRemaining -= dTime;
				if (endTimeRemaining <= 0) {
					dispose();
					ended = true;
				} else {
					container.alpha = Utils.easeOut(endTimeRemaining / endTimeTotal);
				}
			}
		}

		public function completeInstantly():void {
			var dTime:Number = 10 * 1000;
			switch(animationInfo.type) {
				case AnimationType.FLOATING: continueFloating(dTime); break;
				case AnimationType.SLIDING: continueSliding(dTime); break;
				case AnimationType.SPROUTING: continueSprouting(dTime); break;
			}
		}
		

		public function end():void {
			ending = true;
			endTimeRemaining = endTimeTotal = animationData.totalTime / END_SPEED_MULTIPLIER;
			
			for each(var box:Box in contentBoxes) box.ending = true;
		}


		protected function startFloating():void {
			var data:FloatingAnimationData = animationData as FloatingAnimationData;
			bouncers = new Vector.<Box>();
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.setScale(state.scale * 0.1, ANIM_KEY);
				box.setPosition(0, 0, ANIM_KEY);
				box.rotation = state.startRotation;
				box.alpha = 0;// state.alpha;
				box.visible = false;
				box.contentX = -Box.SIZE;				
				box.contentVisible = false;
				if (box.contentInfo.linkedStory) bouncers.push(box);
			}
			bounceTime = 1500 + Math.random() * 1000;
			bounceBox = null;
		}
		protected function continueFloating(dTime:Number):void {
			var data:FloatingAnimationData = animationData as FloatingAnimationData;
			animationTime = Math.max(0, Math.min(animationTime + dTime, data.totalTime));
			finished = (animationTime >= data.totalTime);
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.visible = (animationTime >= state.startTime);
				//if ((dTime > 0) && (animationTime >= state.endTime)) continue;
				//if ((dTime < 0) && (animationTime <= state.startTime)) continue;
				var f:Number = Math.min(1, Math.max(0, (animationTime - state.startTime) / state.animLength));
				var animF:Number = Utils.f(0, 0.4, f);
				var scaleF:Number = Utils.f(0.4, 0.6, f);
				var contentF:Number = Utils.f(0.6, 1, f);
				var eased:Number = Utils.easeOut(animF);
				box.setPosition(state.x * eased, state.y * eased, ANIM_KEY);
				box.alpha = eased;// state.alpha * eased;
				box.rotation = state.startRotation * Utils.easeOut(1 - animF);
				if (animF < 1) box.setScale((0.1 + 0.2 * animF) * state.scale, ANIM_KEY);
				else box.setScale((0.3 + 0.7 * scaleF) * state.scale, ANIM_KEY);				
				box.contentX = ( -1 + Utils.easeOut(contentF)) * box.placement.unitsWide * Box.SIZE;
				if (ending) {
					if ((contentF <= 0) && box.contentVisible) {
						box.contentVisible = false;
						box.contentMasked = false;
					} else if ((contentF < 1) && !box.contentMasked) {
						box.contentMasked = true;
					}
				} else {
					if ((contentF >= 1) && box.contentMasked) {
						box.contentMasked = false;
					} else if ((contentF > 0) && !box.contentVisible) {
						box.contentVisible = true;
						box.contentMasked = true;
					}
				}
			}
		}
		protected function idleFloating(dTime:Number, isCurrent:Boolean):void {
			const BOUNCE_LENGTH:Number = 650;
			bounceTime -= dTime;
			if (bounceBox && !isCurrent && (bounceTime > BOUNCE_LENGTH)) bounceBox = null;
			if (bounceBox) {
				if (bounceTime <= 0) {
					bounceBox.rotation = 0;
					bounceBox.setPosition(-bounceOffset.x, -bounceOffset.y, IDLE_KEY);
					bounceBox = null;
					bounceOffset = null;
				} else if (bounceTime < BOUNCE_LENGTH) {
					//var f:Number = 1 - Math.abs(bounceTime - (BOUNCE_LENGTH / 2)) / (BOUNCE_LENGTH / 2);
					var f:Number = 1 - bounceTime / BOUNCE_LENGTH;
					var f2:Number;
					var split:Number = 0.55;
					var mag1:Number = 1;
					var mag2:Number = 0.6;
					if (f < split) f2 = mag1 * Math.sin((f / split) * Math.PI);
					else f2 = mag2 * Math.sin(((f - split) / (1 - split) * Math.PI));
					bounceBox.rotation = f2 * 10 * bounceDir;
					bounceOffset.x = f2 * 5 * bounceDir;
					bounceOffset.y = f2 * -20;
					bounceBox.setPosition(bounceOffset.x, bounceOffset.y, IDLE_KEY);
				}
			} else {
				if (isCurrent && (bouncers.length > 0)) {
					var index:int = int(Math.random() * bouncers.length);
					if (index == lastBounceIndex) index = (index + 1) % bouncers.length;
					lastBounceIndex = index;
					bounceBox = bouncers[index];
					bounceOffset = new Point(0, 0);
					bounceDir = (Math.random() > 0.5) ? 1 : -1;
					bounceTime = 1000 + Math.random() * 2000;
				} else {
					bounceTime = Number.POSITIVE_INFINITY;
				}
			}
		}

		
		protected function startSprouting():void {
			var data:SproutingAnimationData = animationData as SproutingAnimationData;
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.setPosition(state.x, state.y, ANIM_KEY);
				box.visible = false;
				box.setScale(0, ANIM_KEY);
			}
		}
		protected function continueSprouting(dTime:Number):void {
			var data:SproutingAnimationData = animationData as SproutingAnimationData;
			animationTime = Math.max(0, Math.min(animationTime + dTime, data.totalTime));
			finished = (animationTime >= data.totalTime);
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.visible = (animationTime >= state.startTime);
				//if ((dTime > 0) && (animationTime >= state.endTime)) continue;
				//if ((dTime < 0) && (animationTime <= state.startTime)) continue;
				var bounds:Rectangle = box.placement.getBounds(state.scale);
				var xRad:Number = bounds.width / 2;
				var yRad:Number = bounds.height / 2;
				var sourcePoint:Point;
				switch(state.source) {
					default:
					case "tl": sourcePoint = new Point(state.x - xRad, state.y - yRad); break;
					case "tr": sourcePoint = new Point(state.x + xRad, state.y - yRad); break;
					case "bl": sourcePoint = new Point(state.x - xRad, state.y + yRad); break;
					case "br": sourcePoint = new Point(state.x + xRad, state.y + yRad); break;
				}
				var f:Number = Math.min(1, Math.max(0, (animationTime - state.startTime) / state.animLength));
				var eased:Number = Utils.easeOut(f);
				box.setScale(state.scale * eased, ANIM_KEY);
				box.setPosition(sourcePoint.x + (state.x - sourcePoint.x) * eased, sourcePoint.y + (state.y - sourcePoint.y) * eased, ANIM_KEY);
			}
		}


		protected function startSliding():void {
			var data:SlidingAnimationData = animationData as SlidingAnimationData;
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.setPosition(state.x, state.y, ANIM_KEY);
				box.setScale(state.scale, ANIM_KEY);
				box.visible = false;
				box.bgMasked = true;
				box.contentMasked = true;
			}
		}
		protected function continueSliding(dTime:Number):void {
			var data:SlidingAnimationData = animationData as SlidingAnimationData;
			animationTime = Math.max(0, Math.min(animationTime + dTime, data.totalTime));
			finished = (animationTime >= data.totalTime);
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.visible = (animationTime >= state.startTime);
				//if ((dTime > 0) && (animationTime >= state.endTime)) continue;
				//if ((dTime < 0) && (animationTime <= state.startTime)) continue;
				var f:Number = Math.min(1, Math.max(0, (animationTime - state.startTime) / state.animLength));
				var bgF:Number = Math.max(0, Math.min(1, f / 0.6));
				var contentF:Number = Math.max(0, Math.min(1, (f - 0.4) / 0.6));
				var bgEased:Number = Utils.easeOut(bgF);
				var contentEased:Number = Utils.easeOut(contentF);
				switch(state.dir) {
					case 0: box.bgY = (1 - bgEased) * box.placement.unitsHigh * Box.SIZE; box.contentY = (1 - contentEased) * box.placement.unitsHigh * Box.SIZE; break;
					case 1:	box.bgX = (-1 + bgEased) * box.placement.unitsWide * Box.SIZE; box.contentX = (-1 + contentEased) * box.placement.unitsWide * Box.SIZE; break;
					case 2: box.bgY = (-1 + bgEased) * box.placement.unitsHigh * Box.SIZE; box.contentY = (-1 + contentEased) * box.placement.unitsHigh * Box.SIZE; break;
					case 3: box.bgX = (1 - bgEased) * box.placement.unitsWide * Box.SIZE; box.contentX = (1 - contentEased) * box.placement.unitsWide * Box.SIZE; break;
				}
				if (f >= 1) {
					box.bgMasked = false;
					box.contentMasked = false;
				} else if (dTime < 0) {
					box.bgMasked = true;
					box.contentMasked = true;
				}
			}
		}
		
		


		protected function continueFlashIdling(dTime:Number):void {
			if (!finished || (flashBoxes.length == 0)) return;
			flashTimeRemaining -= dTime;
			if (flashTimeRemaining <= 0) {
				if (currentFlashBoxList.length <= 0) {
					for each(var box:Box in flashBoxes) currentFlashBoxList.push(box);
				}
				var index:int = int(Math.random() * currentFlashBoxList.length);
				box = currentFlashBoxList[index];
				currentFlashBoxList.splice(index, 1);
				
				if (box.invertedBlendMode) {
					if (currentFlashBoxList.length > 0) continueFlashIdling(0);
				} else {
					box.substoryFlash.flash();
					flashTimeRemaining = flashTimeTotal;
				}
			}
		}
		

		/*
		public function expandBoundsForFloating(bounds:Rectangle, camArea:Rectangle):void {
			var minX:Number = 0;
			var maxX:Number = 0;
			var minY:Number = 0;
			var maxY:Number = 0;

			var data:FloatingAnimationData = animationData as FloatingAnimationData;
			const SCALE_CHANGE:Number = 0.3;
			var len:int = contentBoxes.length;
			for each(var camFocus:Point in [camArea.topLeft, camArea.bottomRight]) {
				var midX:Number = container.x + data.bounds.x + data.bounds.width / 2;
				var midY:Number = container.y + data.bounds.y + data.bounds.height / 2;
				var xDif:Number = (camFocus.x - midX);
				var yDif:Number = (camFocus.y - midY);
				for (var i:int = 0; i < len; i++) {
					var box:Box = contentBoxes[i];
					var state:BoxState = box.endState;
					var floatedX:Number = xDif * state.zMoveFactor * SCALE_CHANGE;
					var floatedY:Number = yDif * state.zMoveFactor * SCALE_CHANGE;
					minX = Math.min(minX, floatedX);
					maxX = Math.max(maxX, floatedX);
					minY = Math.min(minY, floatedY);
					maxY = Math.max(maxY, floatedY);
				}
			}
			
			bounds.left += minX;			
			bounds.right += maxX;
			bounds.top += minY;
			bounds.bottom += maxY;
		}
		*/
		protected function moveFloatingZ(camFocus:Point):void {
			var data:FloatingAnimationData = animationData as FloatingAnimationData;
			/*
			var midX:Number = container.x + data.bounds.x + data.bounds.width / 2;
			var midY:Number = container.y + data.bounds.y + data.bounds.height / 2;
			var xDif:Number = (camFocus.x - midX);
			var yDif:Number = (camFocus.y - midY);
			const SCALE_CHANGE:Number = 0.3;
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				box.setPosition(xDif * state.zMoveFactor * SCALE_CHANGE, yDif * state.zMoveFactor * SCALE_CHANGE, Z_KEY);
			}			
			*/
			const SCALE_CHANGE:Number = 0.3;
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				var state:BoxState = box.endState;
				var normalPos:Point = box.getPositionExcluding(Z_KEY);
				var xDif:Number = (camFocus.x - (box.parent.x + normalPos.x));
				var yDif:Number = (camFocus.y - (box.parent.y + normalPos.y));
				box.setPosition(xDif * state.zMoveFactor * SCALE_CHANGE, yDif * state.zMoveFactor * SCALE_CHANGE, Z_KEY);
			}			
		}
		protected function moveImageZ(camFocus:Point):void {
			var midX:Number = container.x + animationData.bounds.x + animationData.bounds.width / 2;
			var midY:Number = container.y + animationData.bounds.y + animationData.bounds.height / 2;
			var xDif:Number = (camFocus.x - midX);
			var yDif:Number = (camFocus.y - midY);
			var len:int = contentBoxes.length;
			for (var i:int = 0; i < len; i++) {
				var box:Box = contentBoxes[i];
				if (box.imageContent) box.imageContent.scrollTo(xDif, yDif);
			}			
		}
		
		
		public function highlightBox(box:Box):HighlightController {
			var boxIndex:int = contentBoxes.indexOf(box);
			
			box.parent.setChildIndex(box, box.parent.numChildren - 1);
			
			var state:BoxState = animationData.boxEndStates[boxIndex];
			var placement:BoxPlacement = animationInfo.placements[boxIndex];
			var bounds:Rectangle = placement.getBounds(state.scale);
			
			var placedWidth:Number = bounds.width;
			var placedHeight:Number = bounds.height;
			
			var x:Number = 0;
			var y:Number = 0;
			var scale:Number = box.heightAsHeader / placedHeight;
			var pad:Number = (box.widthAsHeader / box.heightAsHeader - placedWidth / placedHeight) * placedHeight;
			var time:Number = 1000;
			
			var mainController:HighlightController;
			var c:HighlightController;
			var widthIncrease:Number;
			var i:int;
			
			switch(animationInfo.type) {
				case AnimationType.FLOATING:
					returnHighlightControllers();
					// Assuming it's going right
					x = animationData.originVector.x * parentBox.widthAsHeader / 2 + animationData.bounds.right - box.getX() + Box.SIZE * (2 / 6);
					y = -box.getY();
					mainController = applyHighlight(box, true, x, y, scale, 0, time);
					break;
					
				case AnimationType.SPROUTING:
					// Assuming it's horizontal
					widthIncrease = box.widthAsHeader - placedWidth;
					for (i = 0; i < contentBoxes.length; i++) {
						if (i == boxIndex) {
							c = mainController = applyHighlight(contentBoxes[i], true, widthIncrease / 2, y, scale, pad, time);
						} else if (i < boxIndex) {
							c = applyHighlight(contentBoxes[i], false, 0, 0, 1, 0, time);
						} else {
							c = applyHighlight(contentBoxes[i], false, widthIncrease, 0, 1, 0, time);
						}						
						c.linkMoveAndScale = true;
					}
					break;
					
				case AnimationType.SLIDING:
					//returnHighlightControllers();
					//mainController = applyHighlight(box, true, x, y, scale, pad, time);
					
					var slidingData:SlidingAnimationData = animationData as SlidingAnimationData;
					var laneWidth:Number = slidingData.totalLaneWidth;
					var row:Array = [];
					
					// Assuming it's horizontal
					widthIncrease = box.widthAsHeader - placedWidth;
					for (i = 0; i < contentBoxes.length; i++) {
						if (i == boxIndex) {
							row.push(box);
							//c = mainController = applyHighlight(contentBoxes[i], true, widthIncrease / 2, 0, scale, pad, time);
						} else {
							var s:BoxState = animationData.boxEndStates[i];
							if (s.x == state.x) {
								row.push(contentBoxes[i]);
								//c = applyHighlight(contentBoxes[i], false, widthIncrease / 2, 0, 1, pad, time);
							} else if (i < boxIndex) {
								c = applyHighlight(contentBoxes[i], false, 0, 0, 1, 0, time);
							} else {
								c = applyHighlight(contentBoxes[i], false, widthIncrease, 0, 1, 0, time);
							}
						}
						if (c) c.linkMoveAndScale = true;
					}
					y = -laneWidth / 2;
					while (row.length > 1) {
						var highest:Box;
						for (i = 0; i < row.length; i++) {
							var b:Box = row[i];
							if (b == box) continue;
							if (!highest || (b.getY() < highest.getY())) {
								highest = b;
							}
						}
						var index:int = row.indexOf(highest);
						row.splice(index, 1);
						var h:Number = highest.getHeight();
						s = animationData.boxEndStates[index];
						c = applyHighlight(highest, false, widthIncrease / 2, y + h / 2 - s.y, 1, pad, time);
						c.linkMoveAndScale = true;
						y += h;
					}
					c = mainController = applyHighlight(box, true, widthIncrease / 2, y + box.getHeight() / 2 - state.y, scale, pad, time);
					c.linkMoveAndScale = true;
					
					break;
			}
			
			return mainController;
		}
		protected function returnHighlightControllers():void {
			var controller:HighlightController = null;
			for (var i:int = highlightControllers.length - 1; i >= 0; i--) {
				var c:HighlightController = highlightControllers[i];
				if (c.highlighted) c.returnToSource();
			}
		}
		protected function applyHighlight(box:Box, highlighted:Boolean, x:Number, y:Number, scale:Number, pad:Number, time:Number):HighlightController {					
			var controller:HighlightController = null;
			for (var i:int = highlightControllers.length - 1; i >= 0; i--) {
				var c:HighlightController = highlightControllers[i];
				if (c.box == box) {
					controller = c;
					break;
				}
			}
			if (controller) {
				controller.update(highlighted, x, y, scale, pad, time);
			} else {
				controller = new HighlightController(box, highlighted, x, y, scale, pad, time);
				highlightControllers.push(controller);
			}
			return controller;
		}		
		protected function animateHighlighControllers(dTime:Number):void {
			for (var i:int = highlightControllers.length - 1; i >= 0; i--) {
				var controller:HighlightController = highlightControllers[i];
				controller.animate(dTime);
				if (controller.finished) {
					highlightControllers.splice(i, 1);
				}
			}
		}
		
		
		protected function updateParentPosition():void {
			if (!parentBox || !parentBox.parent || parentBox.ending) return;
			currentParentPosition.x = parentBox.parent.x + parentBox.getX();
			currentParentPosition.y = parentBox.parent.y + parentBox.getY();
		}
		public function alignContainer():void {
			if (!parentBox) return;
			updateParentPosition();
			container.x = currentParentPosition.x + animationData.originVector.x * parentBox.getWidth() / 2;
			container.y = currentParentPosition.y + animationData.originVector.y * parentBox.getHeight() / 2;
		}		
		public function playCameraAnimation():void {
			var x:Number = parentHighlightPosition.x + animationData.focus.x;
			var y:Number = parentHighlightPosition.y + animationData.focus.y;
			// Subtract because this is framing the header
			x -= animationData.originVector.x * parentBox.widthAsHeader / 2;
			y -= animationData.originVector.y * parentBox.heightAsHeader / 2;
			
			var vector:Point = animationData.endPoint.clone();
			var multiplier:Number = 1 / Math.max(Math.abs(vector.x), Math.abs(vector.y));
			vector.x *= multiplier;
			vector.y *= multiplier;
			
			
			var length:Number = isChapter ? 300 : 450;
			var yMultiplier:Number = ((BoxesMain.STAGE_HEIGHT + Box.SIZE) / (BoxesMain.STAGE_WIDTH + Box.SIZE));
			x = parentHighlightPosition.x + vector.x * ( -Box.SIZE + length);
			y = parentHighlightPosition.y + vector.y * ( -Box.SIZE + length * yMultiplier);
			
			camera.animateTo(x, y, animationData.focusTime, 100);			

			autoPanStart = new Point(x, y);
			x = parentHighlightPosition.x + animationData.endPoint.x - vector.x * ( -Box.SIZE + length);
			y = parentHighlightPosition.y + animationData.endPoint.y - vector.y * ( -Box.SIZE + length * yMultiplier);
			autoPanEnd = new Point(x, y);
			
		}
		
		
		

		protected function dispose():void {
			if (container.parent) container.parent.removeChild(container);
			var len:int = contentBoxes.length;
			for (var i:int = len - 1; i >= 0; i--) {
				var box:Box = contentBoxes[i];
				if (box.parent) box.parent.removeChild(box);
				box.dispose();
			}
			contentBoxes.length = 0;			
		}
		
		
		
		
		
		
		

	}

}