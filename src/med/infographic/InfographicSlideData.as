package med.infographic {

	public class InfographicSlideData {


		// simplified version
		public var type:String;		
		public var displayTimeMsec:Number;	
		public var xml:XML;
		
		// temporary info to pass from infographic to slide
		public var currentColors:Vector.<uint>;
		
		public var currentTextColor:uint;
		public var currentBoxColor:uint;
		public var currentBackgroundColor:uint;
		public var currentGraphColor1:uint;
		public var currentGraphColor2:uint;
		public var currentSelectionColor:uint;
		
		
		
		public function InfographicSlideData(type:String, displayTimeMsec:int, xml:XML) {
			this.type = type;
			this.xml = xml;
			this.displayTimeMsec = displayTimeMsec;	
		}
		
		
		//--------------------------------------------------------------------------------------
		// helper functions to quickly grab often-used (but not universal) things from the xml		
		//--------------------------------------------------------------------------------------
		/*
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
		*/
		
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
		
		public static const TIMELINE:String	 					= "timeline";   		// fullscreen simple text with timeline (info5)
		public static const TIMELINE_NUMBER:String	 			= "timeline_number";   		// timeline with flipNumber (info4)
		
		public static const SLIDING_TAGS:String					= "sliding_tags";	// sliding tags with text on the left side of the background (info1)
		public static const FLOATING_BOXES:String				= "floating_boxes";		// floating boxes with a number
		
		public static const CLOCK_ANIMATION:String				= "clock";		// clock animation with text (info4)
		
		
		
		public static const HOTSPOT:String						= "hotspot";	// image background with clickable hotspots
		
		public static const SPLASH_TEXT:String					= "splash_text";	// plain bold text, with or without image
		
		public static const TIME_DIALS:String					= "time_dials";	// dials to show different number of hours
		public static const CLOCK:String						= "clock";	// clock with circular wipe to reveal text

		public static const PICK3_INPUT:String					= "pick3_input";	// pick 3 options from 12 toggleable boxes
		public static const PICK3_RESULTS:String				= "pick3_results";	// display the chosen options in a graph of predefined data for each option

		public static const CHAPTER_SUMMARY:String				= "chapter_summary";	// animation moving through the headers of the 3 chapters
		
		public static const PIE_GRAPH:String					= "pie_graph";	// a pie graph
		public static const BAR_GRAPH:String					= "bar_graph";	// bare bones version of Pick3Results
		public static const DUAL_BAR_GRAPH:String				= "dual_bar_graph";	// vertical bar graph with 2 channels displayed side by side for each category
		
		public static const CAPTIONED_IMAGES:String				= "captioned_images";	// A list of images with possibly multiple captions sliding on the side
		public static const CAPTIONED_VIDEO:String				= "captioned_video";

		public static const VIDEO:String						= "video";	// video playing with optional splash text or text popups
		
		public static const RESET:String						= "reset";	// prompts the user to reset the infographic. Infographic plays from the first slide again when a reset slide is removed
		
				


		
		
	}

}