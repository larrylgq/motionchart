package UI.base
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class LImageLoader extends Loader
	{
		private var panel:Sprite;
		public var url:String="";
		
		private var _width:Number;
		private var _height:Number;
		
		public function ImageLoader():void{
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errHandle);
		}
		
		/**
		 * 控制
		 */
		public function autoSize(panel:Sprite):void//自动填充
		{
			this.panel=panel;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE,loadingBGAuto);
			if(panel&&panel.stage){
				panel.stage.addEventListener(Event.RESIZE,loadingBGAuto);
			}
		}
		
		public function fixedSize(_width:Number,_height:Number):void//缩为制定大小
		{
			this._width=_width;
			this._height=_height;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE,loadingBGFixed);
		}
		
		public function doLoad():void{
			
			this.load(new URLRequest(url));
		}
		
		/**
		 * 内部方法
		 */
		private function loadingBGAuto(event:Event):void
		{
			if(this.content){
				this.content.width   = panel.width;
				this.content.height = panel.height;
			} 
			
		}
		
		private function loadingBGFixed(event:Event):void
		{
			if(this.content){
				this.content.width   = _width;
				this.content.height = _height;
			}
			
		}
		
		private function errHandle(event:IOErrorEvent):void
		{
			trace("Error:" + event);
		}
	}
}