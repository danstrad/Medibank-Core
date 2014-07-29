package com.garin {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Generic drawing / graphics methods
	 * @author Daniel Stradwick "garin"
	 */
	
	public class Drawing {
		
		public static function drawSector(canvas:Sprite, fillColor:uint, alpha:Number, x:Number, y:Number, innerRadius:Number, outerRadius:Number, angle:Number, startA:Number, clearCanvasFirst:Boolean = true, outlineColor:uint=0xffffff, outlineWidth:Number=0.1):void {
			var sector:Sprite;

			var r:Number = innerRadius;
			var R:Number = outerRadius;
			if (canvas == null) 	return;
			else 					sector = canvas;

			if (clearCanvasFirst)	sector.graphics.clear();
			
			if (outlineWidth == 0.1)	sector.graphics.lineStyle(0.1, fillColor, alpha);
			else if (outlineWidth > 0)	sector.graphics.lineStyle(outlineWidth, outlineColor, alpha);
			else						sector.graphics.lineStyle();
			
			sector.graphics.beginFill(fillColor, alpha);
 
			if (Math.abs(angle) > 360) 		angle=360;

			var n:Number = Math.ceil(Math.abs(angle) / 45);
			var angleA:Number = angle / n;
 
			angleA = angleA * Math.PI / 180;
			startA = startA * Math.PI / 180;

			var startB:Number = startA;

			// start edge
			sector.graphics.moveTo(x + r * Math.cos(startA), y + r * Math.sin(startA));
			sector.graphics.lineTo(x + R * Math.cos(startA), y + R * Math.sin(startA));

			// outer arc
			for (var i:int = 1; i <= n; i++) {
				startA += angleA;
 
				var angleMid1:Number = startA - angleA / 2;
				var bx:Number = x + R / Math.cos(angleA / 2) * Math.cos(angleMid1);
				var by:Number = y + R / Math.cos(angleA / 2) * Math.sin(angleMid1);
				var cx:Number = x + R * Math.cos(startA);
				var cy:Number = y + R * Math.sin(startA);

				sector.graphics.curveTo(bx, by, cx, cy);
			}

			// start position of inner arc
			sector.graphics.lineTo(x + r * Math.cos(startA),y + r * Math.sin(startA));
	
			var j:int = n;
			
			// inner arc
			while (j >= 1) {

				startA -= angleA;
 
				var angleMid2:Number=startA + angleA / 2;
				var bx2:Number=x + r / Math.cos(angleA / 2) * Math.cos(angleMid2);
				var by2:Number=y + r / Math.cos(angleA / 2) * Math.sin(angleMid2);
				var cx2:Number=x + r * Math.cos(startA);
				var cy2:Number=y + r * Math.sin(startA);
 
				sector.graphics.curveTo(bx2, by2, cx2, cy2);
				j--;
			}
 
			// end position of inner arc.
			sector.graphics.lineTo(x + r * Math.cos(startB),y + r * Math.sin(startB));
	
			//done
			sector.graphics.endFill();
		}		
		
		
		
		public static function drawRectangle(graphics:Graphics, rectangle:Rectangle):void {
			graphics.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		}
		

		public static function drawDebugMarker(g:Graphics, p:Point=null, radius:int=8, color:uint=0xff0000):void {
			if (p == null) p = new Point(0, 0);
			
			g.lineStyle(1, color);
			g.moveTo(p.x - radius, p.y);
			g.lineTo(p.x + radius, p.y);
			g.moveTo(p.x, p.y - radius);
			g.lineTo(p.x, p.y + radius);
			g.lineStyle();
		}
		
	}		

}