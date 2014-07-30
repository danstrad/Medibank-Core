package med.infographic {

	public class InfographicSlideData {

		
		
		// slide type constants
		public static const CENTER_TEXT_BOX:String 				= "center_text_box";		// a simple text box (text in center of screen)					
		public static const CENTER_TEXT_BOX_QUOTE:String 		= "center_text_box_quote";	// text box with different font sizes and weights (end of info6)
		
		public static const PEOPLE_GRAPH:String					= "people_graph";		// a "moving dots" graph
		
		public static const NUMBER_STRIP:String					= "number_strip";			// a "number strip" where each number slot roattes up/down until it reaches the correct value
		
		public static const FULLSCREEN_TEXT_TOP:String			= "fullscreen_text_top";	// fullscreen text on background with the text at the top (see info4)
		public static const FULLSCREEN_TEXT_CENTER:String		= "fullscreen_text_center";	// fullscreen text on background with the text in the center (see info4)
		public static const FULLSCREEN_TEXT_NUMBER:String		= "fullscreen_text_number";	// a fullscreen number-based text
		
		public static const FALLING_TAGS:String					= "falling_tags";	// falling tags with text on the left side of the background (info1)
		
		public static const FULLSCREEN_IMAGE:String				= "image";
		public static const CLOCK_ANIMATION:String				= "clock";		// clock animation with text (info4)
		
		public static const TIMELINE_WITH_NUMBER:String			= "timeline_number";	// fullscreen number-based text with timeline (info4)
		public static const TIMELINE:String	 					= "timeline";   // fullscreen simple text with timeline (info5)
		
		public static const FLOATING_BOXES_TEXT:String			= "floating_boxes";		// floating boxes with single line of text on left (info2)
		public static const FLOATING_BOXES_NUMBER:String		= "floating_boxes_number";	// floating boxes with a prominent number (info4)
		
		public static const HOTSPOT:String						= "hotspot";	// image background with clickable hotspots
		
				

		
		public var type:String;
		
		public var textColor:uint;
		public var backgroundColor:uint;
		public var boxColor:uint;
		
		public var featuredText:String;
		public var featuredNumber:String;
		
<<<<<<< HEAD
		public var data:Object;
=======
		public var displayTimeMsec:Number;

>>>>>>> 4109ff1686e2c70aeaf18e08757c490ad2697e2a
		
		
		public function InfographicSlideData() {
			
		}

		
		
	}

}