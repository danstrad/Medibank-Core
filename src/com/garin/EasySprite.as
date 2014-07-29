package com.garin {
	import flash.display.Sprite;
	
	/**
	 * Time-saving Sprite subclass
	 * @author Daniel Stradwick "garin"
	 */
	
	public class EasySprite extends Sprite {
		
		public function EasySprite() {
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		public function removeAsChild():Boolean {
			if (parent) {
				parent.removeChild(this);
				return true;
			}
			return false;
		}
		
		public function toTop():void {
			if (parent) parent.addChild(this);
		}
		
	}

}