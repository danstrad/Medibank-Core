package com.garin  {
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.*;
	
	/**
	 * Text and TextField related methods
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Text {
		
		
		public static function setTextMode(tf:TextField, bold:Boolean = false, italic:Boolean = false):void {
			var format:TextFormat = tf.getTextFormat();
			format.bold = bold;
			format.italic = italic;
			tf.setTextFormat(format);
		}

		public static function boldText(tf:TextField):void { setTextMode(tf, true); }


		public static function setTextSpacing(tf:TextField, letterSpacing:Number):void {
			var format:TextFormat = tf.getTextFormat();
			format.letterSpacing = letterSpacing;
			tf.setTextFormat(format);
		}
			
		
		
		
		public static function centerTextfieldVertically(textfield:TextField):void {		
			var oldHeight:Number = textfield.height;
			var oldY:Number = textfield.y;
			textfield.y = oldY + ((oldHeight - textfield.textHeight) * 0.5);
		}
		
		
		public static function capitalize(s:String):String {
			var first:String = s.charAt(0).toUpperCase();
			return first + s.slice(1, s.length);
		}			
		
		public static function dayDateSuffix(dayNumber:int):String {
			if ((dayNumber >= 10) && (dayNumber <= 20))	return "th";
			
			switch (dayNumber % 10) {
				default:
				case 0:		return "th";				
				case 1:		return "st";
				case 2:		return "nd";
				case 3:		return "rd";
			}
		}
		
		
		
		public static function numeralToWord(numeral:uint, recursiveCall:Boolean=false):String {		
			var s:String = "";
			
			var originalNumeral:uint = numeral;
						
			switch (numeral) {
				default:	s += ""; break;
				case 0:		s += "Zero"; break;
				case 1:		s += "One"; break;
				case 2:		s += "Two"; break;
				case 3:		s += "Three"; break;
				case 4:		s += "Four"; break;
				case 5:		s += "Five"; break;
				case 6:		s += "Six"; break;
				case 7:		s += "Seven"; break;
				case 8:		s += "Eight"; break;
				case 9:		s += "Nine"; break;
				case 10:	s += "Ten"; break;
				case 11:	s += "Eleven"; break;
				case 12:	s += "Twelve"; break;
				case 13:	s += "Thirteen"; break;
				case 14:	s += "Fourteen"; break;
				case 15:	s += "Fifteen"; break;
				case 16:	s += "Sixteen"; break;
				case 17:	s += "Seventeen"; break;
				case 18:	s += "Eighteen"; break;
				case 19:	s += "Nineteen"; break;
				case 20:	s += "Twenty"; break;
				case 30:	s += "Thirty"; break;
				case 40:	s += "Forty"; break;
				case 50:	s += "Fifty"; break;
				case 60:	s += "Sixty"; break;
				case 70:	s += "Seventy"; break;
				case 80:	s += "Eighty"; break;
				case 90:	s += "Ninety"; break;
			}
			
			// if we have an answer, return it
			if (s != "")	return s;
			
			
			// otherwise, figure it out
			var thousands:int = 0;
			var hundreds:int = 0;
			var tens:int = 0;
				
			while (numeral >= 1000) {
				numeral -= 1000;
				thousands++;
			}
				
			while (numeral >= 100) {
				numeral -= 100;
				hundreds++;
			}
				
			while (numeral >= 10) {
				numeral -= 10;
				tens++;
			}
				
			if (thousands)											s += numeralToWord(thousands, true) + " Thousand";
			if (thousands && hundreds)								s += ", ";
			if (hundreds)											s += numeralToWord(hundreds, true) + " Hundred";
			if ((hundreds || thousands) && (tens || numeral))		s += " and ";
			if (tens >= 2) {			
				s += numeralToWord(tens * 10, true);
				if (numeral != 0) {
					s += "-";
					s += numeralToWord(numeral, true);
				}					
			} else {
				// teens
				s += numeralToWord(numeral, true);
			}
			
			return s;
		}
		
		
		public static function removeSpaces(str:String):String {
			if ((str == null) || (!str.length))	return "";
			
			while (str.indexOf(" ") != -1) {
				str = str.replace(" ", "");
			}		
		
			return str;
		}
		
		
		public static function replaceSpaces(str:String, replacementChar:String):String {
			if ((str == null) || (!str.length))	return "";
			
			while (str.indexOf(" ") != -1) {
				str = str.replace(" ", replacementChar);
			}		
		
			return str;
		}
		
		
		
		public static function addCommasToNumberString(numberString:String):String {
			if (numberString.length < 4)	return numberString;

			var str:String = "";
			
			
			for (var i:int = numberString.length-3; i > 0; i -= 3) {
				
				// cut off the last 3 digits
				var lastDigits:String = numberString.slice(i, i+3);
				str = "," + lastDigits + str;
			}
				
			if (numberString.length % 3) {
				str = numberString.slice(0, numberString.length % 3) + str;
			}
			
			return str;
		}
		
		
	}

}