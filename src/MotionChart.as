package
{
	import UI.LBubbleChart;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.ui.ContextMenu;
	
	import utils.ThemeHander;
	import utils.Utility;

	/**
	 * 五维图表
	 */
	public class MotionChart extends Sprite
	{
		private var _utility:Utility=Utility.getInstance();//公共属性类
		private var _themeHander:ThemeHander=ThemeHander.getInstance();//皮肤类
		
		public function MotionChart()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,init);//监听加载到舞台的事件
		}
		
		private function init(event:Event):void{
			if(this.stage){//舞台初始化完毕
				stage.scaleMode = StageScaleMode.NO_SCALE;//舞台是否拉伸
				stage.align = StageAlign.TOP_LEFT;//在舞台中的位置
				
				_utility.appSprite=this;//将此类设置为本应用的跟容器
				doInitApp();//初始化根容器
				this.removeEventListener(Event.ADDED_TO_STAGE,init);//删除加载到舞台的监听
			}
		}
		
		/**
		 * 初始化操作
		 * 注意：方法内代码顺序不可变
		 */
		public function doInitApp():void{  
			createRightButton();//创建右键菜单
			
			ExternalInterface.addCallback("setStyle",setStyle);//定制样式
			ExternalInterface.call("style");//
			
			addChart();//加载montionchart
		}
		
		/**
		 * 接收定制样式
		 * 注意：要在画图表前
		 */
		public function setStyle(key:String,value:Object):void{
			ThemeHander.style[key]=value;
		}
		
		/**
		 * 定制右键
		 */
		private function createRightButton():void{
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			cm.builtInItems.print=true;
			this.contextMenu=cm;
		}
		
		/**
		 * 加载图表
		 */
		private var bubbleChart:LBubbleChart;  
		private function addChart():void{
			for(var i:int=0;i<this.numChildren;i++){//清空跟容器下的子容器
				this.removeChildAt(0);
			}
			
			bubbleChart=new LBubbleChart();//新建散点图表
			this.addChild(bubbleChart);//将散点图表容器加载到跟容器下
			bubbleChart.addResizeListener(this.stage);//监听舞台大小改变事件
		}
		
		//事件
		
	}
}