package med.animation {
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import med.display.Box;
	import med.display.HomeBox;
	import med.display.TextContent;
	import med.story.Chapter;
	import med.story.ContentInfo;
	import med.story.HomeInfo;
	import med.story.Story;
	import med.story.StorySet;

	public class HomeAnimationController {

		static public const ZERO_POINT:Point = new Point(0, 0);
		protected static const END_TIME:Number = 700;
		
		static public const ANIM_KEY:String = "home anim";

		protected var container:Sprite;

		public var boxes:Vector.<HomeBox>;
		public var data:HomeAnimationData;
		protected var layout:BoxLayout;

		protected var finished:Boolean; // Finished initial animation
		public var ending:Boolean;
		public var ended:Boolean;
		
		public var currentBounds:Rectangle;
				
		protected static const TIME:Number = 700;
		protected var waitTimeRemaining:Number;
		protected var endTimeRemaining:Number;
		protected var timeRemaining:Number;
		protected var fadeTimeRemaining:Number;
		protected var fadeTimeTotal:Number;
		public var parentBox:Box;
		public var currentParentPosition:Point;
		public var parentHighlightPosition:Point;
		public var offsetFromParent:Point;
		
		public function get sourceX():Number { return container.x; }
		public function get sourceY():Number { return container.y; }
		
		public function getAnimationTypeIndex():int { return data.baseChapterID; }
		
		public function HomeAnimationController(parentBox:Box, parentHighlightPosition:Point, offsetFromParent:Point, container:Sprite, data:HomeAnimationData) {
			this.parentBox = parentBox;
			this.offsetFromParent = offsetFromParent;
			this.container = container;
			this.data = data;
			this.parentHighlightPosition = parentHighlightPosition;
			
			currentParentPosition = new Point(0, 0);
			
			boxes = new Vector.<HomeBox>();
			
			var homeBox:HomeBox;
			
			// Generate this from data
			for each(var info:HomeInfo in data.homeInfos) {
				homeBox = new HomeBox(StorySet.getChapterById(info.chapterID), info.chapterID);
				homeBox.home = this;
				homeBox.defaultColorTransform = info.defaultColorTransform;
				
				homeBox.widthAsHeader = Box.SIZE * 2;
				homeBox.heightAsHeader = Box.SIZE * 2;
				
				if (info.text) homeBox.showText(info.text, Box.SIZE * info.width, Box.SIZE * info.height, TextContent.TYPE_CHAPTER_HEADER);
				else if (info.videoURL) homeBox.showVideo(info.videoURL, Box.SIZE * info.width, Box.SIZE * info.height);
				container.addChild(homeBox);
				boxes.push(homeBox);
			}
			
			alignContainer();
			
			waitTimeRemaining = 0;
			timeRemaining = TIME;
			
		}
		
		public function dispose():void {
			if (container.parent) container.parent.removeChild(container);
			var len:int = boxes.length;
			for (var i:int = len - 1; i >= 0; i--) {
				var box:Box = boxes[i];
				if (box.parent) box.parent.removeChild(box);
				box.dispose();
			}
			boxes.length = 0;			
		}		
		
		public function transitionTo(layout:BoxLayout):void {
			if (!layout) return;
			this.layout = layout;
			
			currentBounds = layout.bounds;

			waitTimeRemaining = 0;
			timeRemaining = TIME;
			ended = false;
			ending = false;
			finished = false;

			for each(var box:HomeBox in boxes) {
				var state:BoxState = layout.states[box.id];
				box.start.x = box.getX();
				box.start.y = box.getY();
				box.destination.x = state.x;
				box.destination.y = state.y;
				box.startScale = box.scale;
				box.endScale = state.scale;
				//if (state.inverted) box.endScale *= 2;
			}
		}
		
		public function continueAnimation(dTime:Number):void {
			for each(var homeBox:HomeBox in boxes) {
				homeBox.animate(dTime);
			}

			if (waitTimeRemaining > 0) {
				if (waitTimeRemaining > dTime) {
					waitTimeRemaining -= dTime;
					return;
				} else {
					dTime -= waitTimeRemaining;
					waitTimeRemaining = 0;
				}
			}
			
			if (fadeTimeRemaining > 0) {
				fadeTimeRemaining = Math.max(0, fadeTimeRemaining - dTime);
				container.alpha = 1 - fadeTimeRemaining / fadeTimeTotal;
			}
			
			if (!finished) {
			
				timeRemaining -= dTime;
				if (timeRemaining <= 0) {
					completeInstantly();
					return;
				}
				

				var f:Number = 1 - timeRemaining / TIME;
				
				var easedShrink:Number = Utils.easeOut(Utils.f(0, 0.5, f));
				var easedGrow:Number = Utils.easeOut(Utils.f(0.5, 1, f));
				var easedMove:Number = Utils.easeOut(Utils.f(0.2, 0.8, f));
				var easedColor:Number = Utils.easeOut(Utils.f(0.3, 0.6, f));
				
				for each(var box:HomeBox in boxes) {
					var state:BoxState = layout.states[box.id];
					box.setPosition(box.start.x + (box.destination.x - box.start.x) * easedMove, box.start.y + (box.destination.y - box.start.y) * easedMove, ANIM_KEY);
					var scaleF:Number = (box.endScale > box.startScale) ? easedGrow : easedShrink;
					box.scale = (box.startScale + (box.endScale - box.startScale) * scaleF);
					updateHeaderBoxScale(box, state, easedColor);
				}
			}
			
			alignContainer();
			if (!currentParentPosition) {
				var target:Point = getTargetPosition();
				var move:Point = target.clone();
				move.x -= container.x;
				move.y -= container.y;
				if (move.length < 1) {
					container.x = target.x;
					container.y = target.y;
				} else {
					var MOVE_FACTOR:Number = 300;
					move.normalize(move.length * dTime / MOVE_FACTOR);
					container.x += move.x;
					container.y += move.y;
				}
			}
			
			if (ending) {
				endTimeRemaining -= dTime;
				if (endTimeRemaining <= 0) {
					dispose();
					ended = true;
				} else {
					container.alpha = endTimeRemaining / END_TIME;
				}
			}			
		}
		
		public function completeInstantly():void {
			finished = true;
			for each(var box:HomeBox in boxes) {
				var state:BoxState = layout.states[box.id];
				box.setPosition(state.x, state.y, ANIM_KEY);
				
				box.inverted = state.inverted;
				
				box.scale = box.endScale;
				updateHeaderBoxScale(box, state, 1);
			}
		}
		
		public function fadeIn(time:Number):void {
			fadeTimeRemaining = time;
			fadeTimeTotal = time;
			container.alpha = 0;
		}
		

		public function wait(time:Number):void {
			waitTimeRemaining += time;
		}
		
		public function end():void {
			ending = true;
			endTimeRemaining = END_TIME;
			
			for each(var box:Box in boxes) box.ending = true;
		}
		
		
		protected function updateParentPosition():void {
			if (parentBox && parentBox.parent && !parentBox.ending) {
				currentParentPosition.x = parentBox.parent.x + parentBox.getX();
				currentParentPosition.y = parentBox.parent.y + parentBox.getY();
			} else {
				currentParentPosition = null;
			}
		}
		public function alignContainer():void {
			updateParentPosition();
			if (currentParentPosition) {
				container.x = currentParentPosition.x + offsetFromParent.x;
				container.y = currentParentPosition.y + offsetFromParent.y;
			}
		}		
		public function getTargetPosition():Point {
			return parentHighlightPosition.add(offsetFromParent);
		}
		
		
		protected function updateHeaderBoxScale(box:HomeBox, state:BoxState, eased:Number):void {
			box.setScale(box.scale, "Home Anim");
			
			if (box.videoContent) return;
			
			var highlightF:Number;
			
			if (state.inverted) {
				if (box.inverted) highlightF = 1;
				else highlightF = eased;					
			} else {
				if (box.inverted) highlightF = 1 -  eased;
				else highlightF = 0;					
			}
			var r:Number = highlightF + box.defaultColorTransform.redMultiplier * (1 - highlightF);
			var g:Number = highlightF + box.defaultColorTransform.greenMultiplier * (1 - highlightF);
			var b:Number = highlightF + box.defaultColorTransform.blueMultiplier * (1 - highlightF);
			box.bgColorTransform = new ColorTransform(r, g, b);
			if (highlightF > 0.5) box.contentAlpha = 1;
			else box.contentAlpha = (1 - highlightF);
			//box.bgAlpha = 0.2 + 0.8 * highlightF;
			box.invertedBlendMode = (highlightF > 0.5);
		}
		
		
		
	}

}