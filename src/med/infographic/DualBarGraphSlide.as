package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class DualBarGraphSlide extends _DualBarGraph implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;
		
		protected var graph:DualBarGraph;

		public function DualBarGraphSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";
			
			graph = new DualBarGraph(slideData, 800, 420);
			graph.x = -400
			graph.y = -165;			
			addChild(graph);
			
		}
		
		public function animateOn():void {
			graph.showFinalValues();
		}
		
		public function animateOff(callback:Function):void {			
		}		

		public function animate(dTime:Number):void {
		}		

	}

}