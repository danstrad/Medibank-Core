package med.infographic {

	public class InfographicSlideData {


		// simplified version
		public var type:String;		
		public var displayTimeMsec:Number;	
		public var xml:XML;
		
		
		public function InfographicSlideData(type:String, displayTimeMsec:int, xml:XML) {
			this.type = type;
			this.xml = xml;
			this.displayTimeMsec = displayTimeMsec;	
		}
		
		
		//--------------------------------------------------------------------------------------
		// helper functions to quickly grab often-used (but not universal) things from the xml		
		//--------------------------------------------------------------------------------------
		
		public function get backgroundColor():uint {
			if (xml.hasOwnProperty("appearance") && xml.appearance.hasOwnProperty("@backgroundColor")) {
				return uint(xml.appearance.@backgroundColor.toString().replace("#", "0x"));
			} else {
				return 0;
			}
		}
		
		public function get boxColor():uint {
			if (xml.hasOwnProperty("appearance") && xml.appearance.hasOwnProperty("@boxColor")) {
				return uint(xml.appearance.@boxColor.toString().replace("#", "0x"));	
			} else {
				return 0;
			}
		}
		
		public function get textColor():uint {
			if (xml.hasOwnProperty("appearance") && xml.appearance.hasOwnProperty("@textColor")) {
				return uint(xml.appearance.@textColor.toString().replace("#", "0x"));	
			} else {
				return 0;
			}
		}		
		
		
		public function get animateOn():String {
			return xml.@animateOn;	
		}

		public function get animateOff():String {
			return xml.@animateOff;	
		}
		
		
		// slide type constants
		public static const CENTER_TEXT_BOX:String 				= "center_text_box";		// a simple text box (text in center of screen)					
		public static const CENTER_TEXT_BOX_QUOTE:String 		= "center_text_box_quote";	// text box with different font sizes and weights (end of info6)
		
		public static const PEOPLE_GRAPH:String					= "people_graph";		// a "moving dots" graph		
		public static const SPIN_NUMBER_STRIP:String			= "spin_number";			// a "number strip" where each number slot rotates up/down until it reaches the correct value
		public static const FLIP_NUMBER:String					= "flip_number";		// a fullscreen number-based text that acts like a flipboard
		
		
		public static const FULLSCREEN_TEXT_TOP:String			= "fullscreen_text_top";	// fullscreen text on background with the text at the top (see info4)
		
		public static const SLIDING_TAGS:String					= "sliding_tags";	// sliding tags with text on the left side of the background (info1)
		public static const FLOATING_BOXES:String				= "floating_boxes";		// floating boxes with a number
		
		public static const CLOCK_ANIMATION:String				= "clock";		// clock animation with text (info4)
		
		public static const TIMELINE_WITH_NUMBER:String			= "timeline_number";	// fullscreen number-based text with timeline (info4)
		public static const TIMELINE:String	 					= "timeline";   // fullscreen simple text with timeline (info5)
		
		
		public static const HOTSPOT:String						= "hotspot";	// image background with clickable hotspots
		
		public static const SPLASH_TEXT:String					= "splash_text";	// plain bold text, with or without image
		
		public static const TIME_DIALS:String					= "time_dials";	// dials to show different number of hours

		public static const PICK3_INPUT:String					= "pick3_input";	// pick 3 options from 12 toggleable boxes
		public static const PICK3_RESULTS:String				= "pick3_results";	// display the chosen options in a graph of predefined data for each option

		public static const CHAPTER_SUMMARY:String				= "chapter_summary";	// animation moving through the headers of the 3 chapters
		
				


		
		
	}

}