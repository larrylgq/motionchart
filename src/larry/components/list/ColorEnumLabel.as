package larry.components.list
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class ColorEnumLabel extends Sprite
	{
		public var color:uint=0x000000;
		public var value:String="";
		
		private var label:TextField=new TextField();
		public function ColorEnumLabel()
		{
			super();
		}
		
		public function draw():void{
			this.graphics.clear();
			this.graphics.lineStyle(1,0x000000);
			this.graphics.beginFill(color,1);
			this.graphics.drawRect(5,5,15,15);
			this.graphics.endFill();
			
			label.text=value;
			label.x=20;
		}
	}
}