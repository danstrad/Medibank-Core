package med.infographic {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class DualBarGraph extends Sprite {
		
		protected static const BAR_X:Number = -512;
		protected static const BAR_WIDTH:Number = 970;
		
		
		protected var bars:Vector.<Pick3Bar>;
		
		
		public function DualBarGraph(xml:XML, w:Number, h:Number) {
			var g:Graphics;
			var tf:TextField;
			
			var ct1:ColorTransform;
			var ct2:ColorTransform;
			
			var channels:Array = [];
			for each(var channelXML:XML in xml.channel) {
				var channel:Object = new Object();
				
				if (channelXML.hasOwnProperty("@color")) channel.color = uint(channelXML.@color.toString().replace("#", "0x"));
				else channel.color = 0x744785;
				channel.ct = new ColorTransform(0, 0, 0, 1);
				channel.ct.color = channel.color;
				if (channelXML.hasOwnProperty("@text")) channel.text = channelXML.@text.toString();
				else channel.text = "";
				
				channels.push(channel);
			}
			
			var maxValue:Number = 0;
			
			var categories:Array = [];
			for each(var categoryXML:XML in xml.category) {
				var category:Object = new Object();
				
				if (categoryXML.hasOwnProperty("@text")) category.text = categoryXML.@text.toString();
				else category.text = "";
				
				if (categoryXML.hasOwnProperty("@value1")) category.value1 = parseFloat(categoryXML.@value1.toString());
				else category.value1 = 0;
				if (categoryXML.hasOwnProperty("@value2")) category.value2 = parseFloat(categoryXML.@value2.toString());
				else category.value2 = 0;
				
				maxValue = Math.max(maxValue, category.value1, category.value2);
				
				categories.push(category);
			}
			if (!maxValue) maxValue = 1;
			
			var keyHeight:Number = 60;
			var labelHeight:Number = 45;
			var widthPerCategory:Number = w / categories.length;
			var barWidth:Number = widthPerCategory * 0.4;
			var barSpacing:Number = widthPerCategory * 0.05;
			var categorySpacing:Number = widthPerCategory * 0.15;
			var barHeight:Number = h - keyHeight - labelHeight;
			
			g = graphics;
			g.lineStyle(4, 0xFFFFFF, 0.5);
			g.moveTo(0, barHeight);
			g.lineTo(w, barHeight);
			
			var key:MovieClip = new _DualBarGraphKey();
			key.y = 30;
			key.y = h - keyHeight;
			g = key.graphics;
			tf = key.textField1;
			if (channels.length >= 1) {
				channel = channels[0];
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.wordWrap = false;
				tf.text = channel.text + "\n ";
				ct1 = channel.ct;
				g.beginFill(channel.color);
				g.drawCircle(keyHeight * 0.25, keyHeight * 0.25, keyHeight * 0.2);
				g.endFill();
			} else {
				tf.text = "";
				ct1 = new ColorTransform();
			}
			tf = key.textField2;
			if (channels.length >= 2) {
				channel = channels[1];
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.wordWrap = false;
				tf.text = channel.text + "\n ";
				ct2 = channel.ct;
				g.beginFill(channel.color);
				g.drawCircle(keyHeight * 0.25, keyHeight * 0.75, keyHeight * 0.2);
				g.endFill();
			} else {
				tf.text = "";
				ct2 = new ColorTransform();
			}
			addChild(key);
			
			bars = new Vector.<Pick3Bar>();
			for (var i:int = 0; i < categories.length; i++) {
				var categoryX:Number = (i + 0.5) * widthPerCategory;

				category = categories[i];
				var label:MovieClip = new _DualBarGraphCategoryLabel();
				tf = label.textField;
				tf.autoSize = TextFieldAutoSize.CENTER;
				tf.wordWrap = false;
				tf.text = (category.text || "") + "\n ";
				label.x = categoryX;
				label.y = barHeight;
				addChild(label);				
								
				addBar(category.value1, maxValue, ct1, categoryX - (barWidth + barSpacing) / 2, barWidth, barHeight);
				addBar(category.value2, maxValue, ct2, categoryX + (barWidth + barSpacing) / 2, barWidth, barHeight);
			}
			
						
		}
		
		protected function addBar(value:Number, maxValue:Number, ct:ColorTransform, barX:Number, barWidth:Number, maxHeight:Number):void {
			const TEXT_ALLOWANCE:Number = 20;
			var h:Number = maxHeight - TEXT_ALLOWANCE;
			var f:Number = value / maxValue;
			
			var bar:MovieClip = new _DualBarGraphBar();
			var bg:MovieClip = bar.bg;
			bg.width = barWidth;
			bg.height = f * h;
			bg.transform.colorTransform = ct;
			
			var tf:TextField = bar.textField;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.wordWrap = false;
			tf.text = "" + value + "\n ";
			bar.x = barX;
			bar.y = TEXT_ALLOWANCE + (1 - f) * h;
			addChild(bar);
		}
		
		public function showFinalValues():void {
			for each(var bar:Pick3Bar in bars) {
				bar.x = BAR_X + bar.value * BAR_WIDTH;
				bar.barWidth = bar.value * BAR_WIDTH;
				bar.textField.x = -5 - bar.textField.width;
			}
		}

	}

}

