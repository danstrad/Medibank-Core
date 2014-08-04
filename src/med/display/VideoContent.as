package med.display {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class VideoContent extends Sprite {
		
		protected static const EXPAND_TIME:Number = 500;
		
		protected var url:String;

		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var video:Video;
		
		protected var expanding:Boolean;
		protected var retracting:Boolean;
		protected var expandTime:Number;
		
		protected var expandedStageRect:Rectangle;
		protected var retractedStageRect:Rectangle;
		protected var homeRect:Rectangle;

		protected var backButton:VideoBackButton;
		
		public function VideoContent() {
			backButton = new VideoBackButton();
			backButton.x = BoxesMain.STAGE_WIDTH;
		}
		
		public function dispose():void {
			if (ns) ns.close();
			if (video) {
				video.clear();
				video.attachNetStream(null);
			}
		}

		
		public function showVideo(url:String, width:Number, height:Number):void {
			this.url = url;
			
			//Create a new Video object that display the video and add it to the stage display list, as shown in the following snippet:
			video = new Video();
			addChild(video);

			nc = new NetConnection();
			nc.connect(null);

			//Create a NetStream object, passing the NetConnection object as an argument to the constructor. The following snippet connects a NetStream object to the NetConnection instance and sets up the event handlers for the stream:
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.client = { onMetaData:function(obj:Object):void { } }
			
			video.attachNetStream(ns);
			ns.play(url);

			homeRect = new Rectangle( -width / 2, -height / 2, width, height);

			video.smoothing = true;
			video.x = homeRect.x;
			video.y = homeRect.y;
			video.width = homeRect.width;
			video.height = homeRect.height;
			
			var maxW:Number = BoxesMain.STAGE_WIDTH;// - 100;
			var maxH:Number = BoxesMain.STAGE_HEIGHT;// - 80;
			var maxScale:Number = Math.max(maxW / width, maxH / height);
			var esw:Number = width * maxScale;
			var esh:Number = height * maxScale;
			expandedStageRect = new Rectangle((BoxesMain.STAGE_WIDTH - esw) / 2, (BoxesMain.STAGE_HEIGHT - esh) / 2, esw, esh);
			
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			if (event.info.code == "NetStream.Buffer.Empty") {
				ns.seek(0);
				ns.resume();
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		}

		public function expand():void {
			if (expanding || !stage) return;
			expanding = true;
			expandTime = 0;	
			
			retractedStageRect = video.getBounds(stage);

			stage.addChild(video);
			
			video.x = retractedStageRect.x;
			video.y = retractedStageRect.y;
			video.width = retractedStageRect.width;
			video.height = retractedStageRect.height;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleClick, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true);
			
			stage.addChild(backButton);
			backButton.alpha = 0;
			
			allowOtherMouseInput = false;
		}
		protected function removeStageListeners():void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleClick, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false);			
		}
		protected function handleClick(event:MouseEvent):void {

			if (expanding) return;
			retracting = true;
			expandTime = 0;	
			
			removeStageListeners();
		}		
		protected function handleRemovedFromStage(event:Event):void {
			removeStageListeners();
		}		
		
		protected function set allowOtherMouseInput(value:Boolean):void {
			var root:Sprite = stage.getChildAt(0) as Sprite;
			root.mouseEnabled = root.mouseChildren = value;
		}
		
		
		
		public function animate(dTime:Number):void {
			if (!stage) return;
			if (expanding || retracting) {
				expandTime += dTime;
				var f:Number = Math.min(1, expandTime / EXPAND_TIME);
				var eased:Number;
				if (expanding) eased = Utils.easeOut(f);
				else eased = Utils.easeOut(1 - f);
				video.width = retractedStageRect.width + (expandedStageRect.width - retractedStageRect.width) * eased;
				video.height = retractedStageRect.height + (expandedStageRect.height - retractedStageRect.height) * eased;
				video.x = retractedStageRect.x + (expandedStageRect.x - retractedStageRect.x) * eased;
				video.y = retractedStageRect.y + (expandedStageRect.y - retractedStageRect.y) * eased;

				backButton.alpha = eased;

				if (f >= 1) {
					if (expanding) {
						expanding = false;
					} else {
						retracting = false;
						addChild(video);
						video.x = homeRect.x;
						video.y = homeRect.y;
						video.width = homeRect.width;
						video.height = homeRect.height;
						allowOtherMouseInput = true;
						
						if (backButton.parent) backButton.parent.removeChild(backButton);
					}
				}
			}
		}
		
		
	}

}