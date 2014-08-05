package med.infographic {
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.garin.Text;
	
	
	public class FloatingBox extends _FloatingBox {

		
		protected static const BOX_SIZE:Number = 256;
		
		
		
		public function FloatingBox(numberString:String, testString:String, boxColor:uint, textColor:uint) {
						
			numberField.text = numberString;
			numberField.textColor = textColor;
			Text.boldText(numberField);
			Text.setTextSpacing(numberField, -1);
						
			textField.text = testString;
			textField.textColor = textColor;
			Text.boldText(textField);
						
			// draw the box
			graphics.clear();
			graphics.beginFill(boxColor, 1.0);
			graphics.drawRect(-BOX_SIZE*0.5, -BOX_SIZE*0.5, BOX_SIZE, BOX_SIZE);
			graphics.endFill();
			
		}
		
		
		public function bringForward():void {
			// todo
			
			TweenMax.to(this, 1.0, { scaleX:1.0, scaleY:1.0, alpha:1.0, blurFilter: { blurX:0, blurY:0 }, ease:SineIn.ease}); 					
				
		}
		
		public function sendBack():void {
			
		}
		
		

	}

}