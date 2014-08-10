package med.display {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import med.story.Chapter;
	import med.story.Story;

	public class HomeBox extends Box {
		
		public var id:int;
		
		public var start:Point;
		public var destination:Point;
		public var inverted:Boolean;
		public var scale:Number;
		public var startScale:Number;
		public var endScale:Number;
		
		public var defaultColorTransform:ColorTransform;
		
		
		public function HomeBox(chapter:Chapter, id:int) {
			this.chapter = chapter;
			this.id = id;
			
			super(0xFFFFFF);
			
			inverted = false;
			scale = 1;
			startScale = 1;
			endScale = 1;
			
			mouseChildren = false;
			buttonMode = true;
			
			defaultColorTransform = new ColorTransform(1, 1, 1, 0.2);
			
			start = new Point(0, 0);
			destination = new Point(0, 0);
			
		}
		
		static public function createDefaultColorTransform(color:uint):ColorTransform {
			var r:uint = (color & 0xFF0000) >> 16;
			var g:uint = (color & 0xFF00) >> 8;
			var b:uint = (color & 0xFF);
			return new ColorTransform(r / 255, g / 255, b / 255);
		}
		
		
	}

}