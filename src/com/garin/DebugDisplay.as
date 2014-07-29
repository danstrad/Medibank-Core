package com.garin {
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.adobe.images.PNGEncoder;
	

	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class DebugDisplay extends Sprite {

		private var tfield:TextField;
		private var refreshTimer:Timer;
		private var frameCount:int;
		private var dragging:Boolean = false;
		private var mainLoaderInfo:LoaderInfo;
		
		
		public function DebugDisplay(loaderInfo:LoaderInfo = null):void {
			this.mainLoaderInfo = loaderInfo;
			
			this.mouseEnabled = true;
			this.mouseChildren = false;
			
			var displayBounds:Rectangle = new Rectangle(0, 0, 60, 45);
			
			this.graphics.beginFill(0x000000, 0.5);
			this.graphics.drawRect(displayBounds.x, displayBounds.y, displayBounds.width, displayBounds.height);
			this.graphics.endFill();
			
			this.graphics.lineStyle(1, 0xffffff, 0.5);
			this.graphics.drawRect(displayBounds.x, displayBounds.y, displayBounds.width, displayBounds.height);
						
			
			tfield = new TextField();
			tfield.x = 5;
			tfield.y = 4;
			tfield.autoSize = TextFieldAutoSize.LEFT;
			tfield.textColor = 0xffffff;
			tfield.filters = [new GlowFilter(0x000000)];
			addChild(tfield);
			
			// (new) init debug log display
			debugLogSprite = new Sprite();
			debugLogSprite.graphics.beginFill(0x000000, 0.5);
			debugLogSprite.graphics.drawRect(0, 0, 800, 600); 
			debugLogSprite.graphics.endFill();
			addChild(debugLogSprite);

			debugLogField = new TextField();
			debugLogField.x = 100;
			debugLogField.y = 10;
			debugLogField.autoSize = TextFieldAutoSize.LEFT;
			debugLogField.textColor = 0xffffff;
			debugLogField.filters = [new GlowFilter(0x000000)];
			debugLogSprite.addChild(debugLogField);
						
			debugLogSprite.visible = false;
						
			
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClick);
			this.doubleClickEnabled = true;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			this.buttonMode = true;
		}
		

		
		
		private function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);			
		}
		
		
		private var debugLogSprite:Sprite;
		private var debugLogField:TextField;
		
		
		private function keyDown(e:KeyboardEvent):void {
			//trace("DebugDisplay.keyDown");
			
			if (e.keyCode == Keyboard.F12) {
				//trace("DebugDisplay: Taking Screenshot");
				takeScreenShot();
			
			} else if (e.keyCode == Keyboard.F11) {
				// toggle visibility
				this.visible = !this.visible;
			
			/*	
			} else if (e.keyCode == Keyboard.F9) {
				// toggle debug log
				if (debugLogSprite.visible) {
					debugLogSprite.visible = false;
				} else {
					debugLogSprite.visible = true;
					debugLogField.text = Debugging.getDebugLog();		
				}
			*/				
			
			}
			
		}
		
		
		public function cleanup():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClick);	
			removeEventListener(Event.ENTER_FRAME, onFrame);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);		
			mainLoaderInfo = null;
		}
		
		public function init():void {
			frameCount = 0;
			addEventListener(Event.ENTER_FRAME, onFrame);
			refreshTimer = new Timer(1000);
			refreshTimer.addEventListener(TimerEvent.TIMER, refreshTimerTick);
			refreshTimer.start();			
		}
		
		private function onFrame(e:Event):void {
			frameCount++;
		}
		
		private function refreshTimerTick(e:TimerEvent):void {
			var fpsStr:String = frameCount + " fps";
			var memoryStr:String = Number(System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + " Mb";
			tfield.text = fpsStr + "\n" + memoryStr;
			if (parent != null) parent.addChild(this);	// bring to top
			frameCount = 0;
		}
		
		private function mouseDown(e:MouseEvent):void {
			if (!dragging) {
				dragging = true;
				startDrag(false);
			}
		}
 
		private function mouseUp(e:MouseEvent):void {
			if (dragging) this.stopDrag();
			dragging = false;
		}		
	
		
		private function mouseDoubleClick(e:MouseEvent):void {
			//cleanup();
			//parent.removeChild(this);
			this.visible = false;
		}
		
		
		
		private function takeScreenShot(e:Event = null):void {
			if (!stage)	return;
			
			var wasVisible:Boolean = this.visible;
			
			var data:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			this.visible = false;
			data.draw(stage, null, null);
			
			this.visible = wasVisible;
			
			var ba:ByteArray = PNGEncoder.encode(data);
			
			var fileRef:FileReference = new FileReference();
			//fileRef.addEventListener(Event.SELECT, onSaveSelect);
			
			var now:Date = new Date();
			
			var timeString:String = ""+now.getHours()+""+now.getMinutes()+""+now.getSeconds();
			var dateString:String = "" + now.getDate() + "" + now.getMonth(); // + "" + now.getFullYear();
			
			var swfString:String = "";
			
			if (mainLoaderInfo) {
				var url:String = loaderInfo.url;
				var startIndex:int = url.lastIndexOf("/")+1;
				swfString = url.substring(startIndex, url.length-4)
				swfString += "-";
			}
			
			fileRef.save(ba, swfString+dateString+timeString+".png");			
		}

		
		
	}
	
}