package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	public class BarGraph extends Sprite {
		
		protected static const BAR_X:Number = -512;
		protected static const BAR_WIDTH:Number = 970;
		
		
		protected var bars:Vector.<Pick3Bar>;
		
		
		public function BarGraph(slideData:InfographicSlideData, inputVars:Object) {
			var xml:XML = slideData.xml;
			
			var optionCT1:ColorTransform = new ColorTransform();
			optionCT1.color = slideData.currentGraphColor1;
			var optionCT2:ColorTransform = new ColorTransform();
			optionCT2.color = slideData.currentGraphColor2;
			var selectedOptionCT:ColorTransform = new ColorTransform();
			selectedOptionCT.color = slideData.currentSelectionColor;
			
			bars = new Vector.<Pick3Bar>();
			var barCount:int = 0;
			for each(var barXML:XML in xml.bar) {
				var barID:String = barXML.@id;
				var barText:String = barXML.@text.toString();
				var barValue:Number = parseFloat(barXML.@value.toString());
				var ct:ColorTransform = ((barCount % 2) == 0) ? optionCT1 :optionCT2;
				if (inputVars.pick3Options && (inputVars.pick3Options.indexOf(barID) >= 0)) ct = selectedOptionCT;
				var bar:Pick3Bar = new Pick3Bar(barID, barText, barValue, ct);
				bars.push(bar);
				addChild(bar);
				bar.x = BAR_X;
				bar.y = 32 * barCount;
				barCount++;
			}
						
		}
		
		public function showFinalValues():void {
			for each(var bar:Pick3Bar in bars) {
				bar.x = BAR_X + bar.value * BAR_WIDTH;
				bar.barWidth = bar.value * BAR_WIDTH;
				bar.textField.x = -5 - bar.textField.width;
			}
		}

		public function animateOn(barStart:Number, barLength:Number, textStart:Number, textLength:Number):void {
			for each(var bar:Pick3Bar in bars) {
				bar.x = BAR_X;
				bar.barWidth = 0;
				TweenMax.to(bar, barLength, { x:(BAR_X + bar.value * BAR_WIDTH), barWidth:(bar.value * BAR_WIDTH), delay:barStart, ease:Quad.easeOut } );
				bar.textField.x = 5;
				TweenMax.to(bar.textField, textLength, { x:(-5 - bar.textField.width), delay:textStart, ease:Quad.easeOut } );
			}
		}
		
		public function animateOff(barStart:Number, barLength:Number, textStart:Number, textLength:Number):void {
			for each(var bar:Pick3Bar in bars) {
				TweenMax.to(bar, barLength, { x:BAR_X, barWidth:0, delay:barStart, ease:Quad.easeOut } );
				TweenMax.to(bar.textField, textLength, { x:5, delay:textStart, ease:Quad.easeOut } );
			}
		}
		
		
	}

}