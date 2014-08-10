package med.display {
	import flash.geom.Rectangle;
	import med.infographic.Infographic;
	import med.infographic.InfographicData;
	import med.story.Chapter;

	public class InfographicContent extends Infographic {
		
		public function InfographicContent(data:InfographicData, chapter:Chapter) {
			
			// get the infographicColors from the relevant Chapter, then pass them to our superclass
			var infographicColors:Vector.<uint>;
			if (chapter) infographicColors = chapter.getInfographicColors();
			else infographicColors = Infographic.DEFAULT_COLORS;

			super(data, null, infographicColors);
		}
		
	}

}