package com.garin.ui {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import md2.dungeon.*;
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	
	public class DialogTwoOptions extends DialogTwoOptionsSWF {
				
//		public var headerField:TextField;
//		public var bodyField:TextField;
		
		public var bb1:GenericButton;
		public var bb2:GenericButton;

		public var handler1:Function;
		public var handler2:Function;
		
		public var handlerArg1:Object;
		public var handlerArg2:Object;
		
		public static var current:DialogTwoOptions;
		
		
		public static const ITEM_DESTROY:int 		= 1;
		public static const UNLOCK_SKILL:int		= 2;

		public static const DUNGEON_ASCEND:int		= 3;
		public static const DUNGEON_DESCEND:int		= 4;
		
		
		private var parameter:Object;
	
		
		
		public function DialogTwoOptions(type:int, param:Object=null):void {
			bb1 = new GenericButton(button1);
			bb2 = new GenericButton(button2);
			bb1.clip.addEventListener(MouseEvent.CLICK, button1Click, false, 0, true);
			bb2.clip.addEventListener(MouseEvent.CLICK, button2Click, false, 0, true);
			current = this;
			this.parameter = param;
			init(type);
		}
		
		
		private function init(type:int):void {
			var header:String = "Dialog";
			var msg:String = "Undefined contents";
			
			switch (type) {
				
				case ITEM_DESTROY:
					header = "Destroy Item";
					msg = "Are you sure you wish to permanently destroy this item?";
				//	if ((parameter != null) && (parameter is Item))	msg +=" ("+Item(param).itemName+")";
					//button1Text = "Confirm";
					//button2Text = "Cancel";	
					//handler1 = ;
					break;
					
				case DUNGEON_ASCEND:
					header = "Ascend Stairs";
					msg = "Are you sure you wish to move up a level?";
					button1Text = "Yes";
					button2Text = "No";	
					handler1 = DungeonRoom.current.ascend();
					break;	

				case DUNGEON_DESCEND:
					header = "Descend Stairs";
					msg = "Are you sure you wish to move down a level?";
					button1Text = "Yes";
					button2Text = "No";	
					handler1 = DungeonRoom.current.descend();
					break;						
					
			}
			
			updateHeader(header);
			updateText(msg);
		}
		
		public function updateHeader(str:String):void {
			headerField.text = str;
		}
		
		public function updateText(str:String):void {
			bodyField.text = str;
			bodyField.autoSize = TextFieldAutoSize.CENTER;
			bodyField.y = ((headerField.y + headerField.height) + bb1.clip.y) / 2 - bodyField.height/2;
		}
	
		
		private function button1Click(e:MouseEvent):void {
			if (this.handler1 != null) {
				if (handlerArg1) handler1(handlerArg1);
				else handler1();
			}
			remove();
		}
		
		private function button2Click(e:MouseEvent):void {
			if (this.handler2 != null) {
				if (handlerArg2) handler2(handlerArg2);
				else handler2();
			}
			remove();
		}
		
		public function remove(e:MouseEvent=null):void {
			if (parent != null) 	parent.removeChild(this);
			parameter = null;
			handler1 = null;
			handler2 = null;
			current = null;
		}
		
	}
	
}