package larry.components.list
{
	import events.LEvent;
	
	import fl.controls.CheckBox;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import utils.Utility;
	
	/**
	 * 媒体选择
	 */
	public class LSelectItem extends Sprite
	{
		private var _utility:Utility=Utility.getInstance();//公共属性类
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var checkBox:CheckBox=new CheckBox();
		
		protected var _defaultColor:uint = 0xffffff;
		protected var _rolloverColor:uint = 0xdddddd;
		protected var _selected:Boolean=false;
		
		
		protected var _mouseOver:Boolean = false;
		public var nodeID:String;
		
		public function LSelectItem(_nodeID:String)
		{
				nodeID = _nodeID;
				this.addChild(checkBox);
				checkBox.label=nodeID;
				
				addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
				checkBox.addEventListener(MouseEvent.CLICK,onSelect);
				_utility.addEventListener(LEvent.NODESELECT+nodeID,nodeSelectFunction);
				
				draw();
			}
			
			
			///////////////////////////////////
			// public methods
			///////////////////////////////////
			
			/**
			 * Draws the visual ui of the component.
			 */
			public function draw() : void
			{
				checkBox.width=this.width;
				checkBox.height=this.height;
				
				graphics.clear();
				if(_mouseOver)
				{
					graphics.beginFill(_rolloverColor);
				}
				else
				{
					graphics.beginFill(_defaultColor);
				}
				graphics.drawRect(0, 0, _width, _height);
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
				draw();
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
				this.draw();
				dispatchEvent(new Event(Event.RESIZE));
			}
			override public function get height():Number
			{
				return _height;
			}
			
			private function onSelect(event:MouseEvent):void{
				this._utility.dispatchEvent(new LEvent(LEvent.NODESELECT+nodeID,this.checkBox.selected));
			}
			
			private function nodeSelectFunction(event:LEvent):void{
				this.checkBox.selected=event.stanza as Boolean;
			}
			
			protected function onMouseOver(event:MouseEvent):void
			{
				addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_mouseOver = true;
				this.draw();
			}
			
			protected function onMouseOut(event:MouseEvent):void
			{
				removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_mouseOver = false;
				this.draw();
			}
		}
	}