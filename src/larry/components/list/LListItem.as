
package larry.components.list
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class LListItem extends Sprite
	{
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		protected var _data:Object;
		protected var _label:TextField=new TextField();
		
		protected var _defaultColor:uint = 0xffffff;
		protected var _selectedColor:uint = 0x999999;
		protected var _rolloverColor:uint = 0xdddddd;
		protected var _selected:Boolean;
		protected var _mouseOver:Boolean = false;
		
		public function LListItem(data:Object = null)
		{
			_data = data;
			this.addChild(_label);
			_label.selectable=false;
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.CLICK,onSelect);
			draw();
		}
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		private var forEnum:Boolean=false;
		public function draw() : void
		{
			graphics.clear();
			if(!forEnum){
				if(_selected)
				{
					graphics.beginFill(_selectedColor);
				}
				else if(_mouseOver)
				{
					graphics.beginFill(_rolloverColor);
				}
				else
				{
					graphics.beginFill(_defaultColor);
				}
			}
			if(_data is String)
			{
				_label.text = _data as String;
			}else if(_data is EnumItem){
				forEnum=true;
				graphics.beginFill(EnumItem(_data).value);
				_label.text = EnumItem(_data).key;
			}
			else if(_data.label is String)
			{
				_label.text = _data.label;
			}
			else
			{
				_label.text = _data.toString();
			}
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		/**
		 * Sets/gets the width of the component.
		 */
		override public function set width(w:Number):void
		{
			_width = w;
			this.draw();
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
			this.draw();
		}
		override public function get height():Number
		{
			return _height;
		}
		
		private function onSelect(event:MouseEvent):void{
			if(this.parent){
				Object(parent).selectedItem=this;
			}
		}
		
		/**
		 * Called when the user rolls the mouse over the item. Changes the background color.
		 */
		protected function onMouseOver(event:MouseEvent):void
		{
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_mouseOver = true;
			this.draw();
		}
		
		/**
		 * Called when the user rolls the mouse off the item. Changes the background color.
		 */
		protected function onMouseOut(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_mouseOver = false;
			this.draw();
		}
		
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets/gets the string that appears in this item.
		 */
		public function set data(value:Object):void
		{
			_data = value;
			this.draw();
		}
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * Sets/gets whether or not this item is selected.
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			this.draw();
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		
		
	}
}