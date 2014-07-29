package src.src.com.garin.ui 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Daniel Stradwick "garin"
	 */
	
	public class GenericButton extends Sprite {
		
		public var clip:MovieClip;
		
		
		public function GenericButton(m_clip:MovieClip):void {
			
			if (clip == null) {
				clip = new GenericButtonSWF();
				addChild(clip);
			} else
				clip = m_clip;
			
		}

		
	}

}