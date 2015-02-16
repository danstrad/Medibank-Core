package med.infographic {
	import com.garin.Text;
	import com.greensock.easing.BounceInOut;
	import com.greensock.easing.ElasticInOut;
	import com.greensock.easing.SineInOut;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import com.gskinner.utils.Rndm;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class SlidingTag extends Sprite {

		
		
		public static const SMALL:String = "small";
		public static const MEDIUM:String = "medium";
		public static const LARGE:String = "large";
		
		public var size:String;
		
		protected var tag:Shape;
		protected var textMask:Shape;
		
		protected var tagColor:uint;
		protected var textColor:uint;
		
		protected var template:Sprite;
		
		protected var leftTextField:TextField;
		protected var rightTextField:TextField;		
		
		protected var stateIndex:int;
		protected var startLeft:Boolean;
		
		protected static const SMALL_TAG_HEIGHT:Number 	= 42.7;
		protected static const MEDIUM_TAG_HEIGHT:Number = 64;
		protected static const LARGE_TAG_HEIGHT:Number 	= 85.35;
		
		protected var tagXML:XML;
		
		public var numStates:int = 0;
				
		protected var maxWidthLeft:Number = 0;
		protected var maxWidthRight:Number = 0;
		
		protected var featuredTextTop:Number;
		protected var featuredTextBottom:Number;

		
		public function SlidingTag(tagXML:XML, tagColor:uint, textColor:uint, featuredTextTop:Number = -50, featuredTextBottom:Number = 90) {						
			this.tagXML = tagXML;
			this.size = tagXML.@size;
			this.tagColor = tagColor;
			this.textColor = textColor;
			
			this.featuredTextBottom = featuredTextBottom;
			this.featuredTextTop = featuredTextTop;
			
			this.startLeft = (tagXML.@startLeft == "true");
			
			this.numStates = tagXML.tagstate.length();
			
			
			this.stateIsOnLeft = startLeft;
			
			
			// create object for background color
			tag = new Shape();
			addChild(tag);
			
			
			if (size == SMALL) {
				
				template = new _SlidingTagSmall();
				
				leftTextField = _SlidingTagSmall(template).leftTextField;
				rightTextField = _SlidingTagSmall(template).rightTextField;
				
			} else if (size == MEDIUM) {

				template = new _SlidingTagMedium();

				leftTextField = _SlidingTagMedium(template).leftTextField;				
				rightTextField = _SlidingTagMedium(template).rightTextField;
				
			} else if (size == LARGE) {
			
				template = new _SlidingTagLarge();

				leftTextField = _SlidingTagLarge(template).leftTextField;
				rightTextField = _SlidingTagLarge(template).rightTextField;
				
				
			} else {
				trace("invalid sliding tag size: " + size);
				return;
			}
		
			addChild(template);
			
			textMask = new Shape();
			addChild(textMask);
		
			template.mask = textMask;
			
			
			
			
			// we need to figure out what our maximum bounds are, so we need to go through the tag states here at the start and store how big we will get
			for (var i:int = 0; i < numStates; i++) {
				loadState(i);
			}

			// for debug, draw bounds
			/*
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x000000, 0.7);
			this.graphics.drawRect(0, -tagHeight * 0.5, maxWidthRight, tagHeight);
			this.graphics.drawRect(-maxWidthLeft, -tagHeight * 0.5, maxWidthLeft, tagHeight);
			*/
			
			// load first state
			loadState(0);		
		}
		
		
		protected static const EDGE_MARGIN:Number = 30;
		
		
		public function get startX():Number {
			var leftMargin:Number = EDGE_MARGIN;
			var rightMargin:Number = EDGE_MARGIN;
			
			// if we're near the middle of the screen, our left margin is incerased so we don't cover the featured text
			if ((this.y >= featuredTextTop) && (this.y <= featuredTextBottom)) {
				leftMargin = 310;
			}
			
			var maxLeftMovement:Number = 512 - maxWidthLeft - leftMargin;
			
			return -maxLeftMovement;	
		}
		
		
		
		public function startSway():void {
			// add swaying back and forth
			var leftMargin:Number = EDGE_MARGIN;
			var rightMargin:Number = EDGE_MARGIN;
			
			// if we're near the middle of the screen, our left margin is incerased so we don't cover the featured text
			if ((this.y >= featuredTextTop) && (this.y <= featuredTextBottom)) {
				leftMargin = 310;
			}
			
			var maxLeftMovement:Number = 512 - maxWidthLeft - leftMargin;
			var maxRightMovement:Number = 512 - maxWidthRight - rightMargin;
			
			var maxDistance:Number = maxRightMovement + maxLeftMovement;
			
			var delay:Number = Rndm.integer(0, 250) * 0.001;
			var distance:Number = maxDistance;
			var duration:Number = distance * 0.03;
			
			TweenMax.fromTo(this, duration, { x:-maxLeftMovement }, { x:maxRightMovement, repeat:-1, yoyo:true, delay:delay, ease:SineInOut.ease } );
			
		}
		

		
		protected var stateIsOnLeft:Boolean; 
		
		
		
		protected function loadState(index:int):Boolean {
			
			if (index >= tagXML.tagstate.length()) {
				return false;
			}

			this.stateIndex = index;
			var stateXML:XML = tagXML.tagstate[this.stateIndex];
			
			
			if ((stateIndex % 2) == 0) {
				stateIsOnLeft = startLeft;
			} else {
				stateIsOnLeft = !startLeft;
			}
			
			
			var textField:TextField;
			
			if (stateIsOnLeft) {
				textField = leftTextField;
				rightTextField.visible = false;				
			} else {
				textField = rightTextField;
				leftTextField.visible = false;
			}
			
			textField.visible = true;
			textField.text = stateXML.@text;
			textField.textColor = textColor;
			Text.boldText(textField);
			Text.setTextSpacing(textField, textSpacing);
			
			if (textField == leftTextField)		textField.autoSize = TextFieldAutoSize.RIGHT;
			else								textField.autoSize = TextFieldAutoSize.LEFT;
						
			var tagWidth:Number = textField.width + 38;
					
			// draw tag
			
			var tagX:Number;
			
			if (stateIsOnLeft) {
				tagX = -tagWidth;
				maxWidthLeft = Math.max(maxWidthLeft, tagWidth);
			} else {
				tagX = 0;
				maxWidthRight = Math.max(maxWidthRight, tagWidth);
			}
			
			tag.graphics.clear();
			tag.graphics.beginFill(tagColor, 1);
			tag.graphics.drawRect(tagX, tagHeight * -0.5, tagWidth, tagHeight);
			tag.graphics.endFill();			
			
			textMask.graphics.clear();
			textMask.graphics.beginFill(0x00FF00, 0.5);
			textMask.graphics.drawRect(tagX, tagHeight * -0.5, tagWidth, tagHeight);
			textMask.graphics.endFill();
					
			return true;
		}
		
		
		
		public function flip():void {
			
			if (stateIndex >= (numStates - 1)) {
				return;
			}
			
			// move the tag and the mask off
			TweenMax.to(tag, 0.5, { scaleX:0, onComplete:flipToNextState, ease:Strong.easeIn } );
			TweenMax.to(textMask, 0.5, { scaleX:0, ease:Strong.easeIn } );
			
		}
		
		
		protected function flipToNextState():void {
			// when done, flip to the next state
			var oldStateIndex:int = stateIndex;
			
			loadState(Math.min(stateIndex + 1, numStates-1));
			
			if (stateIndex == oldStateIndex) {
				return;
			}
			
			// roll out the tag and mask on the other side			
			TweenMax.fromTo(tag, 0.5, { scaleX:0.0 }, { scaleX:1.0, ease:Strong.easeOut} );
			TweenMax.fromTo(textMask, 0.5, { scaleX:0.0 }, { scaleX:1.0, ease:Strong.easeOut } );

		}
		
		

		protected function get tagHeight():Number {
			if (size == SMALL)			return SMALL_TAG_HEIGHT;
			else if (size == MEDIUM)	return MEDIUM_TAG_HEIGHT;
			else if (size == LARGE)		return LARGE_TAG_HEIGHT;
			else						return 0;
		}
		
				
		protected function get textSpacing():Number {
			if (size == SMALL)			return -0.4;
			else if (size == MEDIUM)	return -0.6;
			else if (size == LARGE)		return -0.8;
			else						return 0;
		}
				
		
	}

}