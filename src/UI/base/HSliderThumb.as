package UI.base
{
	import flash.display.Sprite;
	
	import utils.ThemeHander;
	
	public class HSliderThumb extends Sprite
	{
		public function HSliderThumb()
		{
			super();
		}
		
		public function setSize(_width:Number,_height:Number):void{
			this.graphics.clear();
			this.graphics.lineStyle(0.5,ThemeHander.style["table_borderColor"],0.8);
			this.graphics.beginFill(0xffffff,1);
			this.graphics.drawRoundRect(0,0,_width,_height,3);
			this.graphics.endFill();
			
			this.graphics.lineStyle(0.5,0x000000,0.8);
			this.graphics.moveTo(_width*0.5, 5);
			this.graphics.lineTo(_width*0.5, _height-5);
		}
	}
}