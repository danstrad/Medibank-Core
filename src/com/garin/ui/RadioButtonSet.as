package com.garin.ui {
	
	/**
	 * Handles sets of buttons where only one can be selected at a time
	 * @author Daniel Stradwick "garin"
	 */
	
	public class RadioButtonSet {
		
		private var buttons:Array;
		private var callback:Function;
		
		public function RadioButtonSet(buttonClips:Array, callbackFunction:Function) {
			this.buttons = buttonClips;
			this.callbackFunction = callbackFunction;
		}
		
	}

}