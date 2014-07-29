package med.infographic {

	public class InfographicData {
		
		public var id:String;		
		public var slides:Vector.<InfographicSlideData>;

		
		
		public function InfographicData(xml:XML) {

			this.id = xml.@id.toString();
			
			slides = new Vector.<InfographicSlideData>();
			
			
			for (var i:int = 0; i < xml.slide.length(); i++) {
			
				var slideXML:XML = xml.slide[i];								
				var slideData:InfographicSlideData = new InfographicSlideData();
				
				
				slideData.type = slideXML.@type;
										
				slideData.textColor = uint(slideXML.appearance.@textColor.toString().replace("#", "0x"));
				slideData.backgroundColor = uint(slideXML.appearance.@backgroundColor.toString().replace("#", "0x"));
				
				// note: box color is not used in all infographic types
				slideData.boxColor = uint(slideXML.appearance.@boxColor.toString().replace("#", "0x"));	
				
				slideData.featuredText = slideXML.featuredText;
				slideData.featuredNumber = slideXML.featuredNumber;
			
				
				
				
				this.slides.push(slideData);
			}
			
		}
		
		

	}

}