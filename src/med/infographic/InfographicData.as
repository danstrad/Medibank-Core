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
				var data:Object = null;
				
				slideData.type = slideXML.@type;
										
				slideData.textColor = uint(slideXML.appearance.@textColor.toString().replace("#", "0x"));
				slideData.backgroundColor = uint(slideXML.appearance.@backgroundColor.toString().replace("#", "0x"));
				
				// note: box color is not used in all infographic types
				slideData.boxColor = uint(slideXML.appearance.@boxColor.toString().replace("#", "0x"));	
				
				slideData.featuredText = slideXML.featuredText;
				slideData.featuredNumber = slideXML.featuredNumber;
			
				
				switch(slideData.type) {
					case InfographicSlideData.HOTSPOT:
						data = { };
						if (slideXML.hasOwnProperty("Background")) {
							var bgXML:XML = slideXML.Background[0];
							if (bgXML.hasOwnProperty("Image")) {
								var imageXML:XML = bgXML.Image[0];
								data.backgroundURL = imageXML.@url.toString();
								data.backgroundScale = parseFloat(imageXML.@scale.toString());
							}
						}
						if (slideXML.hasOwnProperty("intro")) {
							var introXML:XML = slideXML.intro[0];
							if (introXML.hasOwnProperty("explanationText")) data.introExplanationText = safeText(introXML.explanationText[0].toString());
							if (introXML.hasOwnProperty("instructionsText")) data.introInstructionsText = safeText(introXML.instructionsText[0].toString());
						}
						data.hotspots = [];
						for each(var hotspotXML:XML in slideXML.hotspot) {
							var o:Object = { } ;
							o.x = parseFloat(hotspotXML.@x) || 0;
							o.y = parseFloat(hotspotXML.@y) || 0;
							if (hotspotXML.hasOwnProperty("Text")) o.text = hotspotXML.Text[0].toString();
							if (hotspotXML.hasOwnProperty("Image")) o.imageURL = hotspotXML.Image[0].@url.toString();
							data.hotspots.push(o);
						}
						break;
				}
				
				slideData.data = data;
				
				this.slides.push(slideData);
			}
			
		}
		
		protected static function safeText(text:String):String {
			text = text.replace(/\n\r/ig, '\n');
			text = text.replace(/\r\n/ig, '\n');
			text = text.replace(/\r/ig, '\n');
			return text;
		}
		
		

	}

}