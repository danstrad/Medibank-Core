package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class PieGraphSlide extends _PieGraph implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;

		protected static const RADIUS:Number = 135;
		protected static const LABEL_RADIUS:Number = 145;
		protected static const GRAPH_OFFSET:Number = 35;
		
		protected var angleOffset:Number;
		
		protected var totalValue:Number;
		
		protected var slices:Vector.<Slice>;
		
		protected var graphContainer:Sprite;
		protected var graphColor:Sprite;
		protected var graphErase:Sprite;
		
		
		public function PieGraphSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("subtitle")) subtitleField.text = xml.subtitle[0].toString();
			else subtitleField.text = "";
						
			angleOffset = -0.25 * Math.PI * 2;
			if (xml.hasOwnProperty("appearance")) {
				var appearanceXML:XML = xml.appearance[0];
				angleOffset += (parseFloat(appearanceXML.@startAngle) || 0) * (Math.PI / 180);
			}

			totalValue = 0;
			slices = new Vector.<Slice>();
			for each(var sliceXML:XML in xml.slice) {
				var text:String = TextUtils.safeText(sliceXML.@text.toString());
				var value:Number = parseFloat(sliceXML.@value.toString());
				var slice:Slice = new Slice(text, value);
				slices.push(slice);
				totalValue += value;
			}
			
			graphContainer = new Sprite();
			addChild(graphContainer);
			graphContainer.y = GRAPH_OFFSET;
			graphContainer.blendMode = BlendMode.LAYER;
			
			graphColor = new Sprite();
			graphContainer.addChild(graphColor);
			
			graphErase = new Sprite();
			graphContainer.addChild(graphErase);
			graphErase.blendMode = BlendMode.ERASE;

			var f:Number = 0;
			for each(slice in slices) {
				slice.startFraction = f;
				slice.fraction = slice.value / totalValue;
				f += slice.fraction;
				
				var angle:Number = angleOf(slice.startFraction + slice.fraction / 2);
				var x:Number = Math.cos(angle) * LABEL_RADIUS;
				var y:Number = Math.sin(angle) * LABEL_RADIUS;
				var label:MovieClip = label = new _PieGraphLabel();
				var textField:TextField = label.textField;
				textField.autoSize = TextFieldAutoSize.LEFT;
				textField.wordWrap = false;
				textField.text = slice.text + "\n" + Math.round(slice.fraction * 100) + "%";
				
				if (x > 0) label.x = x;
				else label.x = x - label.width;
				if (y > 0) label.y = y;
				else label.y = y - label.height;
				graphContainer.addChild(label);
			
				slice.spoke = new Shape();
				graphErase.addChild(slice.spoke);
				slice.spoke.rotation = angleOf(slice.startFraction) * 180 / Math.PI;
			}
			
			
			redraw();
							
		}
		
		protected function angleOf(f:Number):Number {
			return f * (Math.PI * 2) + angleOffset;
		}
		
		protected function redraw():void {
			var g:Graphics = graphContainer.graphics;

			g = graphColor.graphics;
			g.clear();			
			g.beginFill(0xFFFFFF, 0.2);
			g.drawCircle(0, 0, RADIUS);
			g.endFill();

			const W:Number = 1.5;
			g = graphErase.graphics;
			g.clear();
			g.beginFill(0x0);
			g.drawCircle(0, 0, W / 2);
			g.endFill();
			for each(var slice:Slice in slices) {
				var spoke:Shape = slice.spoke;
				g = spoke.graphics;
				g.clear();
				g.beginFill(0x0);

				g.drawRect(0, -W / 2, RADIUS * 1.05, W);
				g.endFill();
			}
			

			/*
			g.lineStyle(0, 0xFFFFFF, 0.4);
			for each(var slice:Slice in slices) {
				g.beginFill(0xFFFFFF, 0.25);
				drawSlice(g, RADIUS, slice.startFraction, slice.startFraction + slice.fraction);
				g.endFill();
			}
			*/
			
		}
		
		protected function drawSlice(g:Graphics, radius:Number, start:Number, end:Number):void {
			g.moveTo(0, 0);
			for (var f:Number = start; f < end; f += 0.002) {
				var angle:Number = angleOf(f);
				g.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
			}
			angle = angleOf(end);
			g.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
			g.lineTo(0, 0);			
		}
		
		public function animateOn():void {
			/*
			var t:Number = 0;
			titleField.x = -SCROLL_X - titleField.width / 2;
			TweenMax.to(titleField, SCROLL_TIME, { x:(-titleField.width / 2), ease:Quad.easeOut } );
			subtitleField.x = -SCROLL_X - subtitleField.width / 2;
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(-subtitleField.width / 2), ease:Quad.easeOut } );
			t += SCROLL_TIME;
			*/
			//TweenMax.to(this, t, { onComplete:startTimeDials } );
		}
		
		public function animateOff(callback:Function):void {
			/*
			var t:Number = 0;			
			TweenMax.to(titleField, SCROLL_TIME, { x:(SCROLL_X - titleField.width / 2), ease:Quad.easeIn } );
			TweenMax.to(subtitleField, SCROLL_TIME, { x:(SCROLL_X - subtitleField.width / 2), ease:Quad.easeIn } );
			t += SCROLL_TIME;			
			*/
			//TweenMax.to(this, t, { onComplete:finishedCallback, onCompleteParams:[this] } );
		}
		
		public function animate(dTime:Number):void {
		}

		
	}

}
import flash.display.MovieClip;
import flash.display.Shape;

class Slice {
	public var text:String;
	public var value:Number;
	
	public var startFraction:Number;
	public var fraction:Number;

	public var label:MovieClip;
	public var spoke:Shape;
	
	public function Slice(text:String, value:Number) {
		this.text = text;
		this.value = value;		
	}
}