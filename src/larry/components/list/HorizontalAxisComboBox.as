package larry.components.list
{
	import UI.base.LImageLoader;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.ThemeHander;
	
	public class HorizontalAxisComboBox extends Sprite
	{
		public static const TOP:String = "top";
		public static const LEFT:String = "left";
		
		protected var _defaultLabel:String = "";
		public var labelText:TextField=new TextField();
		public var _list:LList=new LList();
		protected var _open:Boolean = false;
		
		public var _openPosition:String=LEFT;
		
		public var _stage:Stage;
		
		private var vTextFormat:TextFormat;
		
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		
		private var iconLoader:LImageLoader=new LImageLoader();
		public function HorizontalAxisComboBox()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			iconLoader.url="images/arrow.png";
			iconLoader.doLoad();   
			this.addChild(iconLoader);
			
			vTextFormat=new TextFormat();
			vTextFormat.font=ThemeHander.style["font"];
			labelText.selectable=false;
			labelText.defaultTextFormat=vTextFormat;
			this.addChild(labelText);
			
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			
			_list.addEventListener(Event.SELECT,onSelect);
			onUpdate();
		}
		
		private function onUpdate():void{
			this.graphics.clear();
			this.graphics.lineStyle(1,0xcccccc);
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRoundRect(0,0,this._width,this._height,5,5);
			this.graphics.endFill();
			
			iconLoader.x=this._width-20;
			if(this.openPosition==TOP){
				iconLoader.y=20;
				iconLoader.rotation=-180;
			}else if(this.openPosition==LEFT){
				iconLoader.y=5;
				//iconLoader.rotation=360;
			}
			
			labelText.x=20;
			labelText.y=3;
			labelText.width=this.width-40;
			labelText.height=20;
			
			_list.miniWidth=this._width;
		}
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		private function onOver(event:MouseEvent=null):void{
			this.graphics.clear();
			this.graphics.lineStyle(1,0x222222);
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRoundRect(0,0,this._width,this._height,5,5);
			this.graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onOut(event:MouseEvent=null):void{
			if(_open){
				
			}else{
				this.graphics.clear();
				this.graphics.lineStyle(1,0xcccccc);
				this.graphics.beginFill(0x000000,0);
				this.graphics.drawRoundRect(0,0,this._width,this._height,5,5);
				this.graphics.endFill();
			}
			this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		/**
		 * Called when one of the top buttons is pressed. Either opens or closes the list.
		 */
		protected function onClick(event:MouseEvent=null):void
		{
			if(this.mouseX>0&&this.mouseX<this._width&&this.mouseY>0&&this.mouseY<this._height){
			}else{
				_open=false;
				if(_stage.contains(_list)) _stage.removeChild(_list);
				onOut();
				return;
			}
			_open = !_open;
			if(_open)
			{
				var point:Point = new Point(0,0);
				point = this.localToGlobal(point);
				if(this.openPosition==TOP){
					_list.x=point.x;
					_list.y=point.y-_list.height;
				}else if(this.openPosition==LEFT){
					_list.x=point.x-_list.width;
					_list.y=point.y;
				}
				_list.miniWidth=this._width;
				_list.update();
				_stage.addChild(_list);
				
			}else{
				if(_stage.contains(_list)) _stage.removeChild(_list);
			}
		}
		
		/**
		 * Called when an item in the list is selected. Displays that item in the label button.
		 */
		protected function onSelect(event:Event):void
		{
			if(_stage.contains(_list)) _stage.removeChild(_list);
			this.labelText.text=_list.selectedItem.toString();
			dispatchEvent(event);
		}
		
		/**
		 * Called when the component is added to the stage.
		 */
		protected function onAddedToStage(event:Event):void
		{
			_stage = stage;
			_stage.addEventListener(MouseEvent.CLICK,onClick);
		}
		
		/**
		 * Called when the component is removed from the stage.
		 */
		protected function onRemovedFromStage(event:Event):void
		{
			_open=false;
			if(_stage.contains(_list)) _stage.removeChild(_list);
			this.labelText.text=_list.selectedItem.toString();
		}
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		/**
		 * Sets/gets the width of the component.
		 */
		override public function set width(w:Number):void
		{
			_width = w;
			this.onUpdate();
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
			this.onUpdate();
		}
		override public function get height():Number
		{
			return _height;
		}
		public function set defaultLabel(_defaultLabel:String):void{
			_defaultLabel=_defaultLabel;
			labelText.text=_defaultLabel;
		}
		
		public function get defaultLabel():String{
			return _defaultLabel;
		}
		
		public function set openPosition(_openPosition:String):void{
			this._openPosition=_openPosition;
			this.onUpdate();
		}
		
		public function get openPosition():String{
			return _openPosition;
		}
	}
}