package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class CaptionedVideoSlide extends Sprite implements ISlide {

		protected var finishedCallback:Function;

		protected var videoSlide:VideoSlide;
		
		protected var states:Vector.<State>;
		protected var currentStateIndex:int;
		
		protected var texts:Vector.<TextField>
		
		public function CaptionedVideoSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, finishedCallback:Function) {
			this.finishedCallback = finishedCallback;
			
			currentStateIndex = -1;
			
			states = new Vector.<State>();
			
			videoSlide = new VideoSlide(slideData, initialBackgroundColor);
			addChild(videoSlide);			
			videoSlide.animateOn();
			videoSlide.scaleX = videoSlide.scaleY = 0.6;
			videoSlide.x = -Infographic.WIDTH * 0.18;
			
			texts = new Vector.<TextField>();
			
			for each(var stateXML:XML in slideData.xml.state) {
				var state:State = new State();
				state.duration = parseFloat(stateXML.@duration) || 5000;
				
				for each(var captionXML:XML in stateXML.caption) {
					state.captions.push(TextUtils.safeText(captionXML.toString()));
				}				
				
				states.push(state);
			}
			
		}
		
		
		public function animate(dTime:Number):void { 
			
			
		}
		
		public function animateOn():void {
			showNextState();
		}
		
		protected function showNextState():void {
			currentStateIndex++;
			var state:State = states[currentStateIndex];
			
			var t:Number = 0;
			
			const CAPTION_ANIMATE_TIME:Number = 0.5;
			const CAPTION_ANIMATE_BUFFER:Number = 0.3; // Wait before and after
			const CAPTION_ANIMATE_STAGGER:Number = 0.7;
			const CAPTION_X:Number = 150;
			const CAPTION_X_OFF:Number = 1500;
			const CAPTION_Y_SPACING:Number = 50;
			const CAPTION_WIDTH:Number = 800;
			
			for each(var caption:String in state.captions) {
				var cornerAssets:MovieClip = new _CornerText();						
				var tf:TextField = cornerAssets.textField;
				tf.text = caption;
				addChild(tf);
				tf.width = CAPTION_WIDTH;
				tf.autoSize = TextFieldAutoSize.LEFT;
				texts.push(tf);
			}
			var captionHeight:Number = (texts.length - 1) * CAPTION_Y_SPACING;
			for each(tf in texts) {
				captionHeight += Math.ceil(tf.height);
			}
			var captionY:Number = -0.5 * captionHeight;
			for each(tf in texts) {
				tf.y = captionY;
				captionY += CAPTION_Y_SPACING + Math.ceil(tf.height);
			}
			
			t += CAPTION_ANIMATE_BUFFER;
			var captionDuration:Number = state.duration - (CAPTION_ANIMATE_BUFFER * 2 + (state.captions.length - 1) * CAPTION_ANIMATE_STAGGER) * 1000;
			
			for (var i:int = 0; i < texts.length; i++) {
				tf = texts[i];
				tf.x = CAPTION_X_OFF;
				TweenMax.to(tf, CAPTION_ANIMATE_TIME, { x:CAPTION_X, delay:t + i * CAPTION_ANIMATE_STAGGER, ease:Quad.easeOut } );
				TweenMax.to(tf, CAPTION_ANIMATE_TIME, { x:CAPTION_X_OFF, delay:t + i * CAPTION_ANIMATE_STAGGER + (captionDuration / 1000) - CAPTION_ANIMATE_TIME, ease:Quad.easeIn } );
			}
			
			TweenMax.delayedCall(state.duration / 1000, removeCurrentState);
		}
		
		protected function removeCurrentState():void {
			for each(var tf:TextField in texts) {
				if (tf.parent) tf.parent.removeChild(tf);
			}
			texts.length = 0;
			if (currentStateIndex < states.length - 1) {
				showNextState();
			} else {
				videoSlide.dispose();
				finishedCallback(this);
			}
		}
		
		public function animateOff(callback:Function):void {
		}		
				

	}

}
import flash.display.Sprite;

class State {
	
	public var duration:Number;
	public var captions:Vector.<String>;
	
	public function State() {
		captions = new Vector.<String>();
	}
	
}