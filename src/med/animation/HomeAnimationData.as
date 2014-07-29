package med.animation {
	import adobe.utils.CustomActions;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import med.display.Box;
	import med.display.HomeBox;
	import med.story.Chapter;
	import med.story.ContentInfo;
	import med.story.HomeInfo;
	import med.story.Story;
	import med.story.StorySet;

	public class HomeAnimationData {
		
		public var baseChapterID:int;
		
		public var homeInfos:Array;
		
		protected var layouts:Array;
		public function getLayout(chapterID:int):BoxLayout {
			return layouts[chapterID];
		}
		
		public function HomeAnimationData(baseChapterID:int) {
			this.baseChapterID = baseChapterID;
			homeInfos = new Array();
			layouts = new Array();
		}
		
		
		public static function create(baseChapterID:int):HomeAnimationData {
			var data:HomeAnimationData = new HomeAnimationData(baseChapterID);
			
			var layout:BoxLayout;
			var state:BoxState;
			var story:Story;
			var i:int, j:int;
			var info:HomeInfo;
			var chapter:Chapter;
			
			var SIZE:Number = Box.SIZE;
			var SIXTH:Number = SIZE / 6;
			var BIG_OFF:Number = SIZE * ( -1 + 0.25);
			var SMALL_OFF:Number = SIZE * ( -0.5 + 0.25);
			
			info = new HomeInfo(0);
			info.defaultColorTransform = HomeBox.createDefaultColorTransform(StorySet.bgColor);
			info.text = "WELCOME TO GENERATION BETTER.";
			data.homeInfos[info.chapterID] = info;
			for (i = 0; i < StorySet.chapters.length; i++) {
				chapter = StorySet.chapters[i];
				info = new HomeInfo(i + 1);
				info.defaultColorTransform = HomeBox.createDefaultColorTransform(chapter.bgColor);
				info.text = chapter.title;
				data.homeInfos[info.chapterID] = info;
			}
			info = new HomeInfo(4);
			info.width = 9 / 4 * (6 / 9);
			info.height = 5 / 4 * (6 / 9);
			info.videoURL = "assets/003_40inch_Main.mov"
			data.homeInfos[info.chapterID] = info;

			switch(baseChapterID) {
				default:
			
					for (i = 0; i <= 3; i++) {
						layout = new BoxLayout();
						
						switch(i) {
							case 0: // Gen Better
								layout.states[0] = BoxState.forHeader(0, 0, true, 2);
								layout.states[1] = BoxState.forHeader(SIZE * 1.5, SIZE * 0, false, 1);
								layout.states[2] = BoxState.forHeader(SIZE * 0.5, SIZE * 1.5, false, 1);
								layout.states[3] = BoxState.forHeader(SIZE * -1.5, SIZE * 0 - SIXTH * 2, false, 1);
								break;
							case 1: // Floater
								layout.states[0] = BoxState.forHeader(BIG_OFF + SIZE * 0 + SIXTH, BIG_OFF + SIZE * -0.5, false, 0.5);
								layout.states[1] = BoxState.forHeader(0, 0, true, 2);
								layout.states[2] = BoxState.forHeader(BIG_OFF + SIZE * 1.5, BIG_OFF + SIZE * 2, false, 0.5);
								layout.states[3] = BoxState.forHeader(BIG_OFF + SIZE * -0.5, BIG_OFF + SIZE * 2 + SIXTH * -2, false, 0.5);
								break;
							case 2: // Sprouter
								layout.states[0] = BoxState.forHeader(BIG_OFF + SIZE * 0 - SIXTH, BIG_OFF + SIZE * -0.5, false, 0.5);
								layout.states[1] = BoxState.forHeader(BIG_OFF + SIZE * 1.5, BIG_OFF + SIZE * -0.5, false, 0.5);
								layout.states[2] = BoxState.forHeader(0, 0, true, 2);
								layout.states[3] = BoxState.forHeader(BIG_OFF + SIZE * -0.5, BIG_OFF + SIZE * 1, false, 0.5);
								break;
							case 3: // Slider
								layout.states[0] = BoxState.forHeader(BIG_OFF + SIZE * 0 + SIXTH, BIG_OFF + SIZE * -0.5, false, 0.5);
								layout.states[1] = BoxState.forHeader(BIG_OFF + SIZE * 1.5, BIG_OFF + SIZE * -0.5, false, 0.5);
								layout.states[2] = BoxState.forHeader(BIG_OFF + SIZE * 1 + SIXTH, BIG_OFF + SIZE * 2, false, 0.5);
								layout.states[3] = BoxState.forHeader(0, 0, true, 2);
								break;
						}
										
						data.layouts[i] = layout;
					}
					
					addVideo(data);
					break;
			
				case 1:
				case 2:
				case 3:
					
					for (i = 0; i <= 3; i++) {
						layout = new BoxLayout();
						
						switch(i) {
							case 0: // Gen Better
								layout.states[0] = BoxState.forHeader(0, 0, true, 2);
								layout.states[1] = BoxState.forHeader(SIZE * 1, SIZE * 0, false, 0.5);
								layout.states[2] = BoxState.forHeader(SIZE * 0.5, SIZE * 1, false, 0.5);
								layout.states[3] = BoxState.forHeader(SIZE * -1, SIZE * 0 - SIXTH * 2, false, 0.5);
								break;
							case 1: // Floater
								layout.states[0] = BoxState.forHeader(SMALL_OFF + SIZE * 0 + SIXTH * -1, SMALL_OFF + SIZE * -0.5 + SIXTH * -2, false, 0.5);
								layout.states[1] = BoxState.forHeader(0, 0, true, 1);
								layout.states[2] = BoxState.forHeader(SMALL_OFF + SIZE * -0.5 + SIXTH * -1, SMALL_OFF + SIZE * 1 + SIXTH * -1, false, 0.5);
								layout.states[3] = BoxState.forHeader(SMALL_OFF + SIZE * 1 + SIXTH * -1, SMALL_OFF + SIZE * -0.5 + SIXTH * -1, false, 0.5);
								break;
							case 2: // Sprouter
								layout.states[0] = BoxState.forHeader(SMALL_OFF + SIZE * -0.5 + SIXTH * 1, SMALL_OFF + SIZE * -0.5, false, 0.5);
								layout.states[1] = BoxState.forHeader(SMALL_OFF + SIZE * 0.5, SMALL_OFF + SIZE * -0.5, false, 0.5);
								layout.states[2] = BoxState.forHeader(0, 0, true, 1);
								layout.states[3] = BoxState.forHeader(SMALL_OFF + SIZE * -0.5, SMALL_OFF + SIZE * 0.5 + SIXTH * 1, false, 0.5);
								break;
							case 3: // Slider
								layout.states[0] = BoxState.forHeader(SMALL_OFF + SIZE * -0.5, SMALL_OFF + SIZE * 0, false, 0.5);
								layout.states[1] = BoxState.forHeader(SMALL_OFF + SIZE * -0.5, SMALL_OFF + SIZE * 0.5, false, 0.5);
								layout.states[2] = BoxState.forHeader(SMALL_OFF + SIZE * 0, SMALL_OFF + SIZE * 1, false, 0.5);
								layout.states[3] = BoxState.forHeader(0, 0, true, 1);
								break;
						}
						
						data.layouts[i] = layout;
					}

					addVideo(data);
					layout = data.layouts[3];
					state = layout.states[4];
					state.scale = 0;
					break;
					
			}
			
			var bounds:Rectangle;
			for each(layout in data.layouts) {
				if (!layout) continue;
				bounds = null;
				for each(state in layout.states) {
					if (!state) continue;
					var stateBounds:Rectangle = getStateBounds(state);
					if (bounds) bounds = bounds.union(stateBounds);
					else bounds = stateBounds;
				}
				layout.bounds = bounds;
			}

			return data;
		}
		
		static protected function getStateBounds(state:BoxState):Rectangle {
			return new Rectangle(state.x - state.scale * Box.SIZE / 2, state.y - state.scale * Box.SIZE / 2, state.scale * Box.SIZE, state.scale * Box.SIZE);
		}
		
		static protected function addVideo(data:HomeAnimationData):void {
			// Add video above Box 0
			for each(var layout:BoxLayout in data.layouts) {
				var first:BoxState = layout.states[0];						
				var info:HomeInfo = data.homeInfos[4];
				var h:Number = Box.SIZE * ((info.height + 1) * first.scale) / 2; // Half of video height + box height
				var state:BoxState = BoxState.forHeader(first.x, first.y - h, false, first.scale);
				layout.states[4] = state;
			}
		}
		
		
	}

}


