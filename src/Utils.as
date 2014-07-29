package  {

	public class Utils {
		
		public static function easeOut(f:Number):Number { return ease(f, 100); }
		public static function easeIn(f:Number):Number { return ease(f, -100); }
		public static function ease(f:Number, ease:Number):Number {
			var e:Number = ease / -100;
			if (e >= 0) return Math.pow(f, 1 + e);
			else return 1 - Math.pow(1 - f, 1 - e);
		}
		
		static public function f(minBound:Number, maxBound:Number, f:Number):Number {
			return Math.max(0, Math.min(1, (f - minBound) / (maxBound - minBound)));
		}
		
	}

}