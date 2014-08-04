package med.infographic {	import com.greensock.easing.Quad;	import com.greensock.TweenMax;	import flash.display.BlendMode;	import flash.display.Graphics;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.MouseEvent;	public class TimeDial extends _TimeDial {				public var input:Boolean;		public var color:uint;				public var title:String;		public var variable:String;		public var value:Number;		protected var animateValue:Number;		protected var drawnValue:Number;				protected var clock:Sprite;		protected var centreCircle:Sprite;		protected var spokes:Vector.<Shape>;		protected var startHand:Sprite;		protected var endHand:Sprite;				public var inputEnabled:Boolean;				protected var animatingOut:Boolean;				protected var animatingIn:Boolean;				protected var animateTime:Number;		protected static const ANIMATE_TIME:Number = 300;						public function TimeDial() {			drawnValue = 0;			if (!value) value = 0;						titleField.alpha = 0;						clock = new Sprite();			addChild(clock);						var g:Graphics;			var hit:Sprite = new Sprite();			g = hit.graphics;			g.beginFill(0x0);			g.drawCircle(0, 0, 110);			g.endFill();			hit.visible = false;			addChild(hit);			hitArea = hit;						spokes = new Vector.<Shape>();			for (var i:int = 0; i < 12; i++) {				var spoke:Shape = new Shape();				g = spoke.graphics;				g.beginFill(0xFFFFFF);				g.drawRect( -1.5, -126, 3, 18);				g.endFill();				spoke.rotation = i * 360 / 12;				spoke.scaleY = 0;				addChild(spoke);				spokes.push(spoke);			}						startHand = new Sprite();			endHand = new Sprite();			for each(var hand:Sprite in [startHand, endHand]) {				var HAND_RAD:Number = 6;				var HAND_LEN:Number = 96;				var arm:Shape = new Shape();				g = arm.graphics;				g.beginFill(0xFFFFFF);				g.drawCircle(HAND_LEN - HAND_RAD, 0, HAND_RAD);				g.endFill();				hand.addChild(arm);				var circle:Shape = new Shape();				g = circle.graphics;				g.beginFill(0xFFFFFF);				g.drawRect(20, -HAND_RAD, HAND_LEN - HAND_RAD - 20, HAND_RAD * 2);				g.endFill();				hand.addChild(circle);				clock.addChild(hand);				hand.scaleX = 0;				hand.rotation = -90;			}						centreCircle = new Sprite();			var s:Shape = new Shape();			g = s.graphics;			g.beginFill(0xFFFFFF);			g.drawCircle(0, 0, 22);			g.endFill();						clock.addChild(centreCircle);			centreCircle.addChild(s);			centreCircle.addChild(valueField);						clock.blendMode = BlendMode.LAYER;			valueField.blendMode = BlendMode.ERASE;						centreCircle.scaleX = centreCircle.scaleY = 0;					}				public function animateOn():void {			animateValue = value;			drawValue(0);			if (title) titleField.text = title;						var t:Number = 0;			TweenMax.to(titleField, 1, { alpha:1, delay:t, ease:Quad.easeOut } );			t += 0.5;			TweenMax.to(centreCircle, 0.2, { scaleX:1.1, scaleY:1.1, delay:t, ease:Quad.easeOut } );			TweenMax.to(centreCircle, 0.02, { scaleX:1, scaleY:1, delay:t + 0.2, ease:Quad.easeIn } );			t += 0.3;			for each(var spoke:Shape in spokes) {				TweenMax.to(spoke, 0.15, { scaleX:1.05, scaleY:1.05, delay:t, ease:Quad.easeOut } );				TweenMax.to(spoke, 0.015, { scaleX:1, scaleY:1, delay:t + 0.15, ease:Quad.easeIn } );			}			t += 0.2;			for each(var hand:Sprite in [startHand, endHand]) {				TweenMax.to(hand, 0.25, { scaleX:1.05, scaleY:1.05, delay:t, ease:Quad.easeOut } );				TweenMax.to(hand, 0.025, { scaleX:1, scaleY:1, delay:t + 0.25, ease:Quad.easeIn } );			}						t += 0.2;			TweenMax.to(this, t, { onComplete:onAnimateOnComplete } );						addEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false, 0, true);		}				protected function onAnimateOnComplete():void {			animatingOut = true;			animateTime = 0;		}				public function animateOff():void {			inputEnabled = false;						removeEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false);			if (stage) {				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove, false);				stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragRelease, false);			}						animateValue = value;						animatingIn = true;			animateTime = 0;		}				protected function retract():void {						var t:Number = 0;						TweenMax.to(titleField, 0.4, { alpha:0, delay:t, ease:Quad.easeIn } );			for each(var hand:Sprite in [startHand, endHand]) {				TweenMax.to(hand, 0.25, { scaleX:0, scaleY:0, delay:t, ease:Quad.easeIn } );			}			t += 0.2;			for each(var spoke:Shape in spokes) {				TweenMax.to(spoke, 0.15, { scaleX:0, scaleY:0, delay:t, ease:Quad.easeIn } );			}			t += 0.2;			TweenMax.to(centreCircle, 0.2, { scaleX:0, scaleY:0, delay:t, ease:Quad.easeIn } );					}				public function animate(dTime:Number):void {			if (animatingOut) {				animateTime = Math.min(animateTime + dTime, ANIMATE_TIME);				value = (animateTime / ANIMATE_TIME) * animateValue;				drawValue(value);				animatingOut = (animateTime < ANIMATE_TIME);				if (!animatingOut) inputEnabled = true;			} else if (animatingIn) {				animateTime = Math.min(animateTime + dTime, ANIMATE_TIME);				value = (1 - animateTime / ANIMATE_TIME) * animateValue;				drawValue(value);				animatingIn = (animateTime < ANIMATE_TIME);				if (!animatingIn) retract();			} else if (inputEnabled) {				var dv:Number = value - drawnValue;				if (dv) {					dv *= (dTime / 100);					drawValue(drawnValue + dv);				}			}		}						protected function drawValue(v:Number):void {			drawnValue = v;			valueField.text = "" + Math.round(drawnValue) + "h";			var a:Number = (drawnValue / 12) * (Math.PI * 2);			var g:Graphics = clock.graphics;			g.clear();			g.beginFill(color);			g.moveTo(0, 0);			const R:Number = 90;						for (var f:Number = 0; f < a; f += Math.PI / 360) {				var angle:Number = -Math.PI / 2 + f;				g.lineTo(Math.cos(angle) * R, Math.sin(angle) * R);			}			angle = -Math.PI / 2 + a;			g.lineTo(Math.cos(angle) * R, Math.sin(angle) * R);			g.lineTo(0, 0);			g.endFill();			endHand.rotation = angle * 180 / Math.PI;		}				protected function handleBeginDrag(event:MouseEvent):void {			if (!inputEnabled || !input) return;			dragToMouse(true);			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMove, false, 0, true);			stage.addEventListener(MouseEvent.MOUSE_UP, handleDragRelease, false, 0, true);		}				protected function handleDragMove(event:MouseEvent):void {			dragToMouse(false);		}				protected function handleDragRelease(event:MouseEvent):void {			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove, false);			stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragRelease, false);		}				protected function dragToMouse(alwaysAcceptValue:Boolean):void {			var angle:Number = (Math.atan2(mouseY, mouseX) + Math.PI * 2.5) % (Math.PI * 2);			var newValue:Number = angle / (Math.PI * 2) * 12;						if (alwaysAcceptValue) {				value = newValue;			} else if (newValue - value > 6) {				value = 0;			} else if (newValue - value < -6) {				value = 12;			} else {							value = newValue;			}		}			}}