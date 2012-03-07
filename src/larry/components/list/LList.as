package larry.components.list
{
	
	import flash.events.Event;
	
	public class LList extends VBox
	{
		protected var _items:Array=[];
		
		public var itemHeight:Number = 20;
		
		protected var _selectedIndex:int = -1;
		
		public function LList()
		{
			this.spacing=0;//将间隔去掉
		}
		
		public override function update() : void
		{
			for(var i:int=0;i<this.numChildren;i++){
				LListItem(this.getChildAt(i)).width=Math.max(this.miniWidth,this.width);
				LListItem(this.getChildAt(i)).height=itemHeight;
			}
			super.update();
		}
		
		public function set selectedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
				this.update();
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedItem(item:Object):void
		{
			var index:int = _items.indexOf(item.data);
			if(index != -1)
			{
				for(var i:int=0;i<this.numChildren;i++){
					if(Object(this.getChildAt(i))==item){
						Object(this.getChildAt(i)).selected=true;
					}else{
						Object(this.getChildAt(i)).selected=false;
					}
				}  
				selectedIndex = index;
				this.update();
			}
		}
		public function get selectedItem():Object
		{
			if(_selectedIndex >= 0 && _selectedIndex < _items.length)
			{
				return _items[_selectedIndex];
			}
			return null;
		}
		
		//get set
		public function set listItemHeight(value:Number):void
		{
			itemHeight = value;
			this.update();
		}
		
		public function get listItemHeight():Number
		{
			return itemHeight;
		}
		
		public function set items(value:Array):void
		{
			this.removeAllChild();
			_items = value;
			for(var i:int = 0; i < value.length; i++)
			{
				var child:LListItem = new LListItem(value[i]);
				child.width=Math.max(this.miniWidth,this.width);
				child.height=itemHeight;
				this.addChild(child);
			}
			this.update();
		}
		
		public function get items():Array
		{
			return _items;
		}
	}
}