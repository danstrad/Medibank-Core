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
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
		}

				
		
		public static function fillText(textField:TextField, text:String, regularFormat:TextFormat, boldFormat:TextFormat, addGaps:Boolean = true):void {
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

		
		public static function safeText(text:String):String {
			text = text.replace(/\n\r/ig, '\n');
			text = text.replace(/\r\n/ig, '\n');
			text = text.replace(/\r/ig, '\n');
			return text;
		}
		
		
	}

}