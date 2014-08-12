package med.infographic {
	import com.greensock.easing.Strong;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import flash.display.Graphics;
	import flash.display.BlendMode;
	
	
	public class PauseOverlay extends Sprite {
		
		protected var resumeCallback:Function;
		protected var quitCallback:Function;
		protected var pauseCallback:Function;
		
		protected var bg:Sprite;
		
		protected var resumeButton:Sprite;
		protected var quitButton:Sprite;		
						
		protected static const BACK_BUTTON_X:Number = -100;
		protected static const RESUME_BUTTON_X:Number = 100;
			
		protected static const BUTTONS_Y:Number = 220;
			

			
		public function PauseOverlay(resumeCallback:Function, quitCallback:Function, pauseCallback:Function) {
			this.pauseCallback = pauseCallback;
			this.quitCallback = quitCallback;
			this.resumeCallback = resumeCallback;
		
			// background
			bg = new Sprite();
			addChildAt(bg, 0);
			
			var g:Graphics = bg.graphics;
			g.beginFill(0x000000, 0.5);
			g.drawRect(-Infographic.WIDTH * 0.5, -Infographic.HEIGHT * 0.5, Infographic.WIDTH, Infographic.HEIGHT);
			g.endFill();
			
			bg.cacheAsBitmap = true;
			bg.buttonMode = true;
			addChild(bg);
			
			bg.addEventListener(MouseEvent.MOUSE_DOWN, onClickResume, false, 0, true);

			
			// add buttons			
			quitButton = createButton("Back to Trail", 140, true);
			quitButton.x = BACK_BUTTON_X;
			quitButton.y = BUTTONS_Y;
			quitButton.addEventListener(MouseEvent.MOUSE_DOWN, onClickQuit, false, 0, true);
			addChild(quitButton);
			
			resumeButton = createButton("Continue", 140, false);
			resumeButton.x = RESUME_BUTTON_X;
			resumeButton.y = BUTTONS_Y;
			resumeButton.addEventListener(MouseEvent.MOUSE_DOWN, onClickResume, false, 0, true);
			addChild(resumeButton);
			
			animateOn();
		}

		
		
		public static function createButton(text:String, promptWidth:Number, arrowPointsLeft:Boolean=true):Sprite {
			var button:Sprite = new Sprite();
			
			const ARROW_GAP:Number = 8;
			const X_BORDER:Number = 15;
			const Y_BORDER:Number = 10;

			var prompt:MovieClip = new _ResetPrompt();
			var textField:TextField = prompt.textField;
			textField.wordWrap = false;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = text + "\n ";
			
			var arrow:Sprite = prompt.arrow;
//			var promptWidth:Number = (arrow.width + ARROW_GAP + textField.width);
			var promptHeight:Number = Math.abs(textField.getBounds(prompt).top) * 2;
			
			textField.x = (-promptWidth / 2) + (promptWidth - textField.width) / 2;
			
			if (arrowPointsLeft) {
				arrow.x = -promptWidth / 2 + arrow.width / 2;
//				textField.x = promptWidth / 2 - textField.width;
//				textField.x = arrow.x + (arrow.width / 2) + ARROW_GAP;

				textField.x += ARROW_GAP;

			} else {
				arrow.scaleX *= -1;
				arrow.x = (promptWidth / 2) - (arrow.width / 2);
//				textField.x = arrow.x - textField.width - ((arrow.width / 2) + ARROW_GAP);
				textField.x -= ARROW_GAP;
			}
	

			
			var g:Graphics = button.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect( -promptWidth / 2 - X_BORDER, -promptHeight / 2 - Y_BORDER, promptWidth + X_BORDER * 2, promptHeight + Y_BORDER * 2);
			g.endFill();
			
			prompt.blendMode = BlendMode.ERASE;
			button.addChild(prompt);
			
			button.blendMode = BlendMode.LAYER;						
			button.mouseChildren = false;			
			button.buttonMode = true;
			
			return button;
		}		
		
		
		protected function animateOn():void {
			this.mouseEnabled = false;
			TweenMax.fromTo(resumeButton, 0.3, { x:700 }, { x:RESUME_BUTTON_X, immediateRender:true, ease:Strong.easeIn } );
			TweenMax.fromTo(quitButton, 0.3, { x:-700 }, { x:BACK_BUTTON_X, immediateRender:true, ease:Strong.easeIn } );			
			TweenMax.fromTo(bg, 0.4, { alpha:0 }, { alpha:1.0, immediateRender:true, onComplete:finishedAnimateOn } );
		}
		
		
		protected function finishedAnimateOn():void {
			this.mouseEnabled = true;
			if (pauseCallback != null) {
				pauseCallback();
			}
		}
		
		
		protected function animateOff():void {	
			TweenMax.to(resumeButton, 0.3, { x:700, immediateRender:true, ease:Strong.easeOut } );
			TweenMax.to(quitButton, 0.3, { x:-700, immediateRender:true, ease:Strong.easeOut } );			
			TweenMax.fromTo(bg, 0.4, { alpha:1 }, { alpha:0, immediateRender:true, onComplete:remove } );
		}
		
		
		protected function remove():void {
			if (parent) parent.removeChild(this);
		}
		
		
		
		protected function onClickResume(e:MouseEvent):void {
			animateOff();
			
			// make sure this doesn't trigger another pause menu
			e.stopImmediatePropagation();
			
			if (resumeCallback != null) {
				resumeCallback();
			}
		}
		
		
		protected function onClickQuit(e:MouseEvent):void {
			if (quitCallback != null) {
				quitCallback();
			}			
			animateOff();
		}
		
		
		
	}

}