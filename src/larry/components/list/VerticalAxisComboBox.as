package larry.components.list
{
	import UI.base.LImageLoader;
	
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class VerticalAxisComboBox extends Sprite
	{
		protected var _defaultLabel:String = "";
		public var labelText:TextField=new TextField();
		public var _list:LList=new LList();
		protected var _open:Boolean = false;
		
		public var _stage:Stage;
		
		private var vTextFormat:TextFormat;
		
		
		private var iconLoader:LImageLoader=new LImageLoader();
		public function VerticalAxisComboBox()
		{
			super();
			_list.miniWidth=200;
			_list.miniHeight=150;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			this.graphics.lineStyle(1,0xcccccc);
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRoundRect(0,0,25,150,5,5);
			this.graphics.endFill();
			
			iconLoader.url="images/arrow.png";
			iconLoader.doLoad();   
			iconLoader.rotation=-90;
			iconLoader.x=8;
			iconLoader.y=20;
			this.addChild(iconLoader);
			
			vTextFormat=new TextFormat();
			vTextFormat.font="PF Ronda Seven";
			labelText.embedFonts=true;
			labelText.selectable=false;
			labelText.defaultTextFormat=vTextFormat;
			labelText.rotation=-90;
			labelText.y=150-20;
			labelText.width=150-40;
			labelText.height=25;
			this.addChild(labelText);
			
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			
			_list.addEventListener(Event.SELECT,onSelect);
		}
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		private function onOver(event:MouseEvent=null):void{
			this.graphics.clear();
			this.graphics.lineStyle(1,0x222222);
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRoundRect(0,0,25,150,5,5);
			this.graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onOut(event:MouseEvent=null):void{
			if(_open){
				
			}else{
				this.graphics.clear();
				this.graphics.lineStyle(1,0xcccccc);
				this.graphics.beginFill(0x000000,0);
				this.graphics.drawRoundRect(0,0,25,150,5,5);
				this.graphics.endFill();
			}
			this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		/**
		 * Called when one of the top buttons is pressed. Either opens or closes the list.
		 */
		protected function onClick(event:MouseEvent=null):void
		{
			if(this.mouseX>0&&this.mouseX<25&&this.mouseY>0&&this.mouseY<150){
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
				_list.x=point.x+25;
				_list.y=point.y;
				
				//_list.
				Tweener.addTween(_list, 
					{ x:point.x+25, y:point.y,width:200,height:150,time:3} );
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
			_open=false;
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
			onClick();
		}
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		public function set defaultLabel(_defaultLabel:String):void{
			_defaultLabel=_defaultLabel;
			labelText.text=_defaultLabel;
		}
		
		public function get defaultLabel():String{
			return _defaultLabel;
		}
	}
}