package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class VideoSlide extends Sprite implements ISlide {
		
		static public const POOL:Boolean = true;
		static protected const pooled:Vector.<Object> = new Vector.<Object>;

		static public const WIPE_TIME:Number = 0.7;// 0.9;
		static public const POP_TIME:Number = 0.5;
		
		protected var url:String;

		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var video:Video;
		
		protected var stateIndex:int;
		protected var textStates:Vector.<TextState>
		
		protected var boxColor:uint;
		protected var wipeColor:uint;

		protected var startTime:Number; // Seconds
		protected var endTime:Number;
		
		protected var animateOnType:String;
		protected var animateOffType:String;
		
		protected var wipeOnMask:Sprite;

		protected var finishedCallback:Function;
		
		protected var playing:Boolean;
		protected var seeking:Boolean;
		
		
		public function VideoSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
						
			if (xml.hasOwnProperty("@animateOn")) animateOnType = xml.@animateOn;
			if (xml.hasOwnProperty("@animateOff")) animateOffType = xml.@animateOff;
			
			if (xml.hasOwnProperty("video")) {
				var videoXML:XML = xml.video[0];
				var url:String = videoXML.@url.toString();
				var scale:Number = 1;
				var sourceWidth:Number = 1920;
				var sourceHeight:Number = 1080;
				if (videoXML.hasOwnProperty("@sourceWidth")) sourceWidth = parseFloat(videoXML.@sourceWidth.toString())
				if (videoXML.hasOwnProperty("@sourceHeight")) sourceHeight = parseFloat(videoXML.@sourceHeight.toString())
				if (videoXML.hasOwnProperty("@scale")) {
					if (videoXML.@scale.toString() == "auto") {
						scale = Math.max(Infographic.WIDTH / sourceWidth, Infographic.HEIGHT / sourceHeight);
					} else {
						scale = parseFloat(videoXML.@scale.toString());
					}
				}
				if (videoXML.hasOwnProperty("@startTime")) startTime = parseFloat(videoXML.@startTime.toString());
				else startTime = 0;
				if (videoXML.hasOwnProperty("@endTime")) endTime = parseFloat(videoXML.@endTime.toString());
				else endTime = 0;
				var volume:Number = 1;
				if (videoXML.hasOwnProperty("@volume")) volume = parseFloat(videoXML.@volume.toString());
				soundTransform = new SoundTransform(volume);
				showVideo(url, sourceWidth * scale, sourceHeight * scale);
			}
			
			boxColor = 0xFF8080;
			wipeColor = 0xFF8080;
			if (xml.hasOwnProperty("appearance")) {
				var appearanceXML:XML = xml.appearance[0];
				boxColor = slideData.currentBoxColor;
				if (appearanceXML.hasOwnProperty("@wipeColor")) wipeColor = slideData.currentColors[Math.max(0, int(appearanceXML.@wipeColor) - 1)];
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
			playing = false;
			if (!ns) return;
			
			ns.pause();
			ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			video.clear();
			video.attachNetStream(null);
			
			if (POOL) {
				pooled.push( { ns:ns, nc:nc } );
			} else {
				ns.close();
				ns = null;
				nc.close();
				nc = null;
			}
		}

		
		public function showVideo(url:String, width:Number, height:Number):void {
			this.url = url;
			
			//Create a new Video object that display the video and add it to the stage display list, as shown in the following snippet:
			video = new Video();
			addChild(video);
			
			if (POOL && (pooled.length > 0)) {
				var o:Object = pooled.pop();
				nc = o.nc;
				ns = o.ns;
			} else {
				nc = new NetConnection();
				nc.connect(null);
				
				ns = new NetStream(nc);
				ns.client = { onMetaData:function(obj:Object):void { } }
			}


			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			ns.play(url);
			ns.inBufferSeek = true;
			
			playing = false;
			ns.pause();
			
			video.attachNetStream(ns);
			video.width = width;
			video.height = height;
			video.x = -video.width / 2;
			video.y = -video.height / 2;
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			//trace(event.info.code);
			
			switch(event.info.code) {
				case "NetStream.Buffer.Empty":
					seekTo(startTime);				
					//ns.seek(0);
					//ns.resume();
					break;
					
				case "NetStream.Seek.Notify":
					seeking = false;
					if (playing && ns) ns.resume();
					break;
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		}

		public function pauseVideo():void {
			playing = false;
			if (ns) ns.pause();
		}
		
		public function resumeVideo():void {
			playing = false;
			if (ns) ns.resume();
		}
		


		
		
		public function animateOn():void {
			switch(animateOnType) {
				case "wipe_from_bottom":
				case "wipe_from_top":
				case "wipe_from_left":
				case "wipe_from_right":
					wipeOn(animateOnType);
					break;
			}

			playing = true;
			//ns.seek(startTime);
			seekTo(startTime);
			ns.resume();
			
			stateIndex = 0;
			showNextTextState();
		}
		

		public function animateOff(callback:Function):void {
			finishedCallback = callback;

			switch(animateOffType) {
				// Fade?	
				
				case "wipe_from_bottom":
				case "wipe_from_top":
				case "wipe_from_left":
				case "wipe_from_right":
					wipeOff(animateOffType);
					break;
					
				default:
					dispose();
					callback(this);
					break;
			}
		}
		
		public function animate(dTime:Number):void {
			//trace(seeking, url, startTime, endTime, dTime, ns.time);
			//trace(seeking, playing);
			
			if (seeking) return;
			
			var restart:Boolean = false;
			//if ((startTime > 0) && (ns.time < startTime)) restart = true;
			if ((endTime > 0) && (ns.time > endTime)) restart = true;
			//trace(ns.time, startTime, endTime, restart);
			
			if (restart) {
				ns.pause();
				seekTo(startTime);
				//ns.seek(startTime);
			}
		}

		protected function seekTo(time:Number):void {
			seeking = true;
			ns.seek(time);
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
						g.beginFill(boxColor)
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
								
					case "bottom":
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
						g.beginFill(boxColor)
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
			
			if (duration > 0) TweenMax.to(this, duration / 1000, { onComplete:onStateFinished } );
			
			stateIndex++;
		}
		
		protected function removeBox(box:DisplayObject):void {
			if (box && box.parent) box.parent.removeChild(box);
		}
		
		protected function onStateFinished():void {
			showNextTextState();
		}
		
		
		protected function wipeOn(type:String):void {
			var wiper:Sprite = wipeOnMask = new Sprite();
			var g:Graphics = wiper.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect( -Infographic.WIDTH / 2, -Infographic.HEIGHT / 2, Infographic.WIDTH, Infographic.HEIGHT);
			g.endFill();
			addChild(wiper);
			switch(type) {
				case "wipe_from_bottom":
					wiper.scaleY = 0;
					wiper.y = Infographic.HEIGHT / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleY:1, y:0, ease:Quad.easeOut, onComplete:onWipeOnComplete } );
					break;
				case "wipe_from_top":
					wiper.scaleY = 0;
					wiper.y = -Infographic.HEIGHT / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleY:1, y:0, ease:Quad.easeOut, onComplete:onWipeOnComplete } );
					break;
				case "wipe_from_left":
					wiper.scaleX = 0;
					wiper.x = -Infographic.WIDTH / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleX:1, x:0, ease:Quad.easeOut, onComplete:onWipeOnComplete } );
					break;
				case "wipe_from_right":				
					wiper.scaleX = 0;
					wiper.x = Infographic.WIDTH / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleX:1, x:0, ease:Quad.easeOut, onComplete:onWipeOnComplete } );
					break;
			}
			wiper.visible = false;
			mask = wiper;
		}		
		protected function onWipeOnComplete():void {
			mask = null;
			if (wipeOnMask.parent) wipeOnMask.parent.removeChild(wipeOnMask);
			wipeOnMask = null;
		}

		protected function wipeOff(type:String):void {
			// scroll text out of any remaining boxes, but leave the color
			for (var i:int = numChildren - 1; i >= 0; i--) {
				var box:MovieClip = getChildAt(i) as _VideoText;
				if (box) {
					var bounds:Rectangle = box.getBounds(box);
					var textField:TextField = box.textField;
					if (textField) {
						TweenMax.to(textField, POP_TIME, { y:(bounds.bottom + 1), ease:Quad.easeIn } );
					}
				}
			}
			
			var wiper:Shape = new Shape();
			var g:Graphics = wiper.graphics;
			g.beginFill(wipeColor);
			g.drawRect( -Infographic.WIDTH / 2, -Infographic.HEIGHT / 2, Infographic.WIDTH, Infographic.HEIGHT);
			g.endFill();
			addChild(wiper);
			switch(type) {
				case "wipe_from_bottom":
					wiper.scaleY = 0;
					wiper.y = Infographic.HEIGHT / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleY:1, y:0, ease:Quad.easeIn, onComplete:onWipeOffComplete } );
					break;
				case "wipe_from_top":
					wiper.scaleY = 0;
					wiper.y = -Infographic.HEIGHT / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleY:1, y:0, ease:Quad.easeIn, onComplete:onWipeOffComplete } );
					break;
				case "wipe_from_left":
					wiper.scaleX = 0;
					wiper.x = -Infographic.WIDTH / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleX:1, x:0, ease:Quad.easeIn, onComplete:onWipeOffComplete } );
					break;
				case "wipe_from_right":				
					wiper.scaleX = 0;
					wiper.x = Infographic.WIDTH / 2;
					TweenMax.to(wiper, WIPE_TIME, { scaleX:1, x:0, ease:Quad.easeIn, onComplete:onWipeOffComplete } );
					break;
			}
		}		
		protected function onWipeOffComplete():void {
			dispose();
			if (finishedCallback != null) finishedCallback(this);
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

