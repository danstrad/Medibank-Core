package com.garin {
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Debugging {
		
		static public function addDebugDisplay(s:Stage, loaderInfo:LoaderInfo=null, startHidden:Boolean=false):void {
			var d:DebugDisplay = new DebugDisplay(loaderInfo);
			if (startHidden) 	d.visible = false;
			s.addChild(d);
			d.init();
		}
		
		
				
		///Source: http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00000149.html
		static public function printDisplayList(obj:DisplayObjectContainer, indentString:String = ""):void {
			if (obj == null) {
				trace("Display Container to trace is null");
				return;
			}
			var child:DisplayObject;
			for (var i:uint=0; i < obj.numChildren; i++) {
				child = obj.getChildAt(i);
				if (!child) continue;
				trace(indentString, child, child.name); 
				if (obj.getChildAt(i) is DisplayObjectContainer)
				{
					printDisplayList(DisplayObjectContainer(child), indentString + "    ")
				}
			}
		}
		
		
		static private var debugLogStr:String = "";
		
		static public function addToDebugLog(str:String):void {
			debugLogStr += str + "\n";
		}
		
		
		static public function getDebugLog():String {
			return debugLogStr;
		}
		
	}

}