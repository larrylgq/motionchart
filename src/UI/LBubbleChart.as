package UI
{
	import UI.base.LImageLoader;
	import UI.base.PointHSlider;
	import UI.bubblechart.LBubbleNode;
	import UI.bubblechart.LBubbleTable;
	
	import events.LEvent;
	
	import fl.containers.ScrollPane;
	import fl.controls.CheckBox;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import larry.components.list.EnumItem;
	import larry.components.list.HorizontalAxisComboBox;
	import larry.components.list.LList;
	import larry.components.list.LSelectItem;
	import larry.components.list.VBox;
	import larry.components.list.VerticalAxisComboBox;
	
	import utils.ThemeHander;
	import utils.Utility;
	
	/**
	 * BubbleChart  
	 * 最小值：430*220
	 * 
	 * xField
	 * yField
	 * colorField
	 * radiusField
	 * displayName
	 */
	public class LBubbleChart extends Sprite
	{ 
		//模拟数据格式
		private var data:Object = null;
		/*private var data:Object=
			{
				"xField":"Exposure","yField":"Click","radiusField":"Cost","colorField":"CTR",
				"displayName":"MediaName","slidingShaft":"Date",
				"columns":[
					["date","Date"],
					["string","MediaName"],
					["number","Exposure"],
					["number","Click"],
					["number","Cost"],
					["percent","CTR"],
					["number","CPC"],
					["enum","Location"]
				],
				"rows":[
					["2011-2-2","Sina",15181153,28322,346,0.001865603,0.012216651,"West"],
					["2011-1-1","Sina",15220453,7302,1767,0.000479749,0.241988496,"East"],
					["2011-3-3","Sina",14913147,6016,877,0.000403402,0.145777926,"Center"],
					
					["2011-1-1","SOHU",13215968,59266,42,0.004484424,0.000708669,"East"],
					["2011-3-3","SOHU",13246085,23329,1472,0.0017612,0.063097432,"Center"],
					["2011-2-2","SOHU",13304758,4496,72,0.000337924,0.016014235,"West"],
					
					["2011-2-2","QQ",12477602,58687,848,0.004703388,0.014449537,"West"],
					["2011-3-3","QQ",12416152,2291,0,0.000184518,0.0,"Center"],
					["2011-1-1","QQ",12492286,65722,7,0.005261007,0.000106509,"East"],
					
					["2011-3-3","Baidu",11425658,5051,1351,0.000442075,0.267471788,"Center"],
					["2011-1-1","Baidu",11486227,2273,515,0.000197889,0.226572811,"East"],
					["2011-2-2","Baidu",11446680,7542,1458,0.000658881,0.193317422,"West"],
					
					["2011-2-2","MSN",9363155,5182,1283,0.000553446,0.247587804,"West"],
					["2011-1-1","MSN",9368712,26619,639,0.002841266,0.02400541,"East"],
					["2011-3-3","MSN",9339946,4421,1012,0.000473343,0.228907487,"Center"]
				]
			};*/
		
		/**/
		//左侧垂直轴纬度选择
		public var leftVerticalAxis:VerticalAxisComboBox;//纵坐标combox
		public var horizontalAxis:HorizontalAxisComboBox;//横坐标combox
		public var bubbleTable:LBubbleTable;//图表类(有多个层)
		
		
		public var radiusLabel:TextField;//选择大小
		public var radiusCombox:HorizontalAxisComboBox;
		private var radiusyardstick:Shape = new Shape();
		
		public var colorLabel:TextField;//颜色
		public var colorCombox:HorizontalAxisComboBox;
		public var colorIconRuler:Sprite = new Sprite();
		public var topColoryardstick:TextField;
		public var bottomColoryardstick:TextField;
		
		public var zoomLabel:TextField;//缩放
		public var zoomOutLabel:TextField;
		
		//选择
		public var selectLabel:TextField;//选中
		public var disSelectLabel:TextField;//取消选中
		
		public var hSlider:PointHSlider = new PointHSlider();//滑块
		
		private var _utility:Utility = Utility.getInstance();//公共属性类
		private var _themeHander:ThemeHander = ThemeHander.getInstance();//主题
		
		private var _width:Number = width;
		private var _height:Number = height;
		
		//颜色label
		private var cLabel:TextField;
		private var rLabel:TextField;
		private var rTotalLabel:TextField;
		//属性面板
		private var propertyVBox:VBox = new VBox();
		
		private var colorPanel:Sprite = new Sprite();
		private var coloryardstickSprite:Sprite = new Sprite();//标尺块
		
		private var zoom_SelectSprite:Sprite = new Sprite();//用于缩放区域
		
		//
		private var colorEnumScollPanel:ScrollPane = new ScrollPane();
		private var colorEnumlList:LList = new LList();//用于颜色枚举
		
		//选择节点面板
		private var nodeSelectScrollPanel:ScrollPane  =  new ScrollPane();
		private var nodeSelectVBox:VBox  =  new VBox();
		
		//轨迹
		private var trails:CheckBox;
		
		public function LBubbleChart()
		{
			super();  
			//表格
			bubbleTable = new LBubbleTable();//新建散点图表格
			bubbleTable.x = ThemeHander.style["table_x"];//设置表格的x
			bubbleTable.y = ThemeHander.style["table_y"];
			this.addChild(bubbleTable);  //
			bubbleTable.doResize(_width,_height);//设置散点图表格的大小
			
			//竖坐标
			leftVerticalAxis = new VerticalAxisComboBox();//竖坐标
			leftVerticalAxis.x = ThemeHander.style["leftvComboBox_x"];
			leftVerticalAxis.y = _height-ThemeHander.style["leftvComboBox_bottom"] - 150;
			leftVerticalAxis.addEventListener(Event.SELECT, onLeftVerticalAxisSelect);
			this.addChild(leftVerticalAxis);
			
			//横坐标
			horizontalAxis = new HorizontalAxisComboBox();
			horizontalAxis.x = ThemeHander.style["hComboBox_x"];
			horizontalAxis.y = _height-ThemeHander.style["hComboBox_bottom"]-ThemeHander.style["hComboBox_height"];
			horizontalAxis.width = _width-ThemeHander.style["hComboBox_right"]-
				ThemeHander.style["hComboBox_x"];
			horizontalAxis.height = ThemeHander.style["hComboBox_height"];
			horizontalAxis.openPosition = "top";//横坐标combox打开方向
			horizontalAxis.addEventListener(Event.SELECT , onHorizontalAxisSelect);
			this.addChild(horizontalAxis);
			
			//属性面板
			propertyVBox.border = false;//设置属性面板的边框
			propertyVBox.spacing = 5;//设置属性面板子组件间隔为3
			propertyVBox.x = this._width-ThemeHander.style["attributepanel_right"] - ThemeHander.style["attributepanel_width"];
			propertyVBox.y = 20;
			this.addChild(propertyVBox);
			
			//圆的颜色    label
			colorLabel = Utility.getInstance().getTextField(0,0,12,ThemeHander.style["label_color"],"left");
			colorLabel.selectable = false;
			colorLabel.text = "颜色";
			propertyVBox.addChild(colorLabel);
			//颜色combox
			colorCombox = new HorizontalAxisComboBox();
			colorCombox.width = ThemeHander.style["attributepanel_width"];
			colorCombox.height = 25;
			colorCombox.openPosition = "left";//颜色combox打开方向
			colorCombox.addEventListener(Event.SELECT, onColorSelect);
			propertyVBox.addChild(colorCombox);
			
			colorPanel.addChild(coloryardstickSprite);
			
			colorEnumlList.border = false;
			colorEnumlList.miniHeight = 60;
			colorEnumlList.miniWidth = ThemeHander.style["attributepanel_width"];
			colorEnumScollPanel.source = colorEnumlList;
			colorEnumScollPanel.horizontalScrollPolicy = "off";
			colorEnumScollPanel.width = ThemeHander.style["attributepanel_width"];
			colorEnumScollPanel.height = 60;
			
			
			propertyVBox.addChild(colorPanel);
			//颜色标尺
			colorIconRuler = getColorRuler();  
			coloryardstickSprite.addChild(colorIconRuler);
			
			topColoryardstick = Utility.getInstance().getTextField(60, 20,12,ThemeHander.style["label_color"],"left");
			topColoryardstick.x = 15;
			coloryardstickSprite.addChild(topColoryardstick);
			bottomColoryardstick = Utility.getInstance().getTextField(60, 20,12,ThemeHander.style["label_color"],"left");
			bottomColoryardstick.x = 15;
			bottomColoryardstick.y = 50;
			coloryardstickSprite.addChild(bottomColoryardstick);
			
			//当前颜色值
			cLabel = Utility.getInstance().getTextField(0,
				0,14,0x000000,"left")
			cLabel.background = true;
			cLabel.backgroundColor = 0xffffff;
			cLabel.borderColor = 0x000000;
			cLabel.border = true;
			var clabelFormat:TextFormat = cLabel.defaultTextFormat;
			cLabel.defaultTextFormat = clabelFormat;
			cLabel.filters  = [new DropShadowFilter(5,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false)];
			cLabel.visible = false;
			cLabel.x = 15;
			coloryardstickSprite.addChild(cLabel);
			coloryardstickSprite.height = 60;
			//圆的大小
			
			//大小 label
			radiusLabel = Utility.getInstance().getTextField(0,0,12,ThemeHander.style["label_color"],"left");
			radiusLabel.selectable = false;
			radiusLabel.text = "大小";
			propertyVBox.addChild(radiusLabel);
			
			radiusCombox = new HorizontalAxisComboBox();
			radiusCombox.width = ThemeHander.style["attributepanel_width"];
			radiusCombox.height = 25;
			radiusCombox.openPosition = "left";
			radiusCombox.addEventListener(Event.SELECT, onRadiusSelect);
			propertyVBox.addChild(radiusCombox);
			
			var radiusyardstickSprite:Sprite = new Sprite();//标尺
			propertyVBox.addChild(radiusyardstickSprite);
			//大小标尺
			radiusyardstickSprite.graphics.lineStyle(1,ThemeHander.style["label_color"]);
			radiusyardstickSprite.graphics.moveTo(0,16);
			radiusyardstickSprite.graphics.curveTo(16,0,38,16);
			
			radiusyardstickSprite.addChild(radiusyardstick);
			
			rTotalLabel = Utility.getInstance().getTextField(0,
				0,14,0x000000,"left");
			rTotalLabel.x = 38;
			radiusyardstickSprite.addChild(rTotalLabel);
			
			rLabel = Utility.getInstance().getTextField(0,
				0,14,0x000000,"left")
			rLabel.background = true;
			rLabel.backgroundColor = 0xffffff;
			rLabel.borderColor = 0x000000;
			rLabel.border = true;
			var rlabelFormat:TextFormat = rLabel.defaultTextFormat;
			rLabel.defaultTextFormat = rlabelFormat;
			rLabel.filters  = [new DropShadowFilter(5,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false)];
			rLabel.visible = false;
			rLabel.x = 78;
			radiusyardstickSprite.addChild(rLabel);
			
			
			//标尺
			propertyVBox.addChild(zoom_SelectSprite);
			//缩放
			zoomLabel = Utility.getInstance().getTextField(0,0,12,ThemeHander.style["label_color"],"left");
			zoomLabel.text = "Zoom";
			zoomLabel.visible = false;
			//取消缩放
			zoomOutLabel = Utility.getInstance().getTextField(60,
				20,12,0x000000,"left");
			var zoomFormat:TextFormat = zoomOutLabel.defaultTextFormat;
			zoomFormat.underline = true;
			zoomOutLabel.defaultTextFormat = zoomFormat;
			zoomOutLabel.text = "Zoom out";
			zoomOutLabel.addEventListener(MouseEvent.CLICK,zoomOutHander);
			zoomOutLabel.x = ThemeHander.style["attributepanel_width"] - zoomOutLabel.width;
			zoomOutLabel.visible = false;
			
			zoom_SelectSprite.addChild(zoomLabel);
			zoom_SelectSprite.addChild(zoomOutLabel);
			
			//显示选择节点面板
			selectLabel = Utility.getInstance().getTextField(0,0,12,ThemeHander.style["label_color"],"left");
			selectLabel.text = "Select";
			selectLabel.visible = true;
			
			disSelectLabel = Utility.getInstance().getTextField(60,
				20,12,0x000000,"left");
			var disSelectFormat:TextFormat = disSelectLabel.defaultTextFormat;
			disSelectFormat.underline = true;
			disSelectLabel.defaultTextFormat = disSelectFormat;
			disSelectLabel.text = "Deselect all";
			disSelectLabel.addEventListener(MouseEvent.CLICK,nodeSelectHander);
			disSelectLabel.x = ThemeHander.style["attributepanel_width"] - disSelectLabel.width;
			disSelectLabel.visible = true;
			
			zoom_SelectSprite.addChild(selectLabel);
			zoom_SelectSprite.addChild(disSelectLabel);
			
			nodeSelectVBox.border = false;
			nodeSelectVBox.miniWidth = ThemeHander.style["attributepanel_width"];
			nodeSelectVBox.spacing = 0;
			nodeSelectScrollPanel.source = nodeSelectVBox;
			nodeSelectScrollPanel.horizontalScrollPolicy = "off";
			nodeSelectScrollPanel.width = ThemeHander.style["attributepanel_width"];
			nodeSelectScrollPanel.height = 100;
			nodeSelectScrollPanel.y = 20;
			
			zoom_SelectSprite.addChild(nodeSelectScrollPanel);
			
			//是否显示轨迹
			trails = new CheckBox();
			trails.label = "轨迹";
			
			trails.addEventListener(MouseEvent.CLICK,onTrails);
			propertyVBox.addChild(trails);
			//滑动块
			hSlider.x = ThemeHander.style["pointHSlider_x"];
			hSlider.y = _height-ThemeHander.style["pointHSlider_bottom"]-30;
			this.addChild(hSlider);
			
			
			_utility.addEventListener(LEvent.ZOOMMINIMAPON,zoomMiniMapOn);//小地图打开
			_utility.addEventListener(LEvent.ZOOMMINIMAPOFF,zoomMiniMapOff);//关闭小地图
			
			
			//节点选择
			this._utility.addEventListener(LEvent.BUBBLELABELMOVEOUT,bubbleLabelMoveOut);
			this._utility.addEventListener(LEvent.BUBBLELABELMOVEIN,bubbleLabelMoveIn);
			
			//数据测试
			//receiveData(data);
			ExternalInterface.addCallback("receiveData",receiveData);
			ExternalInterface.call("setdata");
			
			//初始化时监听浏览器大小
			var size:Object = ExternalInterface.call("getSize");
			this._width = size.width;
			this._height = size.height;
			resizeForParent();
		}
		
		private function getColorRuler():Sprite{
			var colorRuler:Sprite = new Sprite(); 
			colorRuler.graphics.clear();
			var matix:Matrix =new Matrix()//矩阵
			matix.createGradientBox(15 , 60 , Math.atan2(60 , 0));
			colorRuler.graphics .beginGradientFill(GradientType.LINEAR,[0xff0000,0x0000ff],[1,1],[0,255],matix);
			colorRuler.graphics.drawRect(0,0,15,60);
			colorRuler.graphics.endFill();
			return colorRuler;
		}
		
		/**
		 * 接收数据
		 * 重置属性选择列表
		 * 重画数据图表
		 */
		public function receiveData(_data:Object):void{
			try{
				this.data = _data;
				//数据处理
				var stringAttribute:Array = [];//字符类型
				var numberAttribute:Array = [];//数字类型
				var dateAttribute:Array = [];//时间类型
				var enumAttribuye:Array = [];//枚举类型
				var maximums:Object = new Object();//最大值列表
				var minimums:Object = new Object();//最小值列表
				var percents:Array = [];//百分比
				
				var columns:Array = data.columns;//表头
	
				var columnsindexs:Object = new Object();//列的位置
				var types:Object = new Object();//列的类型
				
				for(var i:int = 0;i<columns.length;i++){
					var _type:Object = columns[i][0];
					if(_type == "string"){
						stringAttribute.push(columns[i][1]);
					}else if(_type == "number"){
						numberAttribute.push(columns[i][1]);
						maximums[columns[i][1]] = getMaximun(i);//最大值
						minimums[columns[i][1]] = getMinimun(i);//最小值
					}else if(_type == "percent"){
						maximums[columns[i][1]] = getMaximun(i);//最大值
						minimums[columns[i][1]] = getMinimun(i);//最小值
						percents.push(columns[i][1]);
					}else if(_type == "date"){
						dateAttribute.push(columns[i][1]);
						transitionDate(i);
						maximums[columns[i][1]] = getMaximunDate(i);//最大值
						minimums[columns[i][1]] = getMinimunDate(i);//最小值
					}else if(_type == "enum"){
						enumAttribuye.push(columns[i][1]);
					}
					columnsindexs[columns[i][1]] = i;
					types[columns[i][1]] = _type;
				}
				// TODO 对时间进行排序在轨迹的时候会用到
				
				
				data.stringAttribute = stringAttribute;
				data.numberAttribute = numberAttribute;
				data.dateAttribute = dateAttribute;
				data.enumAttribuye = enumAttribuye;
				data.percents = percents;
				data.colorEnums = new Object();
				data.columnsindexs = columnsindexs;
				data.types = types;
				
				data.maximums = maximums;
				data.minimums = minimums;
				//整理rows
				var displayName:String = data.displayName;
				var rowsArray:Array = data.rows;
				
				var rows:Object = new Object();
				for(var j:int = 0;j<rowsArray.length;j++){
					var currentDisplayName:String = rowsArray[j][data.columnsindexs[displayName]];
					if(!rows[currentDisplayName]){
						rows[currentDisplayName] = [];
					}
					rows[currentDisplayName].push(rowsArray[j]);
				}
				data.rows = rows;
				
				
				//按时间排序
				this.sortByDate(data.rows);
				
				//****************数据处理<<<<<<<<<<<<>>>>>>>>>>
				
				leftVerticalAxis._list.items = data.numberAttribute.concat(data.percents);//初始化纵坐标
				leftVerticalAxis.defaultLabel = data.yField;  
				
				horizontalAxis._list.items = data.numberAttribute.concat(data.percents).concat(data.dateAttribute);//初始化横坐标
				horizontalAxis.defaultLabel = data.xField;
				
				radiusCombox._list.items = data.numberAttribute.concat(data.percents);//初始化大小纬度选择
				radiusCombox.defaultLabel = data.radiusField;
				
				colorCombox._list.items = data.numberAttribute.concat(data.enumAttribuye).concat(data.percents);//初始化颜色纬度选择
				colorCombox.defaultLabel = data.colorField;
				
				//初始化大小
				rTotalLabel.text = this._utility.formatNumberToString(data.maximums[data["radiusField"]]);
				
				setColorYardstick();//初始化颜色标尺
				
				//初始化节点选择
				var _rows:Object = data.rows;
				for(var rowID:String in _rows){//每个节点对应的
					var selectItem:LSelectItem = new LSelectItem(rowID);
					selectItem.width = ThemeHander.style["attributepanel_width"];
					selectItem.height = 20;
					nodeSelectVBox.addChild(selectItem);
				}
				trace(nodeSelectVBox.height);
				nodeSelectScrollPanel.source = nodeSelectVBox;
				
				//表格
				bubbleTable.receiveData(data);//画数据表
				
				//滑块  
				hSlider.setDate(data.minimums[data["slidingShaft"]],data.maximums[data["slidingShaft"]]);
			}catch(error:Error){
				trace("error data");
				return;
			}
			
		}
		
		private function setColorYardstick():void{//重置标尺
			topColoryardstick.text = "";
			bottomColoryardstick.text = "";
			if(!data){
				return;
			}
			//枚举
			var colorField:String = data["colorField"];
			if((data.enumAttribuye as Array).indexOf(colorField)>-1){//判断字段是否为枚举类型
				if(data.colorEnums[colorField] == null){
					data.colorEnums[colorField] = [];
					var index:int = data.columnsindexs[colorField];
					
					var rows:Object = data.rows;
					
					for(var rowID:String in rows){//每个节点对应的
						var items:Array = rows[rowID];//每个displayName对应的数据列表
						for(var i:int = 0;i<items.length;i++){
							var value:Object = items[i][index];
							if(!data.colorEnums[colorField][value]){
								var randRGB:uint = this._utility.RandRGB();
								data.colorEnums[colorField][value] = randRGB;
								var enumItem:EnumItem = new EnumItem();
								enumItem.key = value.toString();
								enumItem.value = data.colorEnums[colorField][value];
								data.colorEnums[colorField].push(enumItem);
							}
						}
					}
				}else{
					
				}
				colorEnumlList.items = data.colorEnums[colorField];
				colorEnumScollPanel.source = colorEnumlList;
				
				if(coloryardstickSprite.parent&&coloryardstickSprite.parent == colorPanel){
					colorPanel.removeChild(coloryardstickSprite);
				}
				colorPanel.addChild(colorEnumScollPanel);
				return;
			}
			
			if(colorEnumScollPanel.parent&&colorEnumScollPanel.parent == colorPanel){
				colorPanel.removeChild(colorEnumScollPanel);
			}
			colorPanel.addChild(coloryardstickSprite);
			//数字
			//取增量
			var maximumCField:Number = data.maximums[data["colorField"]];//最大值
			var minumumCField:Number = data.minimums[data["colorField"]];//最小值
			var cincrementalPrefix:Number = _utility.integerNumber([maximumCField,minumumCField]); //倍数
			//设置最大值最小值为整数
			maximumCField *= cincrementalPrefix;
			minumumCField *= cincrementalPrefix;
			//此时最大值最小值均为整数
			var cincremental:int = maximumCField-minumumCField;//增量 最大值减去最小值
			var cseparate:Number = 0.0;//垂直标签间隔数值
			var cdivideNumbers:Array = [];//清空垂直标签数组
			  
			if(cincremental  ==  0){
				topColoryardstick.text = "";
				bottomColoryardstick.text = maximumCField / cincrementalPrefix + "";
				bottomColoryardstick.y = 60*0.5 + colorIconRuler.y - 10;
			}else if(cincremental  == 1){
				topColoryardstick.text = "";
				bottomColoryardstick.text = (maximumCField - cincremental*0.5) / cincrementalPrefix + "";
				bottomColoryardstick.y = 60*0.5 + colorIconRuler.y - 10;
			}else{
				var cincrementalString:String = cincremental.toString();//增量number->字符串
				var cfirstnumber:int = new Number(cincrementalString.charAt(0));//增量的第一个数字  左边第一个不为0的数
				if(cfirstnumber >= 5){//首位数大于5 以5*分割
					cseparate = 5*Math.pow(10 , cincrementalString.length - 1);
					var c5separate:Number = cseparate * (Math.ceil(minumumCField / cseparate));
					while(c5separate <= maximumCField){
						cdivideNumbers.push(c5separate);
						c5separate += cseparate;
					}
				}else if(cfirstnumber == 4){//首位大于等于4 小于5 以2*分割
					cseparate = 2*Math.pow(10,cincrementalString.length-1);
					var c2separate:Number = cseparate*(Math.ceil(minumumCField / cseparate));
					while(c2separate<=maximumCField){
						cdivideNumbers.push(c2separate);
						c2separate+=cseparate;
					}
				}else{//大于1  小于4>>  以1*分割
					cseparate = 1 * Math.pow(10,cincrementalString.length-1);
					var c1separate:Number = cseparate * (Math.ceil(minumumCField / cseparate));
					while(c1separate <= maximumCField){
						cdivideNumbers.push(c1separate);
						c1separate += cseparate;
					}  
				}
			}
			var len:int = cdivideNumbers.length;
			if(len >= 0){
				var topy:Number = ((maximumCField-cdivideNumbers[0])/cincremental) * 60;
				topColoryardstick.text = cdivideNumbers[0]/cincrementalPrefix + "  ";
				topColoryardstick.x = colorIconRuler.x + 15;
				this.topColoryardstick.y = colorIconRuler.y + topy - 10;
				
			}
			if(len >= 2){
				var bottomy:Number = ((maximumCField-cdivideNumbers[len-1]) / cincremental) * 60;
				bottomColoryardstick.text = cdivideNumbers[len-1] / cincrementalPrefix + "  ";
				bottomColoryardstick.x = colorIconRuler.x + 15;
				this.bottomColoryardstick.y = colorIconRuler.y + bottomy - 10;
			}
		}
		
		/**
		 * 添加resize监听
		 * 当父容器大小改变时重画组件
		 */
		public function addResizeListener(parentStage:DisplayObject):void{
			parentStage.addEventListener(flash.events.Event.RESIZE,resizeForParent);
		}
		
		private function resizeForParent(e:Event = null):void{
			//重画后大小
			if(e&&stage){
				_width = stage.stageWidth;
				_height = stage.stageHeight;
			}
			_width = Math.max(_width,430);//最低宽度
			_height = Math.max(_height,260);//最低高度
			
			//重画背景
			this.graphics.clear();
			this.graphics.beginFill(ThemeHander.style["app_bg"],ThemeHander.style["app_alpha"]);
			this.graphics.drawRect(0,0,_width,_height);
			this.graphics.endFill();
			
			//重置组件位置
			leftVerticalAxis.y = _height-ThemeHander.style["leftvComboBox_bottom"];//纵坐标 底部留白horizontalAxis高度+horizontalAxis底部留白+10
			
			horizontalAxis.x = ThemeHander.style["hComboBox_x"];//横坐标
			horizontalAxis.y = _height-ThemeHander.style["hComboBox_bottom"]-ThemeHander.style["hComboBox_height"];
			horizontalAxis.width = _width-ThemeHander.style["hComboBox_right"]-ThemeHander.style["hComboBox_x"];
			
			bubbleTable.doResize(_width,_height);//表格
			
			propertyVBox.x = this._width-ThemeHander.style["attributepanel_right"]-ThemeHander.style["attributepanel_width"];
			propertyVBox.y = 20;
			
			//滑动块
			hSlider.y = _height-ThemeHander.style["pointHSlider_bottom"];
			hSlider.doResize(_width-ThemeHander.style["pointHSlider_right"]-ThemeHander.style["pointHSlider_x"],30);
		}
		
		//*********************>>>>>>>>>>>>>>>备份
		//转化时间
		private function transitionDate(index:int):void{
			var date:Date = new Date(0.0);
			var items:Array = data.rows;//每个displayName对应的数据列表
			for(var i:int = 0;i<items.length;i++){
				var _date:Date = this._utility.timeStrToDate(items[i][index]);;
				items[i][index] = _date;
			}
		}
		//按时间进行排序
		private function sortByDate(datesort_rows:Object):void{
			for(var datesort_rowID:String in datesort_rows){//每个节点对应的
				datesort_rows[datesort_rowID] = InsertSort(datesort_rows[datesort_rowID],data.columnsindexs[data["slidingShaft"]]);
			}
		}
		
		// 对2维数组进行插入排序
		private function InsertSort(array:Array, point:int):Array
		{
			var current:Date;
			var newArray:Array = [];
			
			　　　 for (var i:int  =  0; i < array.length; i++)
			　　　 {
				　　　　current  =  array[i][point] as Date;
				if(newArray.length == 0){
					newArray.push(array[i]);
					continue;
				}
				var seted:Boolean = false;
				for (var j:int  =  0; j < newArray.length; j++){
					//如果小于第i个值
					if(current.getTime()<(newArray[j][point] as Date).getTime()){
						for (var k:int =  newArray.length-1; k  >= j; k--){
							newArray[k+1] = newArray[k];//将i后面的全部向后推一位
						}
						newArray[j] = array[i];
						seted = true;
						break;
					}
					
				}
				if(!seted){
					newArray.push(array[i]);
				}
			　　　 }
			return newArray;
		}
		
		
		
		private function getMaximunDate(index:int):Date{//获取某一时间纬度的最大值
			var date:Date = new Date(0.0);
			var items:Array = data.rows;//每个displayName对应的数据列表
			for(var i:int = 0;i<items.length;i++){
				var _date:Date = items[i][index];
				if(i == 0){
					date = _date;
				}
				if(_date.getTime()>date.getTime()){
					date = _date;
				}
			}
			return date;
		}
		
		private function getMinimunDate(index:int):Date{//获取某一时间纬度的最小值
			var date:Date = new Date(0.0);
			var items:Array = data.rows;//每个displayName对应的数据列表
			for(var i:int = 0;i<items.length;i++){
				var _date:Date = items[i][index];
				if(i == 0){
					date = _date;
				}
				if(_date.getTime()<date.getTime()){
					date = _date;
				}
			}
			return date;
		}
		
		private function getMaximun(index:int):Number{//获取某一数字纬度的最大值
			var max:Number = 0.0;
			var items:Array = data.rows;//每个displayName对应的数据列表
			for(var i:int = 0;i<items.length;i++){
				var _max:Number = items[i][index];
				if(i == 0){
					max = _max;
				}
				if(_max>max){
					max = _max;
				}
			}
			return max;
		}
		
		private function getMinimun(index:int):Number{//获取某一数字纬度的最小值
			var min:Number = 0.0;
			var items:Array = data.rows;//每个displayName对应的数据列表
			for(var i:int = 0;i<items.length;i++){
				var _min:Number = items[i][index];
				if(i == 0){
					min = _min;
				}
				if(_min<min){
					min = _min;
				}
			}
			return min;
		}
		
		//*************************事件
		protected function onLeftVerticalAxisSelect(event:Event):void
		{
			var vSelectItem:Object = leftVerticalAxis._list.selectedItem;
			if(vSelectItem)
				_utility.dispatchEvent(new LEvent(LEvent.LEFTVERTICALAXISSELECT,vSelectItem));
		}
		
		protected function onHorizontalAxisSelect(event:Event):void
		{
			var hSelectItem:Object = horizontalAxis._list.selectedItem;
			if(hSelectItem)
				_utility.dispatchEvent(new LEvent(LEvent.HORIZONTALAXISSELECT,hSelectItem));
		}
		
		private function onRadiusSelect(event:Event):void{
			var rSelectItem:Object = radiusCombox._list.selectedItem;
			if(rSelectItem)
				var maximumRField:Number = data.maximums[data["radiusField"]];//最大值
			rTotalLabel.text = this._utility.formatNumberToString(maximumRField);
			_utility.dispatchEvent(new LEvent(LEvent.RADIUSSELECT,rSelectItem));
		}
		
		private function onColorSelect(event:Event):void{
			var cSelectItem:Object = colorCombox._list.selectedItem;
			if(cSelectItem){
				data["colorField"] = cSelectItem;
				this.setColorYardstick();//标尺
				_utility.dispatchEvent(new LEvent(LEvent.COLORSELECT,cSelectItem));
			}
		}
		
		private function zoomMiniMapOn(event:LEvent):void{
			trace("zoomMiniMapOn");
			var zoomMiniMap:Sprite = event.stanza as Sprite;
			zoomMiniMap.y = 20;
			if(this.nodeSelectScrollPanel.parent&&nodeSelectScrollPanel.parent  == zoom_SelectSprite){
				zoom_SelectSprite.removeChild(nodeSelectScrollPanel);
				selectLabel.visible=false;
				disSelectLabel.visible=false;
				
				zoom_SelectSprite.addChild(zoomMiniMap);
				zoomLabel.visible = true;
				zoomOutLabel.visible = true;
			}
			zoom_SelectSprite.graphics.clear();
			zoom_SelectSprite.graphics.drawRect(0,0,0,20+ThemeHander.style["zoomMinimap_height"]);
			propertyVBox.update();
		}
		
		private function zoomMiniMapOff(event:LEvent):void{
			trace("zoomMiniMapOff");
			var zoomMiniMap:Sprite = event.stanza as Sprite;
			if(zoomMiniMap.parent&&zoomMiniMap.parent == this.zoom_SelectSprite){
				zoom_SelectSprite.removeChild(zoomMiniMap);
				zoomLabel.visible = false;
				zoomOutLabel.visible = false;
				
				zoom_SelectSprite.addChild(nodeSelectScrollPanel);
				selectLabel.visible = true;
				disSelectLabel.visible = true;
				
			}
			zoom_SelectSprite.graphics.clear();
			propertyVBox.update();
		}
		
		private function zoomOutHander(event:MouseEvent):void{
			this._utility.dispatchEvent(new LEvent(LEvent.ZOOMOUT,""));
		}
		
		//开始轨迹
		private function onTrails(event:MouseEvent):void{
			this._utility.dispatchEvent(new LEvent(LEvent.TRAILS,this.trails.selected));
		}    
		
		//label
		//选中节点
		private function nodeSelectHander(event:MouseEvent):void{
			for(var i:int = 0;i < nodeSelectVBox.numChildren;i++){
				this._utility.dispatchEvent(new LEvent(LEvent.NODESELECT + Object(nodeSelectVBox.getChildAt(i)).nodeID , false));
			}
		}
		
		private function bubbleLabelMoveOut(event:LEvent):void{
			radiusyardstick.graphics.clear();
			this.cLabel.visible = false;
			this.rLabel.visible = false;
		}
		
		private function bubbleLabelMoveIn(event:LEvent):void{
			var bubbleNode:LBubbleNode = event.stanza as LBubbleNode; 
			cLabel.text = this._utility.formatNumberToString(bubbleNode.colorField);
			rLabel.text = this._utility.formatNumberToString(bubbleNode.radiusField);
			//取增量
			var maximumCField:Number = data.maximums[data["colorField"]];//最大值
			var minumumCField:Number = data.minimums[data["colorField"]];//最小值
			var maximumRField:Number = data.maximums[data["radiusField"]];//最大值
			var minumumRField:Number = data.minimums[data["radiusField"]];//最小值
			
			cLabel.y = (1-(bubbleNode.colorField-minumumCField)/(maximumCField-minumumCField))*60-cLabel.height*0.5;
			
			var rpeasent:Number = (bubbleNode.radiusField-minumumRField)/(maximumRField-minumumRField);
			radiusyardstick.graphics.clear();
			radiusyardstick.graphics.lineStyle(1,0x000000);
			radiusyardstick.graphics.moveTo(0,16);
			radiusyardstick.graphics.curveTo(16*rpeasent,16*(1-rpeasent),38*rpeasent,16);
			
			this.rLabel.visible = true;
			this.cLabel.visible = true;
			rTotalLabel.text = this._utility.formatNumberToString(maximumRField);
		}
	}
}