package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
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
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class VideoSlide extends Sprite implements ISlide {
		
		static public const POP_TIME:Number = 0.5;
		
		protected var url:String;

		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var video:Video;
		
		protected var stateIndex:int;
		protected var textStates:Vector.<TextState>
		
		public function VideoSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
			
			if (xml.hasOwnProperty("video")) {
				var videoXML:XML = xml.video[0];
				var url:String = videoXML.@url.toString();
				var scale:Number = 1;
				if (videoXML.hasOwnProperty("@scale")) scale = parseFloat(videoXML.@scale.toString());
				showVideo(url, 1920 * scale, 1080 * scale);
			}
			
			textStates = new Vector.<TextState>();
			for each(var textstateXML:XML in xml.textstate) {
				var duration:Number = parseFloat(textstateXML.@duration) || 0;
				var state:TextState = new TextState(duration);
				for each(var textXML:XML in textstateXML.text) {
					var box:TextBoxData = new TextBoxData();
					box.type = textXML.@type;
					box.position = textXML.@position;
					box.size = textXML.@size;
					box.text = TextUtils.safeText(textXML.toString());
					box.textScale = parseFloat(textXML.@textScale) || 1;
					state.boxes.push(box);
				}				
				textStates.push(state);
			}
			
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
			ns.pause();

			video.width = width;
			video.height = height;
			video.x = -video.width / 2;
			video.y = -video.height / 2;
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
			// Fade?
			ns.resume();
			stateIndex = 0;
			showNextTextState();
		}

		public function animateOff(callback:Function):void {
			ns.pause();
			dispose();
		}

		public function animate(dTime:Number):void {
			
		}
		

		protected function showNextTextState():void {
			if (stateIndex >= textStates.length) return;
			var state:TextState = textStates[stateIndex];
			var duration:Number = state.duration;

			var textField:TextField;
			var box:MovieClip;
			var g:Graphics;
			var margin:Number;
			var delay:Number;
			for each(var boxData:TextBoxData in state.boxes) {
				switch(boxData.type) {
					case "splash":
						textField = SplashTextSlide.createTextField(boxData.text, boxData.textScale);
						textField.x = -textField.width / 2;
						textField.y = -textField.height / 2;
						addChild(textField);
						
						textField.x = -SplashTextSlide.SCROLL_X - textField.width / 2;
						TweenMax.to(textField, SplashTextSlide.SCROLL_TIME, { x:(0 - textField.width / 2), ease:Quad.easeOut } );
						if (duration > 0) {
							delay = (duration / 1000 - SplashTextSlide.SCROLL_TIME);
							TweenMax.to(textField, SplashTextSlide.SCROLL_TIME, { x:(SplashTextSlide.SCROLL_X - textField.width / 2), delay:delay, onComplete:removeBox, onCompleteParams:[textField], ease:Quad.easeIn } );
						}
						break;
						
					case "pop":
						var boxSize:Number;
						switch(boxData.size) {
							case "small": boxSize = 190; break;
							default:
							case "medium": boxSize = 220; break;
							case "big":
							case "large": boxSize = 250; break;
						}
						margin = 18;
						box = new _VideoText();
						g = box.graphics;
						g.beginFill(0xFF7070)
						g.drawRect( -boxSize / 2, -boxSize / 2, boxSize, boxSize);
						g.endFill();
						addChild(box);
						
						textField = box.textField;
						textField.mouseEnabled = false;
						textField.text = "";
						textField.width = boxSize - 2 * margin;
						textField.height = 1;
						textField.autoSize = TextFieldAutoSize.LEFT;
						textField.wordWrap = true;
			
						textField.text = boxData.text;
						textField.scaleX = textField.scaleY = boxData.textScale;
									
						textField.x = -boxSize / 2 + margin;
						textField.y = -boxSize / 2 + margin - 4;
						
						var angle:Number = boxData.getPositionAngle() * Math.PI / 180;
						box.x = Math.cos(angle) * ((Infographic.WIDTH * 0.45) - boxSize / 2);
						box.y = Math.sin(angle) * ((Infographic.HEIGHT * 0.45) - boxSize / 2);

						box.scaleX = box.scaleY = 0;
						TweenMax.to(box, POP_TIME, { scaleX:1, scaleY:1, ease:Quad.easeOut } );
						if (duration > 0) {
							delay = (duration / 1000 - POP_TIME);
							TweenMax.to(box, SplashTextSlide.SCROLL_TIME, { scaleX:0, scaleY:0, delay:delay, onComplete:removeBox, onCompleteParams:[box], ease:Quad.easeIn } );
						}						
						
						break;
								
					case "edge":
						margin = 45;
						box = new _VideoText();
						addChild(box);
						
						textField = box.textField;
						textField.mouseEnabled = false;
						textField.text = "";
						textField.width = Infographic.WIDTH - 2 * margin;
						textField.height = 1;
						textField.autoSize = TextFieldAutoSize.LEFT;
						textField.wordWrap = true;
			
						textField.text = boxData.text;
						textField.scaleX = textField.scaleY = boxData.textScale;
									
						textField.x = margin;
						textField.y = margin - 4;					
						
						var edgeHeight:Number = textField.height + margin * 2;
						g = box.graphics;
						g.beginFill(0xFF7070)
						g.drawRect(0, 0, Infographic.WIDTH, edgeHeight);
						g.endFill();

						box.x = -Infographic.WIDTH / 2;
						box.y = Infographic.HEIGHT / 2;
						TweenMax.to(box, POP_TIME, { y:(Infographic.HEIGHT / 2 - edgeHeight), ease:Quad.easeOut } );
						if (duration > 0) {
							delay = (duration / 1000 - POP_TIME);
							TweenMax.to(box, SplashTextSlide.SCROLL_TIME, { y:(Infographic.HEIGHT / 2), delay:delay, onComplete:removeBox, onCompleteParams:[box], ease:Quad.easeIn } );
						}						
						
						break;
						
				}
			}
			
			TweenMax.to(this, duration / 1000, { onComplete:onStateFinished } );
			
			stateIndex++;
		}
		
		protected function removeBox(box:DisplayObject):void {
			if (box && box.parent) box.parent.removeChild(box);
		}
		
		protected function onStateFinished():void {
			showNextTextState();
		}
		
		

		
	}

}

class TextState {
	public var duration:Number;
	public var boxes:Vector.<TextBoxData>
	public function TextState(duration:Number):void {
		this.duration = duration;
		boxes = new Vector.<TextBoxData>();
	}
}

class TextBoxData {
	public var type:String;
	public var position:String;
	public var size:String;
	public var text:String;
	public var textScale:Number;
	public function TextBoxData() {
		
	}
	
	public function getPositionAngle():Number {
		switch(position.toLowerCase()) {
			default:
			case "left": return 180;
			case "bottomleft": return 135;
			case "bottom": return 90;
			case "bottomright": return 45;
			case "right": return 0;
			case "topright": return -45;
			case "top": return -90;
			case "topleft": return -135;
		}
	}
}

