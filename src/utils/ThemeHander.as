package utils
{
	

	public class ThemeHander
	{
		/**
		 *单例
		 */
		private static var __instance:ThemeHander=null;
		public static function getInstance():ThemeHander
		{
			if(__instance == null)
			{
				__instance=new ThemeHander();
			}  
			return __instance;
		}
		
		/**
		 * 样式
		 */
		public static var style:Array=[];
		public function ThemeHander()
		{
			//全局
			style["app_bg"] = 0xffffff;
			style["app_alpha"] = 0.8;
			
			//属性面板
			style["attributepanel_y"] = 0;
			style["attributepanel_width"] = 120;
			style["attributepanel_right"] = 10;
			
			//竖坐标选择
			style["leftvComboBox_width"] = 150;
			style["leftvComboBox_height"] = 25;
			style["leftvComboBox_x"] = 20;
			style["leftvComboBox_bottom"] = 60 + 50 + 150;
			//横坐标选择
			style["hComboBox_height"] = 25;
			style["hComboBox_right"] = 150;
			style["hComboBox_x"] = 60;
			style["hComboBox_bottom"] = 50;
			//圆心大小
			style["rComboBox_right"] = 20;
			style["rComboBox_width"] = 120;
			style["rComboBox_y"] = 145;
			//圆心颜色
			style["cComboBox_right"] = 20;
			style["cComboBox_width"] = 120;
			style["cComboBox_y"] = 40;
			//zoom小地图
			style["zoomMinimap_right"] = 20;
			style["zoomMinimap_width"] = 120;
			style["zoomMinimap_height"] = 52;
			style["zoomMinimap_y"] = 200;
			
			//滑动块
			style["pointHSlider_x"] = 20;
			style["pointHSlider_bottom"] = 10 + 30;
			style["pointHSlider_right"] = 150;
			
			//表格
			style["leftvertical_width"] = 40;//竖坐标宽度
			style["horizontal_height"] = 30;//横坐标宽度
			style["table_x"] = 60;//必须大于竖坐标的left+height
			style["table_y"] = 20;
			style["table_right"] = 150;//必须小于属性面板的x
			style["table_bottom"] = 30 + 50;//必须大于horizontal_bottom+hComboBox_height
			style["table_width"] = 0;
			style["table_height"] = 0;
			style["table_borderColor"] = 0x999999;
			style["table_borderWeight"] = 1;
			
			style["table_gridColor"] = 0xCCCCCC;
			
			//坐标
			style["axis_color"] = 0x999999;
			style["label_color"] = 0x999999;
			
			//字体
			style["font"] = "宋体";
			
			//节点
			style["bubblenode_minradius"] = 8;
			style["bubblenode_maxradius"] = 16;
			
		}
		
		/**
		 * 图片
		 */
		//public static var qqmap:String = "images/_dynamic/qqmap.png";
	}
}