package med.infographic {
	import flash.display.Sprite;

	public interface ISlide {
		
		function animateOn():void;
		function animateOff(callback:Function):void;	// the callback function takes the ISlide as the parameter
		
		function animate(dTime:Number):void;
		
		
	}

}