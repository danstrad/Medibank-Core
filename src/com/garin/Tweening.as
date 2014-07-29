package com.garin {
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.*;
	import fl.transitions.easing.*;	
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Tweening {
		
		private static var activeTweens:Vector.<Tween> = new Vector.<Tween>();
		
		
		public static function simpleAlpha(target:Object, start:Number, end:Number, frames:int):void {
			var t:Tween = new Tween(target, "alpha", None.easeNone, start, end, frames);
			t.addEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
			activeTweens.push(t);
		}
		
		public static function simpleCustom(target:Object, property:String, start:Number, end:Number, frames:int, callback:Function=null):void {
			var t:Tween = new Tween(target, property, None.easeNone, start, end, frames);
			t.addEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
			if (callback != null) 	t.addEventListener(TweenEvent.MOTION_FINISH, callback);
			activeTweens.push(t);
		}

		
		private static function tweenFinished(e:TweenEvent):void {
			var f:Tween = e.currentTarget as Tween;
			f.removeEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
				
			for (var i:int = activeTweens.length - 1; i >= 0; i--) {
				var t:Tween = activeTweens[i] as Tween;
				if (t == f)	{
					activeTweens.splice(i, 1);
					break;
				}
			}
		}
		
		public static function cancelExistingTweensOnTarget(target:Object, property:String = ""):void {
			// this is not called as a matter of course because its kind of expensive
			for (var i:int = activeTweens.length - 1; i >= 0; i--) {
				var t:Tween = activeTweens[i] as Tween;				
				if (t.obj == target) {
					if ((t.prop == property) || (property == "")) {
						t.removeEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
						activeTweens.splice(i, 1);
						t.stop();
					}
				}
			}
		}
		
		
		
		public static function clear():void {
			for each (var t:Tween in activeTweens) {
				t.removeEventListener(TweenEvent.MOTION_FINISH, tweenFinished);
				t.stop();
			}
			activeTweens = new Vector.<Tween>();
		}
		
	}

}