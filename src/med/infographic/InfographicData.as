package med.infographic {

	public class InfographicData {
		
		public var id:String;		
		public var slides:Vector.<InfographicSlideData>;

		
		
		public function InfographicData(xml:XML) {

			this.id = xml.@id.toString();
			
			slides = new Vector.<InfographicSlideData>();
			
			
			for (var i:int = 0; i < xml.slide.length(); i++) {
			
				var slideXML:XML = xml.slide[i];								
				
				var type:String = slideXML.@type;
				
				// how long should the slide stay on the screen?
				// note: this currently includes animate on time, but NOT animate off time
				var displayTimeMsec:int;
				
				if (type == InfographicSlideData.PEOPLE_GRAPH) {
					// calculate duration automatically based on slide count, ignore what's in the xml (if anything)
					displayTimeMsec = (PeopleGraph.ANIMATE_ON_DURATION_SEC + 1.0 + (slideXML.graphstate.length() * PeopleGraph.GRAPH_STATE_DURATION_SEC)) * 1000;	
					
				} else if (type == InfographicSlideData.SPIN_NUMBER_STRIP) {
					// calculate duration automatically based on slide count, ignore what's in the xml (if anything)
					displayTimeMsec = 2000 + ((SpinNumberSlot.MIN_SPIN_TIME_SECS + SpinNumberSlide.AFTER_SPINNING_WAIT_TIME_SECONDS) * slideXML.graphstate.length()) * 1000;
									
				} else if (type == InfographicSlideData.FLIP_NUMBER) {
					// calculate duration automatically based on slide count, ignore what's in the xml (if anything)
					displayTimeMsec = (FlipNumberSlide.ANIMATE_ON_TIME_SEC + (slideXML.graphstate.length() * FlipNumberSlide.NUMBER_DISPLAYED_DURATION_SEC)) * 1000;
					
				} else {
					
					displayTimeMsec = int(slideXML.@duration);
				
				}
					
				var slideData:InfographicSlideData = new InfographicSlideData(type, displayTimeMsec, slideXML);
				
				
				/*						
				slideData.textColor = uint(slideXML.appearance.@textColor.toString().replace("#", "0x"));
				slideData.backgroundColor = uint(slideXML.appearance.@backgroundColor.toString().replace("#", "0x"));
				
				// note: box color is not used in all infographic types
				slideData.boxColor = uint(slideXML.appearance.@boxColor.toString().replace("#", "0x"));	
				
				slideData.featuredText = slideXML.featuredText;
				slideData.featuredNumber = slideXML.featuredNumber;
				*/
				
				this.slides.push(slideData);
			}
			
		}
		
		
		

	}

}