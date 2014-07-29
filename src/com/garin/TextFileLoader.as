package com.garin {
	import flash.events.Event;
	import flash.system.Security;
	import flash.net.*;	
	
	/**
	 * Loads files from a server
	 * @author Daniel Stradwick "garin"
	 */
	
	public class TextFileLoader {
		
		private static var activeLoaders:Vector.<TextFileLoader>;
		
		private var url:String = "";
		private var callback:Function;
		
		private var urlLoader:URLLoader;
		private var versionCheckInProgress:Boolean = false;
				
		public var active:Boolean = false;
		
		
		public static function loadFile(url:String, callback:Function):void {
			// activate a loader			
			var fileLoader:TextFileLoader = new TextFileLoader(url, callback);			
			if (fileLoader.active)	activeLoaders.push(fileLoader);
		}
		
		
		
		public function TextFileLoader(url:String, callback:Function):void {
			this.url = url;		
			this.callback = callback;
			load();
		}

		
		protected function load():void {
					
			/*
			if (Security.sandboxType != Security.REMOTE) {
				trace("Unable to connect to remote server");
				return;
			}
			*/
			
			try {
				var urlRequest:URLRequest = new URLRequest(url);
				urlLoader = new URLLoader(urlRequest);
				urlLoader.addEventListener(Event.COMPLETE, loaded, false, 0, true);
				
				this.active = true;
				if (activeLoaders == null)	activeLoaders = new Vector.<TextFileLoader>();	
				activeLoaders.push(this);			
				
			} catch (e:Error) {	
				if (urlLoader)	urlLoader.removeEventListener(Event.COMPLETE, loaded);
				this.active = false;
			}			
		}

		
		
		protected function loaded(e:Event):void {
			
			var contentsText:String = e.target.data as String;
			if (callback != null) 	callback(contentsText);
						
			this.active = false;
						
			if (urlLoader) {
				urlLoader.removeEventListener(Event.COMPLETE, loaded);
				urlLoader.close();
				
				// remove from active list
				for (var i:int = activeLoaders.length - 1; i >= 0; i--) {
					var tf:TextFileLoader = activeLoaders[i] as TextFileLoader;
					if (!tf.active)	activeLoaders.splice(i, 1);
				}
			}
		}		
				
		
	}

}