package com.garin.ui { 
 	import flash.display.MovieClip;
 	import flash.display.Sprite;
	import flash.events.MouseEvent;
   	import flash.events.TimerEvent;
    import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.garin.*;

	
	
	public class CheckBox extends MovieClip {
	
		public var radioGroup:Array;
		public var checked:Boolean = false;
		private var hover:Boolean = false;	// are we hovering over this
		private var clip:MovieClip;
		private var hitBox:MovieClip;
		
		// optional function to call when clicked
		private var clickCallback:Function;
	
		public var value:*;
		
	
		public function CheckBox(clip:MovieClip, checked:Boolean=false, desc:String="", value:*=null, callback:Function=null):void {
			this.clip = clip;

			if (clip.parent) {
				this.x = clip.x;
				this.y = clip.y;
				clip.parent.addChild(this);
				clip.parent.removeChild(clip);
				
			} else if (clip == null) {
				this.clip = new _dCheckBoxSWF();
			}

			clip.x = 0;
			clip.y = 0;			
			addChild(clip);
			
			clip.description.mouseEnabled = false;
			//clip.mouseChildren = false;
			
			this.value = value;

			hitBox = clip.hitBox;
			hitBox.buttonMode = true;
			
			// add mouse listeners
			hitBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseClick, false, 0, true);
			hitBox.addEventListener(MouseEvent.MOUSE_OVER, mouseOn, false, 0, true);
			hitBox.addEventListener(MouseEvent.MOUSE_OUT, mouseOff, false, 0, true);

			setDescription(desc);
			setCallback(callback);			
			setChecked(checked);			
		}
	
	
		public function cleanup():void {
			hitBox.removeEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
			hitBox.removeEventListener(MouseEvent.MOUSE_OVER, mouseOn);
			hitBox.removeEventListener(MouseEvent.MOUSE_OUT, mouseOff);
			clickCallback = null;
		}
	
		public function setCallback(cb:Function):void {
			this.clickCallback = cb;
		}
	
	
		public function setDescription(d:String):void {
			clip.description.htmlText = d;
			clip.description.autoSize = TextFieldAutoSize.LEFT;
	//		clip.hitBox.width = clip.description.x + clip.description.width + 10;
		}
	
	
		private function mouseClick(e:MouseEvent):void {
			if ((radioGroup != null) && checked) return;	// we cant unselect when acting as radio			
			setChecked(!checked);
			if (this.clickCallback != null)		clickCallback();
		}
	
		private function mouseOn(e:MouseEvent):void {
			hover = true;
			update();
		}
	
		private function mouseOff(e:MouseEvent):void {
			hover = false;
			update();
		}
	
		public function setChecked(c:Boolean):void {
			this.checked = c;
			
			// if we're functioning as a radio group..
			if ((radioGroup != null) && c) {
				for each (var b:CheckBox in radioGroup) {
					if (b != this)	b.setChecked(false);
				}
			}
			
			update();
		}
	
	
		private function update():void {
			if (!checked) {
				if (hover) 	clip.gotoAndStop(3);
				else 		clip.gotoAndStop(1);
			} else {
				if (hover) 	clip.gotoAndStop(4);
				else		clip.gotoAndStop(2);
			}
		}

		
	
	}

	
	
	
}