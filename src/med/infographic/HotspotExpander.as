package med.infographic {
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class HotspotExpander extends _HotspotExpander {
		
		static public const FULLSCREEN_TIME:Number = 0.5;
		
		public var expanded:Boolean;
		public var canToggle:Boolean;
		
		protected var fullscreenHome:Rectangle;
		protected var fullscreenImage:Bitmap;
		protected var bitmap:Bitmap;
		protected var title:String;
		protected var text:String;
		protected var imageURL:String;
		
		protected var titleMask:Shape;
		protected var textMask:Shape;
		protected var bitmapMask:Shape;
		
		protected var right:Boolean;
		protected var down:Boolean;
		
		protected var boxRadius:Number;
		protected var dockedX:Number;
		protected var extendedX:Number;
		protected var dockedY:Number;
		protected var extendedY:Number;
		protected var dockedBitmapY:Number;
		protected var extendedBitmapY:Number;
		protected var dockedTextY:Number;
		protected var extendedTextY:Number;
		protected var dockedTitleY:Number;
		protected var extendedTitleY:Number;
		protected var boxWidth:Number;
		protected var boxHeight:Number;
		protected var titleHeight:Number;
		protected var textHeight:Number;
		protected var bitmapHeight:Number;

		protected var color:uint;
		protected var colorTransform:ColorTransform;
		
		public function HotspotExpander(title:String, text:String, imageURL:String, dir:String, color:uint) {
			this.title = title;
			this.text = text;
			this.imageURL = imageURL;
			titleField.visible = false;
			textField.visible = false;
			textBG.visible = false;
			
			this.color = color;
			colorTransform = new ColorTransform(0, 0, 0, 1);
			colorTransform.color = color;

			right = dir.charAt(1) == "r";
			down = dir.charAt(0) == "d";

			boxRadius = 15;
			
			const MARGIN:Number = 15;
			const GAP_SQUEEZE:Number = 20;

			const MIN_WIDTH:Number = 130;
			const MAX_WIDTH:Number = 200;
			
			boxWidth = 0;
			boxHeight = 0;
			
			titleHeight = 0;
			if (title) {
				titleField.defaultTextFormat = TextUtils.contentHeaderFormat;
				titleField.autoSize = TextFieldAutoSize.LEFT;
				titleField.multiline = false;
				titleField.wordWrap = false;
				
				titleField.text = title;
				titleField.width; // force refresh?
				titleField.multiline = true;
				titleField.wordWrap = true;
				titleField.width = Math.min(MAX_WIDTH, titleField.width);
				titleField.width = Math.max(MIN_WIDTH, Math.min(titleField.width, titleField.textWidth + 4));
				
				titleHeight = titleField.height + MARGIN * 2 - 5;
				boxWidth = titleField.width + MARGIN * 2;
				boxHeight = titleHeight;
			}
			
			textHeight = 0;
			if (text) {
				textField.autoSize = TextFieldAutoSize.LEFT;
				textField.multiline = false;
				textField.wordWrap = false;
				
				TextUtils.fillText(textField, text, TextUtils.contentFormat, TextUtils.contentBoldFormat, false);
				textField.width; // force refresh?
				textField.multiline = true;
				textField.wordWrap = true;
				textField.width = Math.min(MAX_WIDTH, textField.width);
				textField.width = Math.max(MIN_WIDTH, Math.min(textField.width, textField.textWidth + 4));
				
				textHeight = textField.height + MARGIN * 2 - 5;
				boxWidth = Math.max(boxWidth, textField.width + MARGIN * 2);
				if (boxHeight > 0) boxHeight -= GAP_SQUEEZE;
				boxHeight += textHeight;
			}
			if (!boxWidth) boxWidth = MAX_WIDTH;
			
			if (right) {
				dockedX = boxRadius - 1;
				extendedX = boxRadius - 1;
			} else {
				dockedX = -boxRadius + 1;
				extendedX = -boxRadius - boxWidth + 1;
			}
			
			textBG.width = boxWidth;
			textBG.height = textHeight;
			textBG.transform.colorTransform = colorTransform;
			horizontalLine.transform.colorTransform = colorTransform;
			verticalLine.transform.colorTransform = colorTransform;
			
			if (imageURL) {
				var bmd:BitmapData = AssetManager.getImage(imageURL);
				bitmap = new Bitmap(bmd, "auto", true);
				bitmap.width = boxWidth;
				bitmap.scaleY = bitmap.scaleX;
				bitmapHeight = bitmap.height;
				addChild(bitmap);
				bitmap.visible = false;
				bitmap.x = extendedX;
			}

			var titleOffset:Number = titleHeight;
			if (titleHeight > 0) titleOffset -= GAP_SQUEEZE;
			if (down) {
				dockedY = -boxRadius;
				extendedY = -boxRadius;
				dockedBitmapY = dockedY + textHeight - bitmapHeight;
				extendedBitmapY = dockedY + textHeight;
				extendedTitleY = extendedY + MARGIN - 5;
				dockedTitleY = extendedTitleY - titleHeight - 2;
				extendedTextY = titleOffset + extendedY + MARGIN - 5;
				dockedTextY = titleOffset + extendedTextY + textHeight + 2;
			} else {
				dockedY = -boxRadius;
				extendedY = boxRadius - boxHeight;
				dockedBitmapY = extendedY;
				extendedBitmapY = extendedY - bitmapHeight;
				if (bitmap) {
					extendedTitleY = extendedY + MARGIN - 5;
					dockedTitleY = extendedTitleY + titleHeight + 2;
					extendedTextY = titleOffset + extendedY + MARGIN - 5;
					dockedTextY = titleOffset + extendedTextY - textHeight - 2;
				} else {
					extendedTitleY = extendedY + MARGIN - 5;
					dockedTitleY = extendedTitleY - titleHeight - 2;
					extendedTextY = titleOffset + extendedY + MARGIN - 5;
					dockedTextY = titleOffset + extendedTextY + textHeight + 2;
				}
			}
			
			

			var g:Graphics;
			if (title) {
				titleField.x = extendedX + MARGIN;
				titleField.y = extendedTitleY;

				titleMask = new Shape();
				g = titleMask.graphics;
				g.beginFill(0xFFFFFF);
				g.drawRect(titleField.x, titleField.y, titleField.width, titleField.height);
				g.endFill();
				titleMask.visible = false;
				addChild(titleMask);
				titleField.mask = titleMask;
			}
			if (text) {
				textField.x = extendedX + MARGIN;				
				textField.y = extendedTextY;				
				
				textMask = new Shape();
				g = textMask.graphics;
				g.beginFill(0xFFFFFF);
				g.drawRect(textField.x, textField.y, textField.width, textField.height);
				g.endFill();
				textMask.visible = false;
				addChild(textMask);
				textField.mask = textMask;
			}
			if (bitmap) {
				bitmapMask = new Shape();
				g = bitmapMask.graphics;
				g.beginFill(0xFFFFFF);
				g.drawRect(bitmap.x, extendedBitmapY, bitmap.width, bitmap.height);
				g.endFill();
				bitmapMask.visible = false;
				addChild(bitmapMask);
				bitmap.mask = bitmapMask;
			}
			
			
			mouseChildren = false;
			
			expanded = false;
			canToggle = true;
		}
		

		
		public function toggle():void {
			expanded = !expanded;
			canToggle = false;
			
			var t:Number = 0;
			const BUTTON_CHANGE_TIME:Number = 0.5;			
			const BUTTON_OVERLAP:Number = 0.2;
			const EXPAND_HORIZONTAL_TIME:Number = 0.3;
			const DIRECTION_DELAY:Number = 0.05;
			const EXPAND_VERTICAL_TIME:Number = 0.2;
			const EXPAND_CONTENT_TIME:Number = 0.5;

			
			
			if (expanded) {
				t = 0;
				TweenMax.to(bg, BUTTON_CHANGE_TIME, { delay:t, colorTransform:{ tint:color, tintAmount:1.0 }, ease:Quad.easeOut } );
				TweenMax.to(verticalLine, BUTTON_CHANGE_TIME, { delay:t, scaleY:0, colorTransform: { tint:0xFFFFFF, tintAmount:1.0 }, alpha:0, ease:Quad.easeOut } );
				TweenMax.to(horizontalLine, BUTTON_CHANGE_TIME, { delay:t, scaleX:1.1, scaleY:1.1, colorTransform: { tint:0xFFFFFF, tintAmount:1.0 }, ease:Quad.easeOut } );
				t += BUTTON_CHANGE_TIME - BUTTON_OVERLAP;
				
				TweenMax.fromTo(textBG, EXPAND_HORIZONTAL_TIME, { x:dockedX, width:0, height:(boxRadius * 2), visible:true }, { delay:t, x:extendedX, width:boxWidth, ease:Quad.easeOut } );				
				t += EXPAND_HORIZONTAL_TIME;
				
				if (boxHeight > 0) {
					TweenMax.to(textBG, EXPAND_VERTICAL_TIME, { delay:t, y:extendedY, height:boxHeight, ease:Quad.easeIn } );
					t += EXPAND_VERTICAL_TIME + DIRECTION_DELAY;
				}
				
				if (bitmap) {
					TweenMax.to(bitmap, 0, { delay:t, visible:true } );
					TweenMax.fromTo(bitmap, EXPAND_CONTENT_TIME, { y:dockedBitmapY }, { delay:t, y:extendedBitmapY, ease:Quad.easeOut } );
				}
				if (text) TweenMax.fromTo(textField, EXPAND_CONTENT_TIME, { y:dockedTextY, visible:true }, { delay:t, y:extendedTextY, ease:Quad.easeOut } );				
				if (title) TweenMax.fromTo(titleField, EXPAND_CONTENT_TIME, { y:dockedTitleY, visible:true }, { delay:t, y:extendedTitleY, ease:Quad.easeOut } );				

				// Dummy to trigger callback
				TweenMax.to(textBG, EXPAND_CONTENT_TIME, { delay:t, onComplete:onExpandingFinished } );								
				
			} else {				
				t = 0;
				
				if (bitmap) TweenMax.to(bitmap, EXPAND_CONTENT_TIME, { delay:t,  y:dockedBitmapY, visible:false, ease:Quad.easeIn } );
				if (text) TweenMax.to(textField, EXPAND_CONTENT_TIME, { delay:t, y:dockedTextY, visible:false, ease:Quad.easeIn } );				
				if (title) TweenMax.to(titleField, EXPAND_CONTENT_TIME, { delay:t, y:dockedTitleY, visible:false, ease:Quad.easeIn } );				
				t += EXPAND_CONTENT_TIME;

				if (boxHeight > 0) {
					TweenMax.to(textBG, EXPAND_VERTICAL_TIME, { delay:t, y:dockedY, height:(boxRadius * 2), ease:Quad.easeOut } );
					t += EXPAND_VERTICAL_TIME + DIRECTION_DELAY;
				}

				TweenMax.to(textBG, EXPAND_HORIZONTAL_TIME, { delay:t, x:dockedX, width:0, ease:Quad.easeIn } );				
				t += EXPAND_HORIZONTAL_TIME - BUTTON_OVERLAP;
				
				TweenMax.to(bg, BUTTON_CHANGE_TIME, { delay:t, colorTransform:{ tint:color, tintAmount:1 }, ease:Quad.easeOut } );
				TweenMax.to(verticalLine, BUTTON_CHANGE_TIME, {delay:t, scaleY:1, colorTransform: { tint:0xFFFFFF, tintAmount:1 }, alpha:1, ease:Quad.easeOut } );
				TweenMax.to(horizontalLine, BUTTON_CHANGE_TIME, { delay:t, scaleX:1, scaleY:1, colorTransform: { tint:0xFFFFFF, tintAmount:1 }, ease:Quad.easeOut } );				
				
				// Dummy to trigger callback
				TweenMax.to(textBG, BUTTON_CHANGE_TIME, { delay:t, onComplete:onExpandingFinished } );								
			}
		}
		
		protected function onExpandingFinished():void {
			canToggle = true;
		}
		

		public function get mouseWithinImage():Boolean {
			if (!bitmap) return false;
			return (bitmap.getBounds(this).contains(mouseX, mouseY));
		}
		
		public function showFullscreenImage():void {
			if (!bitmap || fullscreenImage) return;
			var bmd:BitmapData = bitmap.bitmapData;
			fullscreenImage = new Bitmap(bmd, "auto", true);
			var startRect:Rectangle = bitmap.getBounds(stage);
			/*
			var W:Number = Main.WIDTH * Main.SCALE;
			var H:Number = Main.HEIGHT* Main.SCALE;

			public static const WIDTH:Number = 2857;
			public static const HEIGHT:Number = 1607;
			public static const SCALE:Number = 0.4;
			*/
			var W:Number = 2857 * 0.4;
			var H:Number = 1607 * 0.4;
			
			var scale:Number = Math.max(W / bmd.width, H / bmd.height);
			var endRect:Rectangle = new Rectangle( -(bmd.width * scale - W) / 2, -(bmd.height * scale - H) / 2, bmd.width * scale, bmd.height * scale);
			
			fullscreenHome = startRect;
			stage.addChild(fullscreenImage);
			
			TweenMax.fromTo(fullscreenImage, FULLSCREEN_TIME, { x:fullscreenHome.x, y:fullscreenHome.y, width:fullscreenHome.width, height:fullscreenHome.height },  { x:endRect.x, y:endRect.y, width:endRect.width, height:endRect.height } );
			addEventListener(Event.ENTER_FRAME, handleFullscreenMouseDelay);
		}
		
		protected function handleFullscreenMouseDelay(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, handleFullscreenMouseDelay);
			if (fullscreenImage.stage) {
				fullscreenImage.stage.addEventListener(MouseEvent.MOUSE_DOWN, handleRemoveFullscreenImage);
			}
		}
		
		protected function handleRemoveFullscreenImage(event:MouseEvent):void {
			fullscreenImage.stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleRemoveFullscreenImage);
			TweenMax.to(fullscreenImage, FULLSCREEN_TIME, { x:fullscreenHome.x, y:fullscreenHome.y, width:fullscreenHome.width, height:fullscreenHome.height, onComplete:onFullScreenShrunk } );
		}
	
		protected function onFullScreenShrunk():void {
			if (fullscreenImage) {
				if (fullscreenImage.parent) fullscreenImage.parent.removeChild(fullscreenImage);
				fullscreenImage = null;
				fullscreenHome = null;
			}
		}
		
	}

}