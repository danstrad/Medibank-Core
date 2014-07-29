package com.garin.animation {
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * Renders an animation into an array of BitmapDatas, ready to be saved out to image (or what have you)
	 * @author Daniel Stradwick "garin"
	 */
	
	public class PreRenderAnimation {
		
		private var clip:MovieClip;
		
		private var callback:Function;
		private var callbackArg:Number;
		
		public var frameData:Array = [];
		private var frameCount:int = 0;
		private var frameLimit:int = -1;
		
		private var pixelBuffer:int = 0;
		
		
		public function PreRenderAnimation(mc:MovieClip, frameLimit:int=-1, callback:Function=null, callbackArg:Number=-1) {
			this.clip = mc;
			this.frameLimit = frameLimit;
			this.callback = callback;
			this.callbackArg = callbackArg;
			
			if (frameLimit <= 0) 	frameLimit = clip.totalFrames;				
			else 					frameLimit = Math.min(frameLimit, clip.totalFrames);
		}
		
		
		public function beginRender(pixelBuffer:int=0):Boolean {			
			clip.addEventListener(Event.ENTER_FRAME, onClipFrame);
			this.pixelBuffer = pixelBuffer;
			frameCount = 0;
			clip.play();	
			return true;
		}
		
		
		private function onClipFrame(e:Event):void {
			frameCount++;
			
			if (frameCount > frameLimit) {
				clip.removeEventListener(Event.ENTER_FRAME, onClipFrame);
				if (callback != null)	callback(this, callbackArg);
				return;
			}

			//trace("RENDERING: frame:", frameCount, "limit:", frameLimit);
			frameData.push(BitmapFrame.renderFromClip(clip, clip, 1.0, pixelBuffer));
		}

	
		public function cleanup():void {
			clip.removeEventListener(Event.ENTER_FRAME, onClipFrame);
			delete this;
		}
				
		
		
	}

}