package  {
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextUtils {
		
		public static var chapterHeaderFormat:TextFormat;
		public static var storyHeaderFormat:TextFormat;
		public static var quoteFormat:TextFormat;
		public static var contentFormat:TextFormat;
		public static var contentHeaderFormat:TextFormat;
		public static var contentBoldFormat:TextFormat;
		public static var contentNewlineFormat:TextFormat;
		public static var labelFormat:TextFormat;
		public static var statBoldFormat:TextFormat;
		public static var splashFormat:TextFormat;
		public static var infographicSplashFormat:TextFormat;
		public static var infographicChapterHeaderFormat:TextFormat;
		

		public static function createTextFormats():void {
			var format:TextFormat;			
			chapterHeaderFormat = format = new TextFormat("DINCond-Black", 15);
			format.leading = -5;
			format.letterSpacing = -0.35;
			
			storyHeaderFormat = format = new TextFormat("DIN Bold", 13);
			format.leading = -1;
			format.letterSpacing = -0.35;
			
			quoteFormat = format = new TextFormat("DIN Bold", 20);// 11);
			format.leading = -2;
			format.letterSpacing = -0.35;
			
			contentFormat = format = new TextFormat("DIN", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentHeaderFormat = format = new TextFormat("DIN Bold", 13);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentBoldFormat = format = new TextFormat("DIN Bold", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentNewlineFormat = format = new TextFormat("DIN", 0);
			format.leading = 0;
			
			labelFormat = format = new TextFormat("DIN Bold", 27);
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
			
			statBoldFormat = format = new TextFormat("DIN Bold", 26);
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
			
			splashFormat = format = new TextFormat("DIN Bold", 12);
			format.leading = 0;// -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
			
			
			infographicSplashFormat = format = new TextFormat("DINCond-Black", 50);
			format.leading = -5;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
			
			infographicChapterHeaderFormat = format = new TextFormat("DINCond-Black", 66);
			format.leading = -17;
			format.letterSpacing = -0.35;
			
		}

				
		
		public static function fillText(textField:TextField, text:String, regularFormat:TextFormat, boldFormat:TextFormat, addGaps:Boolean = true):void {
			textField.defaultTextFormat = boldFormat;
			textField.text = "";
			var carat:int = 0
			var len:int;
			var i:int = 0;
			var boldStart:int;
			var boldEnd:int;
			while(true) {
				boldStart = text.indexOf("[b]", i);
				boldEnd = text.indexOf("[/b]", boldStart);
				if ((boldStart >= 0) && (boldEnd >= 0)) {
					len = boldStart - i;
					if (len > 0) {
						textField.appendText(text.substr(i, len));
						textField.setTextFormat(regularFormat, carat, carat + len);
						carat += len;
					}
					len = boldEnd - boldStart - 3;
					if (len > 0) {
						textField.appendText(text.substr(boldStart + 3, len));
						textField.setTextFormat(boldFormat, carat, carat + len);
						carat += len;
					}
				} else {
					len = text.length - i;
					if (len > 0) {
						textField.appendText(text.substr(i, len));
						textField.setTextFormat(regularFormat, carat, carat + len);
						carat += len;
					}
					break;
				}
				i = boldEnd + 4;
			};
			var tft:String = textField.text;
			if (addGaps) {
				for (i = tft.lastIndexOf('\r'); i >= 0; i = tft.lastIndexOf('\r', i - 1)) {
					textField.replaceText(i, i, '\n');
					textField.setTextFormat(contentNewlineFormat, i, i + 1);					
				}
			}
		}		

		
		public static function scaleToFit(textField:TextField, width:Number, height:Number, textScale:Number=1.0, scaleStep:Number=0.05):void {
//			var scale:Number = Math.min(width, height) / (textField.width * textScale);
			var scale:Number = width / (textField.width * textScale);
			textField.scaleX = textField.scaleY = scale;
			textField.width = width / scale;
			textField.height = height / scale;
			
			while (textField.height > height) {
				scale -= scaleStep;
				textField.scaleX = textField.scaleY = scale;
				textField.width = width / textField.scaleX;
				textField.height = height / textField.scaleY;
			}
		}		
		
		
		public static function safeText(text:String):String {
			text = text.replace(/\n\r/ig, '\n');
			text = text.replace(/\r\n/ig, '\n');
			text = text.replace(/\r/ig, '\n');
			return text;
		}
		
		static public function parseTags(textField:TextField, bold:Boolean):void {			
			var text:String = textField.text;
			var scanPos:int = text.length - 1;
			
			var tag:String;
			var tagLength:Number;
			var startIndex:int;
			var endIndex:int;
			var textFormat:TextFormat;
			
			tag = "i";
			tagLength = tag.length;
			while (true) {
				startIndex = text.lastIndexOf("[" + tag + "]", scanPos);
				if (startIndex == -1) break;
				text = text.substr(0, startIndex) + text.substr(startIndex + tagLength + 2);
				textField.replaceText(startIndex, startIndex + tagLength + 2, "");
				endIndex = text.indexOf("[/" + tag + "]", startIndex);
				text = text.substr(0, endIndex) + text.substr(endIndex + tagLength + 3);
				textField.replaceText(endIndex, endIndex + tagLength + 3, "");
				
				textFormat = textField.getTextFormat(startIndex, endIndex);
				if (bold) textFormat.font = "DIN-BoldItalic";
				else textFormat.font = "DIN-RegularItalic";

				textField.setTextFormat(textFormat, startIndex, endIndex);											

				scanPos = startIndex;
			}
					
			tag = "q";
			tagLength = tag.length;
			while (true) {
				startIndex = text.lastIndexOf("[" + tag + "]", scanPos);
				if (startIndex == -1) break;
				text = text.substr(0, startIndex) + text.substr(startIndex + tagLength + 2);
				textField.replaceText(startIndex, startIndex + tagLength + 2, "");
				endIndex = text.indexOf("[/" + tag + "]", startIndex);
				text = text.substr(0, endIndex) + text.substr(endIndex + tagLength + 3);
				textField.replaceText(endIndex, endIndex + tagLength + 3, "");
				
				textFormat = textField.getTextFormat(startIndex, endIndex);
				textFormat.font = "Bree Medibank Regular";

				textField.setTextFormat(textFormat, startIndex, endIndex);											

				scanPos = startIndex;
			}
			
			tag = "bullet";
			tagLength = tag.length;
			while (true) {
				startIndex = text.lastIndexOf("[" + tag + "]", scanPos);
				if (startIndex == -1) break;
				text = text.substr(0, startIndex) + text.substr(startIndex + tagLength + 2);
				textField.replaceText(startIndex, startIndex + tagLength + 2, "");
				endIndex = text.indexOf("[/" + tag + "]", startIndex);
				text = text.substr(0, endIndex) + text.substr(endIndex + tagLength + 3);
				textField.replaceText(endIndex, endIndex + tagLength + 3, "");
				
				textFormat = textField.getTextFormat(startIndex, endIndex);
				textFormat.bullet = true;

				textField.setTextFormat(textFormat, startIndex, endIndex);											

				scanPos = startIndex;
			}
			
		}
		
		
	}

}