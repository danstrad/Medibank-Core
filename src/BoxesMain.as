package {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.GestureEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.utils.getTimer;
	import med.display.ContinueButton;
	import med.display.CoreInfographic;
	import med.infographic.Infographic;
	import med.animation.AnimationAction;
	import med.animation.AnimationController;
	import med.animation.AnimationData;
	import med.animation.AnimationInfo;
	import med.animation.AnimationType;
	import med.animation.BoxLayout;
	import med.animation.Camera;
	import med.animation.HighlightController;
	import med.animation.HomeAnimationController;
	import med.animation.HomeAnimationData;
	import med.infographic.InfographicCenterBox;
	import med.infographic.InfographicData;
	import med.animation.SproutingAnimationData;
	import med.display.BackButton;
	import med.display.Background;
	import med.display.BackgroundEffect;
	import med.display.BackgroundImage;
	import med.display.Box;
	import med.display.ClickBlip;
	import med.display.Grid;
	import med.display.HomeBox;
	import med.display.TextContent;
	import med.display.TiledBackgroundEffect;
	import med.story.BoxPlacement;
	import med.story.Chapter;
	import med.story.ContentInfo;
	import med.story.Story;
	import med.story.StorySet;
	import med.story.StorySetup;

	public class BoxesMain extends MovieClip {
		
		public static const CACHE_AND_SNAP:Boolean = true;
		
		//1024x576 = 1920x1080
		static public var STAGE_WIDTH:Number = 1024;
		static public var STAGE_HEIGHT:Number = 576;

		static protected const ZERO_POINT:Point = new Point(0, 0);
		
		static public const IDLE_ANIMATION_TIME:Number = 30 * 1000;
		static public const IDLE_ABORT_TIME:Number = 10 * 60 * 1000;

		protected var xmlLoader:URLLoader;
		protected var loadedXML:XML;

		protected var mover:Sprite;
		protected var backgroundImageLayer:Sprite;
		protected var backgroundEffectsLayer:Sprite;
		protected var boxesLayer:Sprite;
		protected var background:Background;
		protected var camera:Camera;
		protected var grid:Grid;

		protected var lastFrameTime:Number;		
		protected var idleTime:Number;

		protected var backgroundImages:Vector.<BackgroundImage>;
		protected var currentHomeAnimation:HomeAnimationController;
		protected var homeAnimations:Vector.<HomeAnimationController>;
		protected var endingHomeAnimations:Vector.<HomeAnimationController>;
		protected var currentAnimation:AnimationController;
		protected var currentAnimations:Vector.<AnimationController>;
		protected var endingAnimations:Vector.<AnimationController>;
		protected var currentInfographic:CoreInfographic;
		protected var lingeringInfographic:CoreInfographic;
		protected var endingInfographic:CoreInfographic;
		protected var clickBlips:Vector.<ClickBlip>;
		protected var backgroundEffects:Vector.<BackgroundEffect>;
		protected var backButton:BackButton;
		protected var continueButton:ContinueButton;
		
		protected var currentStory:Story;
		protected var currentChapter:Chapter;
		
		protected var floaterOnScreen:Boolean;
		
		protected var dragging:Boolean;
		protected var dragPoint:Point;
		protected var frameDrag:Point;
		protected var dragMomentum:Point;
		
		protected var autoAnimatingToEnd:Boolean;
		protected var autoAnimateWaitTime:Number;
				
		

		public function BoxesMain() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}

		protected function handleAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			init();
		}

		protected function init():void {
			//STAGE_WIDTH = stage.stageWidth;
			//STAGE_HEIGHT = stage.stageHeight;
			
			new _FontDump();
			TextUtils.createTextFormats();
			
			soundTransform = new SoundTransform(0);
			
			backgroundImages = new Vector.<BackgroundImage>();
			homeAnimations = new Vector.<HomeAnimationController>();
			endingHomeAnimations = new Vector.<HomeAnimationController>();
			currentAnimations = new Vector.<AnimationController>();
			endingAnimations = new Vector.<AnimationController>();
			clickBlips = new Vector.<ClickBlip>();
			backgroundEffects = new Vector.<BackgroundEffect>;

			background = new Background(STAGE_WIDTH, STAGE_HEIGHT);
			backgroundImageLayer = new Sprite();

			mover = new Sprite();
			mover.x = STAGE_WIDTH / 2;
			mover.y = STAGE_HEIGHT / 2;
						
			backgroundEffectsLayer = new Sprite();
			backgroundEffectsLayer.x = STAGE_WIDTH / 2;
			backgroundEffectsLayer.y = STAGE_HEIGHT / 2;
			boxesLayer = new Sprite();
			
			backButton = new BackButton();
			backButton.x = STAGE_WIDTH - (backButton.width / 2) - 10;
			backButton.y = STAGE_HEIGHT - (backButton.height / 2) - 10;
			
			continueButton = new ContinueButton();
			continueButton.x = STAGE_WIDTH - 50;
			continueButton.y = STAGE_HEIGHT / 2;
			continueButton.visible = false;
			
			//mover.addChild(grid = new Grid());
			mover.addChild(boxesLayer);
			
			addChild(background);
			addChild(backgroundImageLayer);
			addChild(backgroundEffectsLayer);
			addChild(mover);
			//addChild(backButton);
			addChild(continueButton);
			
			camera = new Camera(mover, new Point(mover.x, mover.y));
			camera.setScreenSize(stage.stageWidth, stage.stageHeight);
			
			dragPoint = new Point(0, 0);
			frameDrag = new Point(0, 0);
			dragMomentum = new Point(0, 0);
			
			autoAnimatingToEnd = true;
			autoAnimateWaitTime = 0;

			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, handleXMLLoaded);
			xmlLoader.load(new URLRequest("BoxesData.XML"));

			CONFIG::release {
				Mouse.hide();
				stage.addEventListener(MouseEvent.CLICK, handleFullScreenClick);
			}
			
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenChange);
		}

		
		protected function handleXMLLoaded(event:Event):void {
			loadedXML = new XML(xmlLoader.data);

			xmlLoader.removeEventListener(Event.COMPLETE, handleXMLLoaded);
			xmlLoader = null;

			StorySetup.preloadImages(loadedXML)

			addEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);
		}
		
		
		protected function handleCheckImagesLoaded(event:Event):void {
			if (AssetManager.isLoading) return;
			removeEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);			

			StorySetup.readStorySet(loadedXML);

			displayStories();
		}

		protected function clear():void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			removeEventListener(Event.ENTER_FRAME, handleAnimate);
		}




		protected function displayStories():void {
			clear();

			var container:Sprite = new Sprite();
			boxesLayer.addChild(container);

			var homeAnim:HomeAnimationController = new HomeAnimationController(null, ZERO_POINT, ZERO_POINT, container, StorySet.baseAnimationData);
			homeAnim.transitionTo(homeAnim.data.getLayout(0));
			homeAnim.completeInstantly();
			homeAnimations.push(homeAnim);
			currentHomeAnimation = homeAnim;

			background.showColor(StorySet.bgColor);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			addEventListener(Event.ENTER_FRAME, handleAnimate);
			lastFrameTime = getTimer();
			idleTime = 0;
			
			updateCameraBounds();
		}

		protected function transitionToChapter(homeBox:HomeBox):void {			
			var homeAnimation:HomeAnimationController;
			for each(var homeAnim:HomeAnimationController in homeAnimations) {
				if (homeAnim.boxes.indexOf(homeBox) >= 0) {
					homeAnimation = homeAnim;
					break;
				}
			}
			if (!homeAnimation) return;

			killAnimations(homeBox.home);
			fadeOutBackgroundImages();
			
			var chapter:Chapter = homeBox.chapter;
			if (chapter) {
				background.fadeToColor(chapter.bgColor, 300);
			} else {
				background.fadeToColor(StorySet.bgColor, 300);
				//camera.animateTo(0, 0, 400, 100);
				//camera.setPanArea(new Rectangle( -Camera.WIDTH, -Camera.HEIGHT, Camera.WIDTH * 2, Camera.HEIGHT * 2));
			}

			for each(var anim:AnimationController in currentAnimations) {
				anim.end();
				endingAnimations.push(anim);
			}
			currentAnimations.length = 0;

			// Always bring it back to big home buttons
			homeAnimation.data = StorySet.baseAnimationData;
			var layout:BoxLayout = homeAnimation.data.getLayout(homeBox.id);
			homeAnimation.transitionTo(layout);
			
			currentChapter = chapter;
			if (chapter) currentStory = chapter.baseStory;
			else currentStory = null;
			var currentChapterID:int = (currentChapter != null) ? currentChapter.id : 0;

			if (chapter) {
				var homeTarget:Point = homeAnimation.getTargetPosition();
				var boxHighlightPosition:Point = new Point(homeBox.destination.x + homeTarget.x, homeBox.destination.y + homeTarget.y);
				//var boxHighlightPosition:Point = new Point(homeBox.destination.x + homeBox.parent.x, homeBox.destination.y + homeBox.parent.y);
				expandStoryFrom(chapter.baseStory, chapter.id, false, homeBox, boxHighlightPosition, false, true);
			} else {
				currentAnimation = null;
				//camera.setPanArea(null);				
			}
			
			updateCameraBounds();
			
			if (!chapter) {
				var target:Point = homeAnimation.getTargetPosition();
				camera.animateTo(target.x, target.y, 400, 100);
			}

		}

		protected function expandStoryFrom(story:Story, animationTypeIndex:int, smallVariation:Boolean, parent:Box, parentHighlightPosition:Point, showHomeButtons:Boolean, panTo:Boolean):AnimationController {
			if (!story) return null;
			
			var container:Sprite = new Sprite();
			boxesLayer.addChildAt(container, 0);
			
			if (showHomeButtons) fadeOutBackgroundImages(); // Don't clear when showing next batch of chapter headers
			if (story.backgroundImageName) {
				var backgroundImage:BackgroundImage = new BackgroundImage(AssetManager.getImage(story.backgroundImageName));
				backgroundImage.fadeIn();
				backgroundImageLayer.addChild(backgroundImage);
				backgroundImages.push(backgroundImage);
			}
			
			var anim:AnimationController;
			if (!(parent is HomeBox)) {
				for each(anim in currentAnimations) {
					if (anim.contentBoxes.indexOf(parent) >= 0) {
						var hc:HighlightController = anim.highlightBox(parent);
						// Have clicked on a content Box, which will reposition through the highlight. Update parentHighlightPosition with these new coords
						var toTarget:Point = hc.offsetToTarget();
						parentHighlightPosition.x += toTarget.x;
						parentHighlightPosition.y += toTarget.y;
						break;
					}
				}
			}

			var animationInfo:AnimationInfo;
			if (smallVariation) animationInfo = story.smallAnimationInfos[animationTypeIndex];
			if (!animationInfo) animationInfo = story.animationInfos[animationTypeIndex];
			if (!animationInfo) {
				trace("No animationInfo for this story with this animation type");
				return null;
			}
			var animation:AnimationController = new AnimationController(story, animationInfo, parent, parentHighlightPosition, container, camera, currentChapter, !showHomeButtons);
			currentAnimations.push(animation);

			var homeData:HomeAnimationData;
			if (currentChapter) homeData = StorySet.animationDatas[currentChapter.id];
			else homeData = StorySet.baseAnimationData;

			var currentChapterID:int = (currentChapter != null) ? currentChapter.id : 0;
			
			if (showHomeButtons) {
				var animationData:AnimationData = animationInfo.data;
				
				container = new Sprite();
				boxesLayer.addChild(container);
				
				killAnimations(parent.home);
				
				var parentAnimation:AnimationController;
				for each(anim in currentAnimations) {
					if (anim.contentBoxes.indexOf(parent) >= 0) {
						parentAnimation = anim;
						break;
					}
				}
				if (parentAnimation) {
					for (var i:int = currentAnimations.length - 1; i >= 0; i--) {
						anim = currentAnimations[i];
						if (anim == animation) continue;
						if (parentAnimation.contentBoxes.indexOf(anim.parentBox) >= 0) {
							anim.end();
							endingAnimations.push(anim);
							currentAnimations.splice(i, 1);
						}
					}
				}				
				
				var originOffset:Point = animationData.getOriginOffsetFor(parent);
				var homeOffset:Point = new Point(originOffset.x + animationData.homePoint.x, originOffset.y + animationData.homePoint.y);
				var homeAnim:HomeAnimationController = new HomeAnimationController(parent, parentHighlightPosition, homeOffset, container, homeData);
				homeAnim.transitionTo(homeData.getLayout(currentChapterID));
				homeAnim.completeInstantly();
				homeAnim.fadeIn(600);
				homeAnim.wait(800);
				homeAnimations.push(homeAnim);
				currentHomeAnimation = homeAnim;
				
				if (currentChapter) {
					var homeBox:HomeBox;
					for each(var hBox:HomeBox in homeAnim.boxes) {
						if (hBox.chapter && (hBox.chapter == currentChapter)) {
							homeBox = hBox;
							break;
						}
					}
					var homeBoxHighlightPosition:Point = parentHighlightPosition.add(homeOffset.add(homeBox.destination));
					var headers:AnimationController = expandStoryFrom(currentChapter.baseStory, animationTypeIndex, true, homeBox, homeBoxHighlightPosition, false, false);
				}
				
				homeAnim.wait(1200);
				if (headers) headers.wait(2700);
				//if (headers) headers.completeInstantly();
				
			}
			
			currentStory = story;
			currentAnimation = animation;
			
			if (story.continueStoryID || story.continueInfographicID) {
				continueButton.visible = true;
				continueButton.alpha = 0;
				if (story.continueStoryID) continueButton.story = StorySet.getStory(story.continueStoryID);
				else continueButton.story = null;
				if (story.continueInfographicID) continueButton.infographic = StorySet.getInfographic(story.continueInfographicID);
				else continueButton.infographic = null;
				showContinueButton();
			} else {
				continueButton.story = null;
				continueButton.infographic = null;
				hideContinueButton();
			}
			
			updateCameraBounds();
			if (panTo) animation.playCameraAnimation();
				
			return animation;
		}
		
		
		protected function beginInfographic(data:InfographicData, launchRect:Rectangle):void {
			mover.mouseChildren = false;
			
			launchRect = launchRect.clone();
			launchRect.offset(-STAGE_WIDTH / 2, -STAGE_HEIGHT / 2);
			
			var infographic:CoreInfographic = new CoreInfographic(data, mover, launchRect, backgroundImageLayer, background, currentChapter);
			currentInfographic = infographic;
			infographic.x = STAGE_WIDTH / 2;
			infographic.y = STAGE_HEIGHT/ 2;
			addChild(infographic);
			currentInfographic.enable();
			
		}
		
		
		protected function restoreAfterInfographic():void {
			mover.mouseChildren = true;

			var offset:Point;
			var container:Sprite;
			var homeAnim:HomeAnimationController;

			//if (currentInfographic.parent) currentInfographic.parent.removeChild(currentInfographic);
			//currentInfographic = null;
			
			var chapterID:int = 0;
			if (currentChapter) chapterID = currentChapter.id;

			
			
			var story:Story;
			if (currentInfographic.data.xml.hasOwnProperty("LinkedStory")) story = StorySet.getStory(currentInfographic.data.xml.LinkedStory[0].toString());

			
			if (story && (currentInfographic.endedEarly == false)) {
				
				var animIndex:int = 0;
				for (var i:int = 0;  i <= 3; i++) {
					if (story.animationInfos[i]) {
						animIndex = i;
						break;
					}
				}
				
				var fakeParentBox:Box = new Box(0x0);
				fakeParentBox.widthAsHeader = InfographicCenterBox.CENTER_BOX_WIDTH;
				fakeParentBox.heightAsHeader = InfographicCenterBox.CENTER_BOX_HEIGHT;
				var fakeContentInfo:ContentInfo = new ContentInfo();
				var fakePlacement:BoxPlacement = new BoxPlacement();
				fakePlacement.unitsWide = InfographicCenterBox.CENTER_BOX_WIDTH / Box.SIZE;
				fakePlacement.unitsHigh = InfographicCenterBox.CENTER_BOX_HEIGHT / Box.SIZE;
				fakeParentBox.showContentInfo(fakeContentInfo, fakePlacement);
				
				var boxHighlightPosition:Point = new Point(0, 0);
				expandStoryFrom(story, animIndex, false, fakeParentBox, boxHighlightPosition, false, true);				
				
				
			} else if (currentInfographic.endedEarly) {
				// the infographic was forced to exit from the pause menu

				Stats.abortedInfographic(currentInfographic);
				
				offset = new Point(0, 0);
				
				container = new Sprite();
				boxesLayer.addChild(container);
				container.x = offset.x;
				container.y = offset.y;
				
				homeAnim = new HomeAnimationController(null, offset, ZERO_POINT, container, StorySet.baseAnimationData);
				homeAnimations.push(homeAnim);
				currentHomeAnimation = homeAnim;
				
				transitionToChapter(homeAnim.boxes[chapterID]);
				
				if (currentInfographic.parent) {
					currentInfographic.parent.removeChild(currentInfographic);
				}
				
				currentInfographic = null;
				
				
			} else {
				
				Stats.finishedInfographic(currentInfographic);

				offset = new Point(450, 0);
				
				container = new Sprite();
				boxesLayer.addChild(container);
				container.x = offset.x;
				container.y = offset.y;
				
				homeAnim = new HomeAnimationController(null, offset, ZERO_POINT, container, StorySet.baseAnimationData);
				homeAnimations.push(homeAnim);
				currentHomeAnimation = homeAnim;
				
				transitionToChapter(homeAnim.boxes[chapterID]);
				
			}

			
			if (currentInfographic) {
				mover.addChild(currentInfographic);
				currentInfographic.x = 0;
				currentInfographic.y = 0;
				lingeringInfographic = currentInfographic;
				currentInfographic = null;
			}
						
			
			updateCameraBounds();
			camera.setFocus(new Point(0, 0));
			camera.animateTo(200, 0, 1500, 100);
		}
		
		
		protected function showContinueButton():void {
			continueButton.mouseEnabled = true;
			TweenMax.to(continueButton, 1, { alpha:1, delay:2, ease:Quad.easeOut, onComplete:finishedContinueButtonTween } );
		}
		
		protected function hideContinueButton():void {
			if (continueButton.visible) {
				continueButton.mouseEnabled = false;
				TweenMax.to(continueButton, 1, { alpha:0, delay:0, ease:Quad.easeIn, onComplete:finishedContinueButtonTween } );
			}
		}

		protected function finishedContinueButtonTween():void {
			continueButton.visible = (continueButton.alpha > 0.5);
		}
		
		
		protected function expandCameraBounds():void {			
			// Expands based on current graphics. Allows for more leeway with floaters
			
			var margin:Number = Box.SIZE * (1 + 1.5 / 6);
			
			var camArea:Rectangle;
			var b:Rectangle;
			for each(var anim:AnimationController in currentAnimations) {
				b = anim.container.getBounds(mover);
				if (camArea) camArea = camArea.union(b);
				else camArea = b;
			}
			for each(var homeAnim:HomeAnimationController in homeAnimations) {
				if (!homeAnim.currentParentPosition || (homeAnim.parentBox && homeAnim.parentBox.ending)) return;
				b = homeAnim.container.getBounds(mover);
				if (camArea) camArea = camArea.union(b);
				else camArea = b;
			}
			if (!camArea) return;
			
			var camFocus:Point = camera.getFocus();
			var camTarget:Point = camera.getTarget();
			camArea.left = Math.min(camArea.left, camFocus.x, camTarget.x);
			camArea.right = Math.max(camArea.right, camFocus.x, camTarget.x);
			camArea.top = Math.min(camArea.top, camFocus.y, camTarget.y);
			camArea.bottom = Math.max(camArea.bottom, camFocus.y, camTarget.y);
			camArea.inflate(Math.max(margin, (Camera.WIDTH - camArea.width) / 2), Math.max(margin, (Camera.HEIGHT - camArea.height) / 2));
			
			var current:Rectangle = camera.getPanArea().clone();
			current.inflate(STAGE_WIDTH / 2, STAGE_HEIGHT / 2);
			camArea = camArea.union(current);
			
			camera.setPanArea(camArea);
		}
		protected function updateCameraBounds():void {
			var margin:Number = Box.SIZE * (1 + 1.5 / 6);
			
			var camArea:Rectangle;
			var b:Rectangle
			var d:DisplayObject;
			
			camera.tetheredObjects.length = 0;
			camArea = null;
			
			var floaterBuffers:Vector.<Number> = new Vector.<Number>();
			
			floaterOnScreen = false;
			for each(var anim:AnimationController in currentAnimations) {
				b = anim.animationData.bounds.clone();
				b.offsetPoint(anim.parentHighlightPosition);
				b.offsetPoint(anim.animationData.getOriginOffsetFor(anim.parentBox));
				if (anim.animationInfo.type == AnimationType.FLOATING) {
					floaterOnScreen = true;
					floaterBuffers.push(b.width * 0.1);
				}
				if (camArea) camArea = camArea.union(b);
				else camArea = b;
				
				for each(d in anim.contentBoxes) camera.tetheredObjects.push(d);
			}
			for each(var homeAnim:HomeAnimationController in homeAnimations) {
				b = homeAnim.currentBounds.clone();
				b.offsetPoint(homeAnim.getTargetPosition());
				if (camArea) camArea = camArea.union(b);
				else camArea = b;

				for each(d in homeAnim.boxes) camera.tetheredObjects.push(d);
			}
			if (lingeringInfographic) {
				b = new Rectangle( -Camera.WIDTH / 2 + margin, -Camera.HEIGHT / 2 + margin, Camera.WIDTH - margin * 2, Camera.HEIGHT - margin * 2);
				if (camArea) camArea = camArea.union(b);
				else camArea = b;
				
				camera.tetheredObjects.push(lingeringInfographic);
			}			
			if (currentAnimation) {
				b = new Rectangle(currentAnimation.parentHighlightPosition.x - Camera.WIDTH / 2, currentAnimation.parentHighlightPosition.y - Camera.HEIGHT / 2, Camera.WIDTH, Camera.HEIGHT);
				if (camArea) camArea = camArea.union(b);
				else camArea = b;
			}
			
			camArea.inflate(Math.max(margin, (Camera.WIDTH - camArea.width) / 2), Math.max(margin, (Camera.HEIGHT - camArea.height) / 2));
			
			var buffer:Number = 0;
			var len:int = floaterBuffers.length;
			for (var i:int = 0; i < len; i++) {
				var n:Number = floaterBuffers[i];
				buffer += n * (len - i);
			}
			camArea.right += buffer;

			/*
			// Tricky because each bounds are dependent on the float of any previous bounds
			for each(anim in currentAnimations) {
				if (anim.animationInfo.type == AnimationType.FLOATING) {
					//anim.expandBoundsForFloating(b, camArea);
					anim.expandBoundsForFloating(camArea, camArea.clone());
				}
			}
			*/
			
			camera.setPanArea(camArea);
		}
		
		
		protected function killAnimations(exception:HomeAnimationController):void {
			var i:int;
			for (i = homeAnimations.length - 1; i >= 0; i--) {
				var homeAnim:HomeAnimationController = homeAnimations[i];
				if (homeAnim != exception) {
					homeAnim.end();
					endingHomeAnimations.push(homeAnim);
					homeAnimations.splice(i, 1);
				}
			}
			for (i = currentAnimations.length - 1; i >= 0; i--) {
				var anim:AnimationController = currentAnimations[i];
				if ((anim.contentBoxes.length == 0) || !anim.contentBoxes[0].home || anim.contentBoxes[0].home.ending) {
					anim.end();
					endingAnimations.push(anim);
					currentAnimations.splice(i, 1);
				}
			}
			if (lingeringInfographic) {
				endingInfographic = lingeringInfographic;
				lingeringInfographic = null;
				endingInfographic.animateOff();
			}
		}


		protected function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.S) {
				Stats.print();
			}
		}


		protected function handleMouseDown(event:MouseEvent):void {
			if (stage) stage.focus = stage;

			idleTime = 0;
						
			if (currentInfographic) return;
			
			if (event.target == continueButton) {
				if (continueButton.story) {
					// Not implemented
					//killAnimations(null);
					//hideContinueButton();
				}
				if (continueButton.infographic) {
					killAnimations(null);
					beginInfographic(continueButton.infographic, new Rectangle(0, 0, 0, 0));
					hideContinueButton();
				}				
			}
			
			if (checkClick(event)) return;
			
			
			var allowDrag:Boolean = true;
			var box:Box = event.target as Box;
			if (box) {
				if (box.textContent && box.textContent.isScroller) allowDrag = false;
			}
			
			if (allowDrag) beginDragging();			
		}
		
		protected function checkClick(event:MouseEvent):Boolean {
			var i:int;
			var launchRect:Rectangle;
			
			var box:Box = event.target as Box;
			if (!box || !box.clickEnabled) return false;
			var homeBox:HomeBox = box as HomeBox;

			var showBlip:Boolean = false;
			
			if (homeBox) {
				
				if ((homeBox.alpha < 0) || (homeBox.parent.alpha < 0)) return false;
				
				if (homeBox.videoContent) {
					Stats.homeBoxClicked(homeBox);
					homeBox.videoContent.expand();
					return true;
				}
				
				/*
				if (!homeBox.chapter) {
					var bge:BackgroundEffect = new TiledBackgroundEffect();
					backgroundEffects.push(bge);
					backgroundEffectsLayer.addChild(bge);
				}
				*/
				
				if (homeBox.chapter) {
					if (homeBox.chapter.baseInfographic) {
						
						Stats.homeBoxClicked(homeBox);

						launchRect = box.getBounds(this);						
						killAnimations(null);
						currentChapter = homeBox.chapter;	// correct problems with vision palette when opened from other chapter. hope this doesn't break everything
						background.fadeToColor(homeBox.chapter.bgColor, 300);
						beginInfographic(homeBox.chapter.baseInfographic, launchRect);
						showBlip = true;
						
						
					} else if (homeBox.chapter.baseStory) {
						if (homeBox.chapter.baseStory == currentStory) return false;

						Stats.homeBoxClicked(homeBox);
						showBlip = true;
						transitionToChapter(homeBox);
					} else {
						return false;
					}
				} else {
					if (!currentStory) return false;
				}
				
				//disableExistingClickableBoxes();

			} else {
				
				var linkedStory:Story = box.contentInfo.linkedStory;
				var linkedInfographic:InfographicData = box.contentInfo.linkedInfographic;
				
				if (linkedStory) {

					var showing:Boolean = false;
					for each(var anim:AnimationController in currentAnimations) {
						if (anim.parentBox == box) {
							showing = true;
							break;
						}
					}
					
					if (!showing) {
						Stats.boxClicked(box);
						//disableExistingClickableBoxes();
						// Change this to some sort of destination coords
						var boxHighlightPosition:Point = new Point(box.parent.x + box.getX(), box.parent.y + box.getY());
						expandStoryFrom(linkedStory, currentChapter.id, false, box, boxHighlightPosition, true, true);
						
						showBlip = true;
					}
				} else if (linkedInfographic) {
					
					Stats.boxClicked(box);
					
					launchRect = box.getBounds(this);					
					killAnimations(null);
					beginInfographic(linkedInfographic, launchRect);
					showBlip = true;
					
				} else if (box.contentInfo.action == AnimationAction.HOME) {
					//showBlip = true;
					//transitionToChapter(null);
					return true;
				} else if (box.videoContent) {
					Stats.boxClicked(box);
					showBlip = false;
					box.videoContent.expand();
					return true;
				} else {
					return false;
				}
				
			}
			
			if (showBlip) {
				var blip:ClickBlip = new ClickBlip(box);
				mover.addChild(blip);
				clickBlips.push(blip);

				for each(var homeAnim:HomeAnimationController in homeAnimations) homeAnim.wait(ClickBlip.TIME);
				if (currentAnimation) currentAnimation.wait(ClickBlip.TIME);
				camera.wait(ClickBlip.TIME);
			}

			return true;
		}

		protected function disableExistingClickableBoxes():void {
			var anim:AnimationController;
			var homeAnim:HomeAnimationController;
			var box:Box;
			for each(anim in currentAnimations) {
				for each(box in anim.contentBoxes) {
					box.clickEnabled = false;
					box.stopFlashing();
				}
			}
			for each(anim in endingAnimations) {
				for each(box in anim.contentBoxes) {
					box.clickEnabled = false;
					box.stopFlashing();
				}
			}
			for each(homeAnim in homeAnimations) {
				if (homeAnim == currentHomeAnimation) continue;
				for each(box in homeAnim.boxes) {
					box.clickEnabled = false;
					box.stopFlashing();
				}
			}
		}			
		

		protected function beginDragging():void {
			dragging = true;
			dragPoint.x = stage.mouseX;
			dragPoint.y = stage.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleDragUp);
		}		
		
		protected function handleDragMove(event:MouseEvent):void {
			idleTime = 0;			
			
			var dx:Number = stage.mouseX - dragPoint.x;
			var dy:Number = stage.mouseY - dragPoint.y;			
			dragPoint.x = stage.mouseX;
			dragPoint.y = stage.mouseY;
			frameDrag.x += dx;
			frameDrag.y += dy;
		}
		
		protected function handleDragUp(event:MouseEvent):void {
			dragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragUp);;
		}
		
		protected function animateCamera(dTime:Number):void {
			if (floaterOnScreen) expandCameraBounds();
			
			if (dragging) {
				const OLD_CHECK:Number = 0.8;
				if (dragMomentum.length * OLD_CHECK > frameDrag.length) {
					dragMomentum.normalize(dragMomentum.length * OLD_CHECK);
				} else {
					dragMomentum.x = frameDrag.x;
					dragMomentum.y = frameDrag.y;
				}
				camera.pan(frameDrag.x, frameDrag.y);
			} else {
				camera.pan(dragMomentum.x, dragMomentum.y);
			}
			
			/* disable autoscroll
			if (currentAnimation && !camera.animating && (idleTime > 3000)) {
				if (autoAnimateWaitTime > 0) {
					autoAnimateWaitTime = Math.max(0, autoAnimateWaitTime - dTime);
				} else {
					var source:Point;
					var target:Point;
					if (autoAnimatingToEnd) {
						target = currentAnimation.autoPanEnd;
						source = currentAnimation.autoPanStart;
					} else {
						target = currentAnimation.autoPanStart;
						source = currentAnimation.autoPanEnd;
					}
					if (target) {
						target = target.clone();
						target.x = camera.clampX(target.x);
						target.y = camera.clampY(target.y);
						source = source.clone();
						source.x = camera.clampX(source.x);
						source.y = camera.clampY(source.y);
						
						var speed:Number = 10;
						var move:Number = speed * dTime / 1000;
						var focus:Point = camera.getFocus();
						
						var fromStart:Number = Point.distance(source, focus);
						var fromEnd:Number = Point.distance(target, focus);
						var f:Number = Math.min(1, fromStart / 10, fromEnd / 50);
						//var f:Number = Math.min(1, fromEnd / 50);
						var eased:Number = Utils.easeOut(f);
						move *= (0.01 + 0.99 * eased);
						//trace(fromStart, fromEnd, f, eased, move, autoAnimatingToEnd);
						
						var v:Point = target.subtract(focus);
						if (v.length <= move + 0.1) {
							autoAnimatingToEnd = !autoAnimatingToEnd;
							autoAnimateWaitTime = 2000;
						} else {
							v.normalize(move);
						}
						camera.pan( -v.x, -v.y);
					}
				}
			}
			*/
				
			frameDrag.x = 0;
			frameDrag.y = 0;

			var FALLOFF_PER_SECOND:Number = (dragging) ? 0.6 : 3;
			var falloff:Number = FALLOFF_PER_SECOND * dTime / 1000;
			dragMomentum.normalize(Math.max(0, dragMomentum.length * (1 - falloff) - 1));
			
			camera.animateFloat(dTime);			
			camera.animate(dTime, dragging);
		}
		
		
		protected var secondTime:Number = 0;
		protected var frameCount:Number = 0;
		protected var debugField:TextField;
		protected function handleAnimate(event:Event):void {
			var i:int;
			var time:Number = getTimer();
			var dTime:Number = time - lastFrameTime;
			
			CONFIG::debug {
			
				if (!secondTime) secondTime = time;
				if (time - secondTime >= 1000) {
					secondTime += 1000;

					if (!debugField) {
						debugField = new TextField();
						debugField.width = 200;
						debugField.height = 50;
						debugField.mouseEnabled = false;
						stage.addChild(debugField);
					}
					debugField.text = "" + frameCount;
					//trace(frameCount);

					frameCount = 0;
				}
				frameCount++;
				
			}
			
			
			if (endingInfographic) {
				if (endingInfographic.ended) {
					if (endingInfographic.parent) endingInfographic.parent.removeChild(endingInfographic);
					endingInfographic = null;
				}
			}
			
			if (currentInfographic) {
				currentInfographic.animate(dTime);
				if (currentInfographic.finished) {
					restoreAfterInfographic();
				}
			}
			
			if (!currentInfographic) {
				idleTime += dTime;
				if ((idleTime % IDLE_ANIMATION_TIME) - dTime < 0) {
					var bge:BackgroundEffect = new TiledBackgroundEffect();
					backgroundEffects.push(bge);
					backgroundEffectsLayer.addChild(bge);
				}
				if ((idleTime % IDLE_ABORT_TIME) - dTime < 0) {
					if (homeAnimations.length > 0) {
						var home:HomeAnimationController = homeAnimations[0];
						transitionToChapter(home.boxes[0]);
					}
				}
			}
			
			for (i = backgroundImages.length - 1; i >= 0; i--) {
				var backgroundImage:BackgroundImage = backgroundImages[i];
				backgroundImage.animate(dTime);
				if (backgroundImage.finished) {
					backgroundImages.splice(i, 1);
					if (backgroundImage.parent) backgroundImage.parent.removeChild(backgroundImage);
				}
			}
		
			for (i = clickBlips.length - 1; i >= 0; i--) {
				var blip:ClickBlip = clickBlips[i];
				blip.animate(dTime);
				if (blip.finished) {
					clickBlips.splice(i, 1);
					if (blip.parent) blip.parent.removeChild(blip);
				}
			}
			
			for (i = backgroundEffects.length - 1; i >= 0; i--) {
				bge = backgroundEffects[i];
				bge.animate(dTime);
				if (bge.finished) {
					if (bge.parent) bge.parent.removeChild(bge);
					backgroundEffects.splice(i, 1);
				}
			}

			background.animate(dTime);
			if (!currentInfographic) animateCamera(dTime);
			if (grid) grid.focus(camera.getFocus());

			var camFocus:Point = camera.getFocus();
			
			var homeAnim:HomeAnimationController;
			for each(homeAnim in homeAnimations) {
				homeAnim.continueAnimation(dTime);
			}
			for (i = endingHomeAnimations.length - 1; i >= 0; i--) {
				homeAnim = endingHomeAnimations[i];
				homeAnim.continueAnimation(dTime);
				if (homeAnim.ended) endingHomeAnimations.splice(i, 1);
			}

			var anim:AnimationController;
			for each(anim in currentAnimations) {
				anim.continueAnimation(dTime, (anim == currentAnimation), camFocus);
			}
			for (i = endingAnimations.length - 1; i >= 0; i--) {
				anim = endingAnimations[i];
				anim.continueAnimation(dTime, (anim == currentAnimation), camFocus);
				if (anim.ended) endingAnimations.splice(i, 1);
			}
			
			lastFrameTime = time;
		}
		
		

		protected function handleFullScreenClick(event:MouseEvent):void {
			stage.displayState = StageDisplayState.FULL_SCREEN;
			removeEventListener(MouseEvent.CLICK, handleFullScreenClick);
		}
		protected function handleFullScreenChange(event:FullScreenEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.addEventListener(MouseEvent.CLICK, handleFullScreenClick);
				camera.setScreenSize(stage.stageWidth, stage.stageHeight);
			} else {
				camera.setScreenSize(stage.fullScreenWidth, stage.fullScreenHeight);
			}
		}
		
		protected function fadeOutBackgroundImages():void {
			for each(var backgroundImage:BackgroundImage in backgroundImages) {
				backgroundImage.fadeOut();
			}
		}
		
		
		
		
		
			
		
		







	}

}