package larry.components.list
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;

	public class VBox extends Sprite
	{
		public var _width:Number = 0;//宽度
		public var _height:Number = 0;//高度
		public var _border:Boolean = true;//是否显示边框
		protected var _spacing:Number = 5;//间隔
		public var miniWidth:Number=0;//最小宽度
		public var miniHeight:Number=0;//最大宽度
		
		public function VBox()
		{
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		//初始化
		protected function onInvalidate(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			update();
		}
		
		//添加节点至指定位置
		override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
		{
			super.addChildAt(child, index);
			update();
			return child;
		}
		//添加节点
		override public function addChild(child:DisplayObject) : DisplayObject
		{
			super.addChild(child);
			update();
			return child;
		}
		
		//删除节点
        override public function removeChild(child:DisplayObject):DisplayObject
        {
            super.removeChild(child);            
			update();
            return child;
        }
		
		//删除指定位置节点
        override public function removeChildAt(index:int):DisplayObject
        {
            var child:DisplayObject = super.removeChildAt(index);
			update();
            return child;
        }
		
		//删除所有节点
		public function removeAllChild():void{
			for(var i:int = numChildren; i >0; i--)
			{
				super.removeChildAt(i-1);
			}
			this.update();
		}
		
		/**
		 * Draws the visual ui of the component, in this case, laying out the sub components.
		 */
		public function update() : void
		{
			this.graphics.clear();
			_width = 0;
			_height = 0;
			var ypos:Number = 1;
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.x = 1;
				child.y = ypos;
				ypos += child.height;
				ypos += _spacing;
				_height += child.height;
				_width = Math.max(_width, child.width);
			}
			_height += _spacing * (numChildren - 1);
			
			var borderWidth:Number=Math.max(miniWidth,_width);
			var borderHeight:Number=Math.max(miniHeight,_height);
			if(_border==true){
				this.graphics.lineStyle(1,0x000000,1);
			}else{
				this.graphics.lineStyle(1,0x000000,0);
			}
			this.graphics.beginFill(0xffffff,1);
			this.graphics.drawRoundRect(0,0,borderWidth+1,borderHeight+1,5,5);
			this.graphics.endFill();
		}
		
		/**
		 * Gets / sets the spacing between each sub component.
		 */
		public function set spacing(s:Number):void
		{
			_spacing = s;
			update();
		}
		public function get spacing():Number
		{
			return _spacing;
		}
		
		public function set border(_border:Boolean):void{
			this._border=_border;
			this.update();
		}
		
		public function get border():Boolean{
			return _border;
		}
		
		/**
		 * Sets/gets the width of the component.
		 */
		override public function set width(w:Number):void
		{
			_width = w;
			update();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get width():Number
		{
			return _width;
		}
		
		/**
		 * Sets/gets the height of the component.
		 */
		override public function set height(h:Number):void
		{
			_height = h;
			update();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get height():Number
		{
			return _height;
		}
	}
}