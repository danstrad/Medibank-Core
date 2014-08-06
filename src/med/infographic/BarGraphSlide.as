package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class BarGraphSlide extends _BarGraph implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var inputVars:Object;
		
		protected var graph:BarGraph;

		public function BarGraphSlide(slideData:InfographicSlideData, initialBackgroundColor:uint, inputVars:Object) {
			this.inputVars = inputVars;
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";
			
			graph = new BarGraph(xml, inputVars);
			graph.y = -130;
			addChild(graph);
			
		}
		
		public function animateOn():void {
			graph.arrange();
		}
		
		public function animateOff(callback:Function):void {			
		}		

		public function animate(dTime:Number):void {
		}		

	}

}