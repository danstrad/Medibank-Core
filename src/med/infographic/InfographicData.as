package med.infographic {

	public class InfographicData {
		
		public var xml:XML;		
		public var id:String;		
		public var slides:Vector.<InfographicSlideData>;
		
		
		public function InfographicData(xml:XML) {
			this.xml = xml;
			this.id = xml.@id.toString();
			
			slides = new Vector.<InfographicSlideData>();
			
			var startIndex:int = 0;
			
			for (var i:int = 0; i < xml.slide.length(); i++) {
			
				var slideXML:XML = xml.slide[i];
				
				// skip to the last slide that has a "<startPoint />" tag in its xml
				if (slideXML.hasOwnProperty("startPoint")) {
					startIndex = i;
				}
				
				var type:String = slideXML.@type;
				
				// how long should the slide stay on the screen?
				// note: this currently includes animate on time, but NOT animate off time
				var displayTimeMsec:int;
				
				if (type == InfographicSlideData.PEOPLE_GRAPH) {
					// calculate duration automatically based on slide count, ignore what's in the xml (if anything)
					displayTimeMsec = PeopleGraph.getTotalMSecDurationFromXML(slideXML);
					
				} else if (type == InfographicSlideData.SPIN_NUMBER_STRIP) {
					// calculate duration automatically based on slide count, ignore what's in the xml (if anything)
					displayTimeMsec = 2000 + ((SpinNumberSlot.MIN_SPIN_TIME_SECS + SpinNumberSlide.AFTER_SPINNING_WAIT_TIME_SECONDS) * slideXML.graphstate.length()) * 1000;
									
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
			
			while (startIndex > 0) {
				startIndex--;
				this.slides.shift();
			}
			
		}
		
		
		

	}

}