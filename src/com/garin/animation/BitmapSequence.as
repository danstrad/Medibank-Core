package com.garin.animation {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Behaves outwardly like a MovieClip, but is an arbitrary sequence of bitmaps (apologies to Andrew Sega)
	 * @author Daniel Stradwick "garin"
	 */
	
	public class BitmapSequence extends MovieClip {
		
		private var _currentFrame:int = 1;
		private var _totalFrames:int = 0;
		private var _frames:Array = [0];	// 0 index is unused		
		private var bitmap:Bitmap;	
		
		public var removeAfterPlaying:Boolean;
		
		
		public function BitmapSequence(bitmapFrameArray:Array, removeAfterPlaying:Boolean=false) {
			this._totalFrames = bitmapFrameArray.length;						
			this._frames = _frames.concat(bitmapFrameArray);		// preserve empty 0 index
			this.removeAfterPlaying = removeAfterPlaying;
			
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
			
			var testData:BitmapData = new BitmapData(100, 100, false, 0xff0000);
			
			bitmap = new Bitmap(testData);
			addChild(bitmap);
			
			trace("new BitmapSequence! totalFrames", _totalFrames, "frames", _frames);
			
			updateBitmap();			
		}
		
		
		public function clone():BitmapSequence {
			return new BitmapSequence(_frames);
		}
		
		
		private function enterFrame(event:Event):void {
			_currentFrame = _currentFrame + 1;	
			
			if (_currentFrame > _totalFrames) {
				if (removeAfterPlaying) {
					if (parent) parent.removeChild(this);
					cleanup();
					return;
				} else 
					_currentFrame = 1;	// wrap playhead around
			}
			
			updateBitmap();
		}
		
		private function removedFromStage(event:Event):void {			
			stop();			
		}
		
		private function updateBitmap():void {
			if (_currentFrame == 0) _currentFrame = 1;
			
			var frame:BitmapFrame = _frames[_currentFrame] as BitmapFrame;
			if (frame) {	
				bitmap.bitmapData = frame.bitmapData;
				bitmap.x = frame.xOffset;
				bitmap.y = frame.yOffset;
			} else {
				trace("BitmapSequence.updateBitmap() - frame " + _currentFrame + " not found!"); 
			}
		}
		

		override public function set x(value:Number):void {	super.x = Math.floor(value); }
		override public function set y(value:Number):void {	super.y = Math.floor(value); }
		
		override public function get currentFrame():int { return _currentFrame; }
		override public function get totalFrames():int { return _totalFrames; }
		override public function stop():void { removeEventListener(Event.ENTER_FRAME, enterFrame, false); }
		override public function play():void { addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true); trace("BitmapSequence.play()"); }
		override public function gotoAndStop(frame:Object, scene:String = null):void { goto(frame, scene); stop(); }
		override public function gotoAndPlay(frame:Object, scene:String = null):void { goto(frame, scene); play(); }
		override public function nextFrame():void { enterFrame(null); }

		private function goto(frame:Object, scene:String = null):void {
			// NOTE: string labels not supported 
			if (frame is Number) {
				_currentFrame = frame as Number;
				updateBitmap();
			}
		}		
			
		public function cleanup():void { 
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_frames = null;
		}		
		
	}

}