package com.garin.animation {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class SelfRemovingAnimation extends MovieClip {
		
		private var clip:MovieClip;
		private var callback:Function;
		public var frameLimit:int = -1;
		
		public function SelfRemovingAnimation(anim:MovieClip, callOnCompletion:Function=null, frameLimit:int=-1) {
			this.clip = anim;
			this.callback = callOnCompletion;
			this.frameLimit = frameLimit;
			addChild(clip);
			
			if (frameLimit == -1) {
				// use clip length
				clip.addFrameScript(clip.totalFrames - 1, remove);
				this.frameLimit = clip.totalFrames - 1;
			} else {
				// override clip length
				addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
			}
		}
		
		private var _frameCount:int = 0;
		
		private function onFrame(e:Event):void {
			_frameCount++;
			if (_frameCount > frameLimit) {
				removeEventListener(Event.ENTER_FRAME, onFrame);
				remove();
				trace("SelfRemovingAnimation -- frame limit hit");
			}
		}
		
		
		public function remove():void {
			stop();
			
			if (clip) {
				clip.stop();				
				
				if ("cleanup" in clip) {
				//if (clip["cleanup"] == undefined) {
					clip.cleanup();						
				}
				
				
				if (clip.parent) 						removeChild(clip);
			}
			
			if (parent) {
				parent.removeChild(this);
				// change: now we only do the callback if we actually removed the clip ourselves
				if (callback != null) callback();			
			}

			callback = null;
			clip = null;
			delete this;
		}
		
		override public function play():void {
			if (clip is MovieClip) 	MovieClip(clip).play();
			super.play();
		}
		
//		override public function gotoAndStop(frame:uint):void {
//			clip.gotoAndStop(frame);
//			super.gotoAndStop(frame);
//		}

		
	}

}