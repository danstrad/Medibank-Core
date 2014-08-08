package med.infographic {
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

	public class VideoSlide extends Sprite implements ISlide {
		
		protected static const EXPAND_TIME:Number = 500;
		
		protected var url:String;

		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var video:Video;
		
		public function VideoSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
			
			var url:String = xml.@url.toString();
			showVideo(url, 100, 100);
			trace('go');
			
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

			/*
			var maxW:Number = BoxesMain.STAGE_WIDTH;// - 100;
			var maxH:Number = BoxesMain.STAGE_HEIGHT;// - 80;
			var maxScale:Number = Math.max(maxW / width, maxH / height);
			var esw:Number = width * maxScale;
			var esh:Number = height * maxScale;
			expandedStageRect = new Rectangle((BoxesMain.STAGE_WIDTH - esw) / 2, (BoxesMain.STAGE_HEIGHT - esh) / 2, esw, esh);
			*/
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			if (event.info.code == "NetStream.Buffer.Empty") {
				ns.seek(0);
				ns.resume();
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		}

		public function animateOn():void {
			
		}

		public function animateOff(callback:Function):void {
			
		}

		public function animate(dTime:Number):void {
			
		}

		
	}

}