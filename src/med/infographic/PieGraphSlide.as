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

	public class PieGraphSlide extends _PieGraphSlide implements ISlide {
		
		protected const SCROLL_TIME:Number = 0.6;
		protected const SCROLL_X:Number = 1200;

		protected static const GRAPH_X:Number = -410 + 450 / 2;
		protected static const GRAPH_Y:Number = 35;
		protected static const GRAPH_OUTER_RADIUS:Number = 185;
		protected static const GRAPH_INNTER_RADIUS:Number = 155;

		protected static const LABEL_X:Number = 52;
		protected static const LABEL_RADIUS:Number = 18;
		protected static const LABEL_SPACING:Number = 6;

		
		protected var angleOffset:Number;
		
		protected var hasCenterText:Boolean;
		
		protected var totalValue:Number;
		
		protected var slices:Vector.<Slice>;
		
		protected var graphContainer:Sprite;
		protected var graphColor:Sprite;
		protected var graphErase:Sprite;
		
		
		public function PieGraphSlide(slideData:InfographicSlideData, initialBackgroundColor:uint) {
			var xml:XML = slideData.xml;
			if (xml.hasOwnProperty("title")) titleField.text = xml.title[0].toString();
			else titleField.text = "";
			if (xml.hasOwnProperty("centerValue")) {
				centerValueField.text = xml.centerValue[0].toString();
				hasCenterText = true;
			} else centerValueField.text = "";
			if (xml.hasOwnProperty("centerText")) {
				centerTextField.text = xml.centerText[0].toString();
				hasCenterText = true;
			} else centerTextField.text = "";
						
			angleOffset = -0.25 * Math.PI * 2;
			if (xml.hasOwnProperty("appearance")) {
				var appearanceXML:XML = xml.appearance[0];
				angleOffset += (parseFloat(appearanceXML.@startAngle) || 0) * (Math.PI / 180);
			}

			totalValue = 0;
			slices = new Vector.<Slice>();
			for each(var sliceXML:XML in xml.slice) {
				var text:String = TextUtils.safeText(sliceXML.@text.toString());
				var subtext:String = TextUtils.safeText(sliceXML.@subtext.toString());
				var valueText:String = TextUtils.safeText(sliceXML.@valueText.toString());
				var value:Number = parseFloat(sliceXML.@value.toString());
				var slice:Slice = new Slice(text, subtext, valueText, value);
				slices.push(slice);
				totalValue += value;
			}
			
			graphContainer = new Sprite();
			addChild(graphContainer);
			graphContainer.x = GRAPH_X;
			graphContainer.y = GRAPH_Y;
			graphContainer.blendMode = BlendMode.LAYER;
			
			graphColor = new Sprite();
			graphContainer.addChild(graphColor);
			
			graphErase = new Sprite();
			graphContainer.addChild(graphErase);
			graphErase.blendMode = BlendMode.ERASE;

			var f:Number = 0;
			var labelY:Number = Math.ceil(GRAPH_Y - GRAPH_OUTER_RADIUS);
			for (var i:int = 0; i < slices.length; i++) {
				slice = slices[i];
				
				slice.alpha = 0.2 + (1 - i / slices.length) * 0.6;
				
				slice.startFraction = f;
				slice.fraction = slice.value / totalValue;
				f += slice.fraction;
				
				var label:MovieClip = label = new _PieGraphLabel();

				// Draw circle centered at a single line label's mid height
				var g:Graphics = label.graphics;
				g.beginFill(0xFFFFFF, slice.alpha);
				g.drawCircle(LABEL_RADIUS, label.textField.height / 2, LABEL_RADIUS);
				g.endFill();				
				
				setLabelText(label, slice);
				
				label.x = LABEL_X;
				label.y = labelY;
				labelY = Math.ceil(labelY + label.height + LABEL_SPACING);
				//label.y = LABEL_Y + LABEL_SPACING * i;
				addChild(label);
				
				

				
				var angle:Number = angleOf(slice.startFraction + slice.fraction / 2);
				var x:Number = Math.cos(angle) * LABEL_RADIUS;
				var y:Number = Math.sin(angle) * LABEL_RADIUS;
				
				slice.spoke = new Shape();
				graphErase.addChild(slice.spoke);
				slice.spoke.rotation = angleOf(slice.startFraction) * 180 / Math.PI;
			}
			
			
			redraw();
							
		}
		
		protected function setLabelText(label:MovieClip, slice:Slice):void {
			var textField:TextField = label.textField;
			var subtextField:TextField = label.subtextField;
			var valueField:TextField = label.valueField;			
			var textX:Number = textField.x;
			var textY:Number = textField.y;
			var textHeight:Number = textField.height;
			var w:Number = (valueField.x + valueField.width - textX);
			
			textField.wordWrap = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = slice.text || "";
			valueField.wordWrap = false;
			valueField.autoSize = TextFieldAutoSize.RIGHT;
			valueField.text = slice.valueText || "";
			
			while (textField.width >= w) {
				textField.scaleX = textField.scaleY = textField.scaleX - 0.05;
			}
			textField.x = textX;
			textField.y = textY + (textHeight - textField.height) / 2;
			
			if (slice.subtext && (slice.subtext.length > 0)) {
				subtextField.wordWrap = false;
				subtextField.autoSize = TextFieldAutoSize.LEFT;
				subtextField.text = slice.subtext;
				subtextField.scaleX = subtextField.scaleY = textField.scaleX;
				while (subtextField.width >= w) {
					subtextField.scaleX = subtextField.scaleY = subtextField.scaleX - 0.05;
				}
				subtextField.x = textX;
				subtextField.y = textY + Math.max(textHeight, textField.height);				
			} else {
				subtextField.visible = false;
			}
			
			var leftWidth:Number = textField.width;
			var leftHeight:Number = Math.max(textHeight, textField.height);
			if (subtextField.visible) {
				leftWidth = Math.max(leftWidth, subtextField.width);
				leftHeight += subtextField.height;
			}

			const GAP:Number = 5;
			if (leftWidth + valueField.width + GAP > w) {
				valueField.y = textY + leftHeight + 1;
			}
		}
		
		protected function angleOf(f:Number):Number {
			return f * (Math.PI * 2) + angleOffset;
		}
		
		protected function redraw():void {
			var g:Graphics = graphContainer.graphics;

			g = graphColor.graphics;
			g.clear();			
			for each(var slice:Slice in slices) {
				g.beginFill(0xFFFFFF, slice.alpha);
				drawSlice(g, GRAPH_OUTER_RADIUS, slice.startFraction, slice.startFraction + slice.fraction);
				g.endFill();
			}

			const W:Number = 1.5;
			g = graphErase.graphics;
			g.clear();
			g.beginFill(0x0);
			if (hasCenterText) g.drawCircle(0, 0, GRAPH_INNTER_RADIUS);
			else g.drawCircle(0, 0, W / 2);
			g.endFill();
			for each(slice in slices) {
				var spoke:Shape = slice.spoke;
				g = spoke.graphics;
				g.clear();
				g.beginFill(0x0);

				g.drawRect(0, -W / 2, GRAPH_OUTER_RADIUS * 1.05, W);
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
	public var subtext:String;
	public var valueText:String;
	public var value:Number;
	
	public var startFraction:Number;
	public var fraction:Number;
	public var alpha:Number;

	public var label:MovieClip;
	public var spoke:Shape;
	
	public function Slice(text:String, subtext:String, valueText:String, value:Number) {
		this.text = text;
		this.subtext = subtext;
		this.valueText = valueText;
		this.value = value;		
	}
}