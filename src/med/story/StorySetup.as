package med.story {
	import com.gskinner.utils.Rndm;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import med.animation.AnimationAction;
	import med.animation.AnimationData;
	import med.animation.AnimationInfo;
	import med.animation.AnimationType;
	import med.animation.BoxState;
	import med.animation.FloatingAnimationData;
	import med.animation.HomeAnimationData;
	import med.infographic.InfographicData;
	import med.animation.SlidingAnimationData;
	import med.animation.SproutingAnimationData;
	import med.display.Box;
	import med.display.HomeBox;
	import med.display.TextContent;
	import med.story.ContentInfo;
	import med.story.Story;

	public class StorySetup {

		public static function readStorySet(xml:XML):void {
			
			var setXML:XML = xml;
			if (setXML.hasOwnProperty("BackgroundColour")) StorySet.bgColor = uint(setXML.BackgroundColour[0].toString().replace("#", "0x"));
			else StorySet.bgColor = 0x555500;
			
			var chapterCount:int = 0;
			for each(var chapterXML:XML in setXML.Chapter) {
				chapterCount++;
				var chapter:Chapter = new Chapter(chapterCount);
				if (chapterXML.hasOwnProperty("Title")) chapter.title = chapterXML.Title[0].toString().toUpperCase();
				if (chapterXML.hasOwnProperty("BackgroundColour")) chapter.bgColor = uint(chapterXML.BackgroundColour[0].toString().replace("#", "0x"));
				else chapter.bgColor = 0x555500;
				if (chapterXML.hasOwnProperty("Story")) chapter.storyID = chapterXML.Story[0].toString();
				StorySet.chapters.push(chapter);
			}
									
			StorySet.animationDatas[0] = StorySet.baseAnimationData = HomeAnimationData.create(0);
			for (var i:int = 1; i <= 3; i++) {
				StorySet.animationDatas[i] = HomeAnimationData.create(i);
			}
			
			for each(var storyXML:XML in setXML.Story) {
				StorySet.addStory(readStory(storyXML));
			}
			
			for each(var infographicXML:XML in setXML.Infographic) {
				StorySet.addInfographic(new InfographicData(infographicXML));
			}
			
		}
		
		static protected function readStory(storyXML:XML):Story {
			
			var story:Story = new Story();
			story.id = storyXML.@id.toString();
			
			var infos:Dictionary = new Dictionary();
			
			if (storyXML.hasOwnProperty("Background")) {
				var backgroundXML:XML = storyXML.Background[0];
				if (backgroundXML.hasOwnProperty("Image")) {
					var imageXML:XML = backgroundXML.Image[0];
					if (imageXML.hasOwnProperty("@url")) story.backgroundImageName = imageXML.@url.toString();
					
					AssetManager.loadImage(story.backgroundImageName);
				}
			}
			
			for each(var boxXML:XML in storyXML.Box) {
				var info:ContentInfo = new ContentInfo();
				story.contentInfos.push(info);
				infos[boxXML.@id.toString()] = info;

				if (boxXML.hasOwnProperty("Text")) {
					var textXML:XML = boxXML.Text[0];
					info.text = textXML.toString();
					if (textXML.hasOwnProperty("@type")) info.textType = textXML.@type.toString();
					if (!info.textType || !info.textType.length) info.textType = TextContent.TYPE_STORY_HEADER;
					if (textXML.hasOwnProperty("@scale")) info.textScale = parseFloat(textXML.@scale.toString());
				}
				if (boxXML.hasOwnProperty("Subtext")) {
					var subtextXML:XML = boxXML.Subtext[0];
					info.subtext = subtextXML.toString();
					if (subtextXML.hasOwnProperty("@scale")) info.subtextScale = parseFloat(subtextXML.@scale.toString());
				}
				if (boxXML.hasOwnProperty("Image")) {
					imageXML = boxXML.Image[0];
					if (imageXML.hasOwnProperty("@url")) info.imageURL = imageXML.@url.toString();
					if (imageXML.hasOwnProperty("@scroll")) info.imageScrollMargin = parseFloat(imageXML.@scroll.toString());
					
					AssetManager.loadImage(info.imageURL);
				}
				if (boxXML.hasOwnProperty("Video")) {
					var videoXML:XML = boxXML.Video[0];
					if (videoXML.hasOwnProperty("@url")) info.videoURL = videoXML.@url.toString();
				}
				
				if (boxXML.hasOwnProperty("Story")) {
					info.linkedStoryID = boxXML.Story[0].toString();
				}
				if (boxXML.hasOwnProperty("Infographic")) {
					info.linkedInfographicID = boxXML.Infographic[0].toString();
				}
				
				if (boxXML.hasOwnProperty("Break")) {
					info.action = AnimationAction.BREAK;
				}
				if (boxXML.hasOwnProperty("Home")) {
					info.action = AnimationAction.HOME;
				}

					
			}
			
			for each(var animXML:XML in storyXML.Animation) {
				var animationInfo:AnimationInfo = new AnimationInfo();
				if (animXML.hasOwnProperty("@type")) animationInfo.type = animXML.@type.toString().toLowerCase();
				if (animXML.hasOwnProperty("@small")) animationInfo.small = (animXML.@small.toString() == "true");
				var bearing:Number = 90;
				if (animXML.hasOwnProperty("@direction")) bearing = parseFloat(animXML.@direction);
				animationInfo.direction = (bearing - 90) * Math.PI / 180;
				if (animXML.hasOwnProperty("@randomSeed")) animationInfo.seed = parseInt(animXML.@randomSeed);
				if (animXML.hasOwnProperty("@slidingWidth")) animationInfo.param = parseFloat(animXML.@slidingWidth);
				if (animXML.hasOwnProperty("Camera")) {
					var camStrings:Array = animXML.Camera[0].toString().split(",");
					if (camStrings.length >= 2) animationInfo.cameraOverride = new Point(parseFloat(camStrings[0]), parseFloat(camStrings[1]));
					else if (camStrings.length == 1) animationInfo.cameraOverride = new Point(parseFloat(camStrings[0]), 0);
					else animationInfo.cameraOverride = new Point(0, 0);
				}
				var typeIndex:int = animationInfo.typeIndex;
				if (animationInfo.small) {
					story.smallAnimationInfos[typeIndex] = animationInfo;
				} else {
					story.animationInfos[typeIndex] = animationInfo;
				}
				
				var placements:Array = new Array();
				
				for each(boxXML in animXML.Box) {
					var placement:BoxPlacement = new BoxPlacement();
					if (boxXML.hasOwnProperty("@width")) placement.unitsWide = parseFloat(boxXML.@width);
					if (boxXML.hasOwnProperty("@height")) placement.unitsHigh = parseFloat(boxXML.@height);
					if (boxXML.hasOwnProperty("@size")) placement.unitsWide = placement.unitsHigh = parseFloat(boxXML.@size);
					if (boxXML.hasOwnProperty("@scale")) placement.unitsWide = placement.unitsHigh = parseFloat(boxXML.@scale);
					if (boxXML.hasOwnProperty("@inverted")) placement.inverted = (boxXML.@inverted.toString() == "true");
					if (boxXML.hasOwnProperty("@x") || boxXML.hasOwnProperty("@y")) {
						placement.position = new Point((parseFloat(boxXML.@x) || 0) * Box.SIZE, (parseFloat(boxXML.@y) || 0) * Box.SIZE);
					}
					if (boxXML.hasOwnProperty("@xOffset") || boxXML.hasOwnProperty("@yOffset")) {
						placement.offset = new Point((parseFloat(boxXML.@xOffset) || 0) * Box.SIZE, (parseFloat(boxXML.@yOffset) || 0) * Box.SIZE);
					}
					var boxID:String = boxXML.@id.toString();
					info = infos[boxID];
					var boxIndex:int = story.contentInfos.indexOf(info);
					placements[boxIndex] = placement;
				}
				var len:int = story.contentInfos.length;
				for (i = 0; i < len; i++) {
					placement = placements[i];
					if (!placement) placement = new BoxPlacement();
					animationInfo.placements[i] = placement;
				}
				
				var colors:Vector.<uint>;
				switch(animationInfo.type) {
					case AnimationType.FLOATING: colors = FloatingAnimationData.COLORS; break;
					case AnimationType.SPROUTING: colors = SproutingAnimationData.COLORS; break;
					case AnimationType.SLIDING: colors = SlidingAnimationData.COLORS; break;
				}
				for each(placement in animationInfo.placements) {
					if (!placement.color) {
						placement.color = colors[int(Math.random() * colors.length)];
					}
				}

				var i:int = AnimationType.getIndex(animationInfo.type);
				var homeRect:Rectangle = StorySet.animationDatas[i].getLayout(i).bounds;
				animationInfo.data = AnimationType.generateData(story, animationInfo, homeRect);
			}
			
			return story;
		}

		
		static public function preloadImages(loadedXML:XML):void {
			//<Image url="assets/Test Image.png" />
			var xmlString:String = loadedXML.toString();
			for (var index:int = xmlString.lastIndexOf("<Image"); index >= 0; index = xmlString.lastIndexOf("<Image", index - 1)) {
				var startIndex:int = xmlString.indexOf("\"", index);
				var endIndex:int = xmlString.indexOf("\"", startIndex + 1);
				var url:String = xmlString.substr(startIndex + 1, (endIndex - startIndex) - 1);
				AssetManager.loadImage(url);
			}			
		}
		

		
		
	}

}