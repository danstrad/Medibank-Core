package com.garin {
	import com.gskinner.utils.Rndm;
	
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
		
		
		public static function shuffle(array:Array, seedRandomizer:Rndm = null):Array {
            // returns a copy
            var shuffled:Array = [];
            if (array == null) return shuffled;
             
            // copy to temp array
            var temp:Array = array.slice();
            var i:int;
 
            // shuffle temp array into new array
            if (seedRandomizer == null) {
                while (temp.length) {
                    i = randomInt(0, temp.length - 1);
                    shuffled = shuffled.concat(temp.splice(i, 1));              
                }
             
            } else {
                while (temp.length) {
                    i = seedRandomizer.integer(0, temp.length);
                    shuffled = shuffled.concat(temp.splice(i, 1));      
                }
            }
 
            return shuffled;
        }		
		
		
		static private function randomInt(min:int, max:int, rndm:Rndm = null):int {          
            if (rndm == null)           return Math.round(Math.random() * (max - min)) + min;
            else                        return rndm.integer(min, max+1);
        }		
		
	}

}