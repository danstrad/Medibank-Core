package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class CaptionedImagesSlide extends Sprite implements ISlide {

		protected var finishedCallback:Function;

		protected var states:Vector.<State>;
		protected var currentStateIndex:int;
		
		protected var texts:Vector.<TextField>
		
		public function CaptionedImagesSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, finishedCallback:Function) {
			this.finishedCallback = finishedCallback;
			
			currentStateIndex = -1;
			
			states = new Vector.<State>();
			
			texts = new Vector.<TextField>();
			
			var maxImageWidth:Number = 400;
			var maxImageHeight:Number = 600;
			
			for each(var stateXML:XML in slideData.xml.state) {
				var state:State = new State();
				state.duration = parseFloat(stateXML.@duration) || 5000;
				
				var imageXML:XML = stateXML.Image[0];
				var url:String = imageXML.@url.toString();
				var bitmap:Bitmap = new Bitmap(AssetManager.getImage(url), "auto", true);
				var scale:Number = Math.min(maxImageWidth / bitmap.width, maxImageHeight / bitmap.height);
				bitmap.scaleX = bitmap.scaleY = scale;
				bitmap.x -= bitmap.width / 2;
				bitmap.y -= bitmap.height / 2;
				state.imageHolder.addChild(bitmap);
				
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
			var image:Sprite = state.imageHolder;
			
			var t:Number = 0;
			
			const IMAGE_ANIMATE_TIME:Number = 0.5;			
			const IMAGE_X:Number = -250;
			const IMAGE_X_OFF:Number = -300;
			const IMAGE_Y:Number = 500;
			const SMALL_SCALE:Number = 0.2 * image.scaleX;
			const NORMAL_SCALE:Number = 1 * image.scaleX;
			const BIG_SCALE:Number = 2 * image.scaleX;
			
			const CAPTION_ANIMATE_TIME:Number = 0.5;
			const CAPTION_ANIMATE_BUFFER:Number = 0.3; // Wait before and after
			const CAPTION_ANIMATE_STAGGER:Number = 0.7;
			const CAPTION_X:Number = -20;
			const CAPTION_X_OFF:Number = 1500;
			const CAPTION_Y_SPACING:Number = 50;
			const CAPTION_WIDTH:Number = 1250;
			
			addChild(image);
			image.x = IMAGE_X_OFF;
			image.y = IMAGE_Y;
			image.scaleX = image.scaleY = BIG_SCALE;
			TweenMax.to(image, IMAGE_ANIMATE_TIME, { x:IMAGE_X, y:0, scaleX:NORMAL_SCALE, scaleY:NORMAL_SCALE, delay:t, ease:Quad.easeOut } );
			TweenMax.to(image, IMAGE_ANIMATE_TIME, { x:IMAGE_X_OFF, y:-IMAGE_Y, scaleX:SMALL_SCALE, scaleY:SMALL_SCALE, delay:t + (state.duration / 1000) - IMAGE_ANIMATE_TIME, ease:Quad.easeIn } );
			
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
	public var imageHolder:Sprite;
	public var captions:Vector.<String>;
	
	public function State() {
		imageHolder = new Sprite();
		captions = new Vector.<String>();
	}
	
}