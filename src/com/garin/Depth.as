/*

	Whenever a new DisplayObject is added to the world, call:
	Depth.check(displayObject);
	
	Also check whenever its y value changes.
	Best to override set y

	override public function set y(value:Number):void { super.y = value; Depth.check(this); }

*/

package com.garin {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	public class Depth {	

		//overrideDepth allows using a value other than clip's y pos, but note that this overriden depth value
		//is only used for this check (subsequent by other display objects won't take this value into account).
		public static function check(d:DisplayObject, overrideDepth:Number = -1):void {
			var parent:DisplayObjectContainer = d.parent;
			if (!parent) return;
			var depth:Number = (overrideDepth != -1) ? overrideDepth : d.y;
			var i:int = parent.getChildIndex(d);
			var child:DisplayObject;
			while (i > 0) {
				child = parent.getChildAt(i - 1);
				if (depth < child.y) i--;
				else break;
			}
			while (i < parent.numChildren-1) {
				child = parent.getChildAt(i + 1);
				if (depth > child.y) i++;
				else break;
			}
			parent.setChildIndex(d, i);
		}
	}
}