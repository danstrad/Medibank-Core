package med.display {
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import med.animation.AnimationAction;
	import med.animation.BoxState;
	import med.animation.HomeAnimationController;
	import med.story.BoxPlacement;
	import med.story.ContentInfo;

	public class Box extends Sprite {
		
		static public const SIZE:Number = 100;
		
		protected var w:Number;
		protected var h:Number;
		
		public var widthAsHeader:Number;
		public var heightAsHeader:Number;
				
		protected var bg:Sprite;
		protected var bgMask:Sprite;
		protected var contentMask:Sprite;
		protected var content:Sprite;
		
		public var textContent:TextContent;
		public var videoContent:VideoContent;
		public var imageContent:ImageContent;
		public var substoryFlash:SubstoryFlash;
		
		public var contentInfo:ContentInfo;
		public var placement:BoxPlacement;

		public var color:uint;
		protected var _inverted:Boolean;

		public var clickEnabled:Boolean;
		
		public var endState:BoxState;
		public var home:HomeAnimationController;
		
		public var ending:Boolean;
				
		public function set contentX(value:Number):void { content.x = value; }
		public function set contentY(value:Number):void { content.y = value; }
		public function set bgX(value:Number):void { bg.x = value; }
		public function set bgY(value:Number):void { bg.y = value; }
		public function set bgColorTransform(ct:ColorTransform):void { bg.transform.colorTransform = ct; }
		//public function get bgAlpha():Number { return bg.alpha; }
		//public function set bgAlpha(alpha:Number):void { bg.alpha = alpha; }
		public function set contentAlpha(alpha:Number):void { content.alpha = alpha; }
		public function set bgMasked(value:Boolean):void { if (value) bg.mask = bgMask; else bg.mask = null; }
		public function get bgMasked():Boolean { return (bg.mask != null); }
		public function set contentMasked(value:Boolean):void { if (value) content.mask = contentMask else content.mask = null; }
		public function get contentMasked():Boolean { return (content.mask != null); }
		public function set contentVisible(value:Boolean):void { content.visible = value; }
		public function get contentVisible():Boolean { return content.visible; }
		public function get invertedBlendMode():Boolean { return _inverted; }
		public function set invertedBlendMode(value:Boolean):void {
			if (value == _inverted) return;
			_inverted = value;
			if (_inverted) {
				if (textContent) textContent.blendMode = BlendMode.ERASE;
				blendMode = BlendMode.LAYER;
				updateCacheAsBitmap();
			} else {
				if (textContent) textContent.blendMode = BlendMode.NORMAL;
				blendMode = BlendMode.NORMAL;
				updateCacheAsBitmap();
			}
		}
		protected function updateCacheAsBitmap():void {
			content.cacheAsBitmap = !_inverted && !videoContent && BoxesMain.CACHE_AND_SNAP;			
		}
		
		override public function get x():Number { trace("Do not access box x/y directly"); return super.x; }
		override public function set x(value:Number):void { trace("Do not set box x/y directly"); super.x = value; }
		override public function get y():Number { trace("Do not access box x/y directly"); return super.y; }
		override public function set y(value:Number):void { trace("Do not set box x/y directly"); super.y = value; }
		override public function get scaleX():Number { trace("Do not access box scaleX/scaleY directly"); return super.scaleX; }
		override public function set scaleX(value:Number):void { trace("Do not set box scaleX/scaleY directly"); super.scaleX = value; }
		override public function get scaleY():Number { trace("Do not access box scaleX/scaleY directly"); return super.scaleY; }
		override public function set scaleY(value:Number):void { trace("Do not set box scaleX/scaleY directly"); super.scaleY = value; }

		public function getWidth():Number { return w * super.scaleX; }
		public function getHeight():Number { return h * super.scaleY; }
		
		public function getX():Number { return super.x; }
		public function getY():Number { return super.y; }
		protected var positions:Dictionary;
		public function setPosition(x:Number, y:Number, key:String):void {
			var found:Boolean = false;
			var pos:Pos = positions[key];
			if (pos) {
				pos.x = x;
				pos.y = y;
			} else {
				positions[key] = new Pos(x, y, key);
			}
			updatePosition();
		}
		protected function updatePosition():void {
			var x:Number = 0;
			var y:Number = 0;
			for each(var pos:Pos in positions) {
				x += pos.x;
				y += pos.y;
			}
			super.x = x;
			super.y = y;
		}
		
		public function getScale():Number { return super.scaleX; }
		protected var scales:Dictionary;
		public function setScale(value:Number, key:String):void {
			var found:Boolean = false;
			var scale:Scale = scales[key];
			if (scale) {
				scale.scale = value;
			} else {
				scales[key] = new Scale(value, key);
			}
			updateScale();
		}
		protected function updateScale():void {
			var value:Number = 1;
			for each(var scale:Scale in scales) {
				value *= scale.scale;
			}
			super.scaleX = value;
			super.scaleY = value;
		}
		protected var padding:Number;
		
		
		

		public function Box(color:uint) {
			this.color = color;
			
			w = SIZE;
			h = SIZE;			

			positions = new Dictionary();
			scales = new Dictionary();
			padding = 0;
			
			mouseChildren = false;
			
			addChild(bg = createBlock(color));
			addChild(bgMask = createBlock(0xFFFFFF));
			addChild(contentMask = createBlock(0xFFFFFF));
			
			clickEnabled = true;
			
			contentMask.visible = false;
			bgMask.visible = false;
			bg.visible = false;
			content = new Sprite();
			addChild(content);
			
			bg.cacheAsBitmap = BoxesMain.CACHE_AND_SNAP;
			updateCacheAsBitmap();
		}
		
		public function animate(dTime:Number):void {
			if (textContent) textContent.animate(dTime);
			if (videoContent) videoContent.animate(dTime);
			if (substoryFlash) substoryFlash.animate(dTime);
		}

		public function showContentInfo(contentInfo:ContentInfo, placement:BoxPlacement):void {
			this.contentInfo = contentInfo;
			this.placement = placement;
			
			w = SIZE * placement.unitsWide;
			h = SIZE * placement.unitsHigh;

			// fit to scale
			if (placement.unitsWide != 1) bg.scaleX = bgMask.scaleX = contentMask.scaleX = placement.unitsWide;
			if (placement.unitsHigh != 1) bg.scaleY = bgMask.scaleY = contentMask.scaleY = placement.unitsHigh;
			
			
			var addFlash:Boolean = false;
			
			if (placement.inverted) {
				bg.alpha = 1;
				content.blendMode = BlendMode.ERASE;
				blendMode = BlendMode.LAYER;
			}
			
			if (contentInfo.imageURL) {
				showImage(contentInfo.imageURL, w, h, contentInfo.imageScrollMargin);
			}
			if (contentInfo.videoURL) {
				showVideo(contentInfo.videoURL, w, h);
			}
			if (contentInfo.text) {
				showText(contentInfo.text, w, h, contentInfo.textType, contentInfo.textScale, contentInfo.subtext, contentInfo.subtextScale);
			}
			if (contentInfo.linkedStory) {
				addFlash = true;
			}
			if (contentInfo.linkedInfographic) {
				addFlash = true;
			}
			if (contentInfo.action == AnimationAction.HOME) {
				addFlash = true;
			}
			if (addFlash) {
				substoryFlash = new SubstoryFlash();
				substoryFlash.width = w;
				substoryFlash.height = h;
				addChild(substoryFlash);
			}
		}
		
		public function showText(text:String, width:Number, height:Number, textType:String, textScale:Number = 1, subtext:String = "", subtextScale:Number = 1):void {
			textContent = new TextContent(text, textType, textScale, subtext, subtextScale, width - 2 * TextContent.MARGIN, height - 2 * TextContent.MARGIN);
			addChild(textContent);
			content.addChild(textContent);
			bg.visible = true;
		}
		
		public function showImage(imageURL:String, width:Number, height:Number, scrollMargin:Number):void {
			imageContent = new ImageContent(AssetManager.getImage(imageURL), width, height, scrollMargin);
			content.addChild(imageContent);
			bg.visible = true;
			bg.alpha = 0.2;
		}		
		
		public function showVideo(videoURL:String, width:Number, height:Number):void {
			bg.scaleX = bgMask.scaleX = contentMask.scaleX = width / Box.SIZE;
			bg.scaleY = bgMask.scaleY = contentMask.scaleY = height / Box.SIZE;
			bg.visible = true;
			bg.alpha = 0.2;
			
			videoContent = new VideoContent();
			videoContent.showVideo(videoURL, width, height);
			content.addChild(videoContent);
			
			updateCacheAsBitmap();
		}
		
		public function stopFlashing():void {
			if (substoryFlash) substoryFlash.visible = false;
		}
		

		
		public function dispose():void {
			//if (textContent) textContent.dispose();
			if (videoContent) videoContent.dispose();
		}
		
		public function setPadding(value:Number):void {
			if (Math.abs(value) < 1) value = 0;
			if (value == padding) return;
			padding = value;
			bg.width = placement.unitsWide * SIZE + padding;
			if (substoryFlash) substoryFlash.width = bg.width;
			if (imageContent) imageContent.setPadding(padding);
			if (textContent) textContent.x = -padding / 2;
		}
		
		public function setColor(color:Number):void {
			this.color = color;
			if (!bg) return;
			var g:Graphics = bg.graphics;
			g.clear();
			g.beginFill(color);
			g.drawRect( -Box.SIZE / 2, -Box.SIZE / 2, Box.SIZE, Box.SIZE);
			g.endFill();
		}
		
		
		protected static function createBlock(color:uint):Sprite{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(color);
			s.graphics.drawRect( -Box.SIZE / 2, -Box.SIZE / 2, Box.SIZE, Box.SIZE);
			s.graphics.endFill();
			return s;
		}
		
		
		
		
	}

}

class Pos {
	public var x:Number;
	public var y:Number;
	public var key:String;
	public function Pos(x:Number, y:Number, key:String) {
		this.x = x;
		this.y = y;
		this.key = key;		
	}
}
class Scale {
	public var scale:Number;
	public var key:String;
	public function Scale(scale:Number, key:String) {
		this.scale = scale;
		this.key = key;		
	}
}