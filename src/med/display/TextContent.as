package med.display {
	import adobe.utils.CustomActions;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextContent extends _TextContent {
		
		protected static const TEXT_SCALE:Number = 1;// 0.4;
		protected static const NATURAL_SIZE:Number = 86;
		public static const MARGIN:Number = ((100 - 86) / 2) * TEXT_SCALE;
		//static public const MARGIN:Number = 7;
		//static public const WIDTH:Number = 86;
		//static public const HEIGHT:Number = 86;

		public static const TYPE_CHAPTER_HEADER:String = "Chapter Header";
		static public const TYPE_STORY_HEADER:String = "Story Header";
		public static const TYPE_QUOTE:String = "Quote";
		public static const TYPE_CONTENT:String = "Content";
		public static const TYPE_LABEL:String = "Label";
		public static const TYPE_STATS:String = "Stats";
		public static const TYPE_SPLASH:String = "Splash";
		

		
		protected static const MOMENTUM_FALLOFF:Number = 0.4;
		protected static const INITIAL_WAIT:Number = 5000;
		protected static const TOUCH_WAIT:Number = 2000;
		protected static const END_WAIT:Number = 3000;
		protected static const AUTO_SCROLL:Number = 3;
		
		protected var min:Number;
		protected var max:Number;
		protected var dragY:Number;
		protected var mouseInteractor:DisplayObjectContainer;
		protected var momentum:Number;
		protected var dragging:Boolean;
		protected var autoWait:Number;
		protected var autoIncrease:Boolean;
		protected var scrollY:Number;
		
		protected var scrollBar:Shape;
		
		public function get isScroller():Boolean { return (scrollBar != null); }

		public function TextContent(text:String, textType:String, textScale:Number, subtext:String, subtextScale:Number, width:Number, height:Number) {
			
			textMask.visible = false;
			subtextField.visible = false;
			max = 0;
			
			switch(textType) {
				case TYPE_LABEL:
				case TYPE_STATS:
					textField.autoSize = TextFieldAutoSize.CENTER;
					break;
				default:
					textField.autoSize = TextFieldAutoSize.LEFT;
					break;
			}

			text = TextUtils.safeText(text);

			if (textType == TYPE_CONTENT) {
				
				TextUtils.fillText(textField, text, TextUtils.contentFormat, TextUtils.contentBoldFormat);
				TextUtils.parseTags(textField, false);
				
				textField.width = width;
				textField.height = height;
				textField.x = Math.round(-textField.width / 2);
				textField.y = Math.round(-height / 2);

				setupScrolling(width, height);
				
			} else if (textType == TYPE_STATS) {
				
				TextUtils.fillText(textField, text, TextUtils.contentFormat, TextUtils.statBoldFormat);
				textField.width = width;
				textField.height = height;
				scaleToFit(width, height, textScale);
				
				textField.x = Math.round(-textField.width / 2);
				textField.y = Math.round(-height / 2);

			} else {
				switch(textType) {
					case TYPE_CHAPTER_HEADER: textField.defaultTextFormat = TextUtils.chapterHeaderFormat; break;
					default:
					case TYPE_STORY_HEADER: textField.defaultTextFormat = TextUtils.storyHeaderFormat; break;
					case TYPE_QUOTE: textField.defaultTextFormat = TextUtils.quoteFormat; break;
					case TYPE_LABEL: textField.defaultTextFormat = TextUtils.labelFormat; break;
					case TYPE_SPLASH: textField.defaultTextFormat = TextUtils.splashFormat; break;
				}
								
				textField.text = text;				
				TextUtils.parseTags(textField, true);
				scaleToFit(width, height, textScale);
				
				switch(textType) {
					case TYPE_LABEL:
					case TYPE_SPLASH:
						textField.x = -textField.width / 2;
						textField.y = -textField.height / 2 - 2 * TEXT_SCALE;
						break;
					case TYPE_QUOTE:
					case TYPE_STORY_HEADER:
						//scale = scaleToFit(scale, width, height);
						textField.x = Math.round(-width / 2);
						textField.y = -height / 2 - 4 * TEXT_SCALE;
						break;
					default:
						textField.x = Math.round(-width / 2);
						textField.y = -height / 2 - 4 * TEXT_SCALE;
						break;
				}
				
				if (subtext) {
					subtextField.autoSize = TextFieldAutoSize.LEFT;
					subtextField.visible = true;
					subtextField.defaultTextFormat = TextUtils.contentFormat;
					subtextField.text = subtext;
					subtextField.scaleX = subtextField.scaleY = Math.min(width, height) / NATURAL_SIZE * subtextScale;
					subtextField.x = textField.x;
					subtextField.y = 0;
					subtextField.width = textField.width / subtextField.scaleX;
					subtextField.height = height / 2;
				}
			}
			
		}
		
		protected function setupScrolling(width:Number, height:Number):void {
			if (textField.height > height) {
				textField.cacheAsBitmap = BoxesMain.CACHE_AND_SNAP;

				textField.width -= 10;
				
				scrollY = textField.y;
				min = textField.y - (textField.height - height);
				max = textField.y;
				momentum = 0;
				autoIncrease = false;
				textMask.width = textField.width;
				textMask.height = height;
				textMask.x = textField.x +  textField.width / 2;
				textField.mask = textMask;
				
				autoWait = INITIAL_WAIT;
				
				scrollBar = new Shape();
				scrollBar.graphics.beginFill(0xFFFFFF, 0.3);
				scrollBar.graphics.drawRect(0, 0, 2, height * (height / textField.height));
				scrollBar.graphics.endFill();
				addChild(scrollBar);
				scrollBar.x = width / 2 - 2;
				
				scrollTo(0);
				
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}
		}
		
		
		protected function handleAddedToStage(event:Event):void {
			for (mouseInteractor = this; mouseInteractor != null; mouseInteractor = mouseInteractor.parent) {
				if (!mouseInteractor.mouseChildren) {
					break;
				} else if (mouseInteractor == stage) {
					mouseInteractor = this;
					break;
				}
			}
			if (!mouseInteractor) return;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true);
			mouseInteractor.addEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false, 0, true);			
		}
		protected function handleRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			mouseInteractor.removeEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false);			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}

		
		protected function handleBeginDrag(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp, false, 0, true);
			dragY = scrollY - mouseInteractor.mouseY;
			dragging = true;
		}
		protected function handleUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}
		protected function handleMove(event:MouseEvent):void {
			var target:Number = mouseInteractor.mouseY + dragY;
			var current:Number = scrollY;
			scrollTo(target);
			momentum += (target - current);
			autoWait = TOUCH_WAIT;
			if (target > current) autoIncrease = true;
			if (target < current) autoIncrease = false;
		}
		
		public function animate(dTime:Number):void {
			if (max == 0) return;
			momentum *= (1 - MOMENTUM_FALLOFF);
			if (!dragging) {
				if (momentum < 0) {
					scrollTo(scrollY + momentum);
					if (momentum > -1) momentum = 0;				
					if (scrollY == min) {
						momentum = 0;
						autoIncrease = true;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else if (momentum > 0) {
					scrollTo(scrollY + momentum);
					if (momentum < 1) momentum = 0;				
					if (scrollY == max) {
						momentum = 0;
						autoIncrease = false;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else {
					/* disable autoscroll
					if (autoWait > 0) {
						autoWait = Math.max(0, autoWait - dTime);
					} else {
						var scroll:Number = dTime / 1000 * AUTO_SCROLL;
						if (autoIncrease) {
							if (scrollY + scroll >= max) {
								scrollTo(max);
								autoIncrease = false;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY + scroll);
							}
						} else {
							if (scrollY - scroll <= min) {
								scrollTo(min);
								autoIncrease = true;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY - scroll);
							}
						}
					}
					*/
				}
			}
		}
		
		protected function scrollTo(y:Number):void {
			textField.y = scrollY = Math.max(min, Math.min(max, y));
			scrollBar.y = textMask.y - textMask.height / 2 + (textMask.height - scrollBar.height) * ((scrollY - max) / (min - max));
		}
		
		
		protected function scaleToFit(width:Number, height:Number, textScale:Number):void {
			var scale:Number = Math.min(width, height) / NATURAL_SIZE * textScale;
			textField.scaleX = textField.scaleY = scale;
			textField.width = width / scale;
			textField.height = height / scale;
			
			while (textField.height > height) {
				scale -= 0.05;
				textField.scaleX = textField.scaleY = scale;
				textField.width = width / textField.scaleX;
				textField.height = height / textField.scaleY;
			}
		}
		
				

	}

}