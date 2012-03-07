package events
{
	import flash.events.Event;
	
	public class LEvent extends Event
	{
		
		public static const LEFTVERTICALAXISSELECT:String = "leftVerticalAxisSelect";//左侧纵坐标选择
		public static const HORIZONTALAXISSELECT:String="horizontalAxisSelect";//横坐标选择
		public static const RADIUSSELECT:String="radiusSelect";//大小选择
		public static const COLORSELECT:String="colorSelect";//颜色选择
		
		public static const POINTHSLIDERSELECT:String="pointHSliderSelect";//滑动点选择
		public static const POINTHSLIDERMOVETO:String="pointHsliderMoveto";//滑动点移至
		
		public static const ZOOMMINIMAPON:String="zoomMinimapOn";//小地图打开
		public static const ZOOMMINIMAPOFF:String="zoomMinimapOff";//小地图关闭
		
		public static const ZOOMIN:String="zoomOn";//缩放小地图
		public static const ZOOMOUT:String="zoomOut";//回复小地图
		
		public static const BUBBLELABELMOVEIN:String="bubbleLabelMoveIn";
		public static const BUBBLELABELMOVEOUT:String="bubbleLabelMoveOut";
		
		//选中节点
		public static const NODESELECT:String="selectNode_";
		
		//启动轨迹
		public static const TRAILS:String="trails";
		
		public var stanza:Object;
		public function LEvent(type:String, stanza:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{ 
			this.stanza = stanza;
			super(type, bubbles, cancelable);
		}
		
	}
}