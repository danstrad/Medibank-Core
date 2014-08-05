package med.infographic {
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class ChapterSummarySlide extends Sprite implements ISlide {
		
		protected static const WIPE_DURATION:Number = 500;
		
		protected var previousSlide:Sprite;
		protected var finishedCallback:Function;
		
		protected var wipes:Vector.<ChapterSummaryWipe>;
		protected var currentWipeIndex:int;
		
		protected var isFinished:Boolean;
		
		public function ChapterSummarySlide(slideData:InfographicSlideData, initialBackgroundColor:uint, previousSlide:Sprite) {
			this.previousSlide = previousSlide;
			
			var xml:XML = slideData.xml;
			
			wipes = new Vector.<ChapterSummaryWipe>();
			
			var wipe:ChapterSummaryWipe = new ChapterSummaryWipe();
			if (previousSlide) wipe.addChild(previousSlide);
			wipe.startTime = 0;
			wipe.duration = 0;
			wipes.push(wipe);
			
			for each(var wipeXML:XML in xml.wipe) {
				wipe = new ChapterSummaryWipe();
				wipe.drawColor(uint(wipeXML.@color.toString().replace("#", "0x")));
				wipe.source = wipeXML.@source.toString() || "right";
				wipe.animationType = wipeXML.@animation.toString().toLowerCase();
				
				var box:MovieClip = new _ChapterSummaryBox();
				var textField:TextField = box.textContainer.textField;
				textField.text = wipeXML.@text || "";
				textField.setTextFormat(TextUtils.infographicChapterHeaderFormat, 0, textField.text.length - 1);
				box.blendMode = BlendMode.LAYER;
				
				wipe.addChild(box);
				wipes.push(wipe);				
			}
			
			var duration:Number = parseFloat(xml.@duration) || 12000;
			var durationPerWipe:Number = duration / (wipes.length - 1);
			var t:Number = 0;
			for (var i:int = 1; i < wipes.length; i++) {
				wipe = wipes[i];
				wipe.startTime = t;
				wipe.duration = durationPerWipe;
				t += wipe.duration;

				wipe.initAnimation();
			}
			
		}
		
		
		public function animateOn():void {
			addChild(wipes[0]);
			currentWipeIndex = 0;
			
			showNextWipe();
		}
		
		protected function showNextWipe():void {
			currentWipeIndex++;
			if (currentWipeIndex >= wipes.length) {
				// slide off
			} else {
				var newWipe:ChapterSummaryWipe = wipes[currentWipeIndex];
				addChild(newWipe);
				newWipe.wipeProgress = 0;
				newWipe.durationProgress = 0;
				newWipe.delayAnimation(WIPE_DURATION);
				TweenMax.to(newWipe, WIPE_DURATION / 1000, { wipeProgress:1, ease:Quad.easeOut, onComplete:wipeCompleted } );
				TweenMax.to(newWipe, newWipe.duration / 1000 - 0.5, { durationProgress:1, delay:0.5, ease:Linear.easeNone, onComplete:showNextWipe } );				
				
				if (currentWipeIndex == (wipes.length - 1)) {
					//var offStart:Number = newWipe.getScrollOffTime() / 1000;
					//var offDuration:Number = ((newWipe.duration / 1000) - offStart) * 2;
					var offDuration:Number = 0.5;
					var offStart:Number = newWipe.duration / 1000 - offDuration / 2;
					TweenMax.to(this, offDuration, { x:( -1024), delay:offStart, ease:Linear.easeNone, onComplete:finishedSlidingOff } );			
					
				}
			}
		}
		
		protected function wipeCompleted():void {
			if (currentWipeIndex == 0) return;
			var prevWipe:ChapterSummaryWipe = wipes[currentWipeIndex - 1];
			if (prevWipe.parent) prevWipe.parent.removeChild(prevWipe);
		}
				
		
		public function animateOff(callback:Function):void {
			finishedCallback = callback;
			if (isFinished) finishedCallback(this);
		}
		protected function finishedSlidingOff():void {
			isFinished = true;
			if (finishedCallback != null) finishedCallback(this);
		}
		
		
		public function animate(dTime:Number):void {
			for each(var wipe:ChapterSummaryWipe in wipes) {
				if (wipe.parent) wipe.animate(dTime);
			}
		}
		
		
	}

}