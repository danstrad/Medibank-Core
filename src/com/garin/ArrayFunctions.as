package com.garin {
	
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class ArrayFunctions {
		
		public static function removeElementFrom(a:Array, element:*):Boolean {
			for (var i:int = 0; i < a.length; i++) {
				if (a[i] == element) {
					a.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		
		public static function removeDuplicatesFrom(array:Array):Array {
			var a:Array = array.slice();
			
			for (var i:int = 0; i < array.length; i++) {
				
				for (var j:int = i+1; j < array.length; j++) {					
					if (a[i] == a[j]) {
						a.splice(j, 1);
					}
				}
			}
			
			return a;
		}
		
	}

}