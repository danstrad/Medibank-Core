package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class Pick3ResultsSlide extends _Pick3ResultsSlide implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var inputVars:Object;
		protected var finishedCallback:Function;
		
		protected var graph:BarGraph;

		public function Pick3ResultsSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, inputVars:Object, finishedCallback:Function) {
			this.inputVars = inputVars;
			this.finishedCallback = finishedCallback;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";
			
			graph = new BarGraph(slideData, inputVars);
			graph.y = -180;
			addChild(graph);
			
			nextButton.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);			
		}
		
		public function animateOn():void {
			var t:Number = 0;
			titleField.x = -SCROLL_X - titleField.width / 2;
			TweenMax.to(titleField, SCROLL_TIME, { x:(-titleField.width / 2), ease:Quad.easeOut } );
			subtitleField.x = -SCROLL_X - subtitleField.width / 2;
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(-subtitleField.width / 2), ease:Quad.easeOut } );
			nextButton.alpha = 0;
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:1, ease:Quad.easeOut } );
			t += SCROLL_TIME;

			const BAR_START:Number = 0.3;
			const BAR_LENGTH:Number = 0.5;
			const TEXT_START:Number = 0.6;
			const TEXT_LENGTH:Number = 0.3;
			graph.animateOn(BAR_START, BAR_LENGTH, TEXT_START, TEXT_LENGTH);
			
			t = Math.max(t, BAR_START + BAR_LENGTH, TEXT_START + TEXT_LENGTH);
		}
		
		public function animateOff(callback:Function):void {
			var t:Number = 0;
			TweenMax.to(titleField, SCROLL_TIME, { x:(SCROLL_X - titleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(SCROLL_X - subtitleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(nextButton, SCROLL_TIME, { alpha:0, ease:Quad.easeIn } );
			t += SCROLL_TIME;
			
			const BAR_START:Number = 0.4;
			const BAR_LENGTH:Number = 0.5;
			const TEXT_START:Number = 0.3;
			const TEXT_LENGTH:Number = 0.3;
			graph.animateOff(BAR_START, BAR_LENGTH, TEXT_START, TEXT_LENGTH);
			
			t = Math.max(t, BAR_START + BAR_LENGTH, TEXT_START + TEXT_LENGTH);
			TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
		}		

		protected function handleMouseDown(event:MouseEvent):void {
			if (event.target == nextButton) {
				animateOff(finishedCallback);
			}
		}
		
	}

}