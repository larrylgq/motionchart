package UI.bubblechart
{
	import UI.base.BubbleNodePool;
	
	import events.LEvent;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import larry.components.list.EnumItem;
	import larry.components.list.LList;
	
	import utils.ThemeHander;
	import utils.Utility;
	
	public class LBubbleTable extends Sprite
	{
		private var borderShape:Sprite=new Sprite();//边框
		private var gridShape:Shape=new Shape();//网格
		private var leftVerticalAxisShape:Sprite=new Sprite();//纵坐标
		private var horizontalAxisShape:Sprite=new Sprite();//横坐标
		
		private var reportShape:Sprite=new Sprite();//数据
		private var masksShape:Shape=new Shape();//遮罩层遮罩数据点
		
		private var zoomShape:Shape=new Shape();//放大缩小控制
		private var zoomList:LList;//放大缩小选择
		
		private var zoomMinimap:Sprite=new Sprite();//小地图
		private var miniMapSelecter:Sprite=new Sprite(); 
		
		private var data:Object;//数据
		
		private var border_width:Number=1.0;//边框宽度
		private var border_height:Number=1.0;//边框高度
		
		//for zoom
		private var currentMaxXField:Number;//横坐标最大值
		private var currentMinXField:Number;//横坐标最小值
		private var currentMaxYField:Number;//纵坐标最大值
		private var currentMinYField:Number;//纵坐标最小值
		
		private var zoomMaxXInc:Number;//横坐标最大值
		private var zoomMinXInc:Number;//横坐标最小值
		private var zoomMaxYInc:Number;//纵坐标最大值
		private var zoomMinYInc:Number;//纵坐标最小值
		
		private var isZoomed:Boolean=false;
		
		private var miniMap_minX:Number=0;
		private var miniMap_maxX:Number=0;
		private var miniMap_minY:Number=0;
		private var miniMap_maxY:Number=0;
		
		//end
		
		private var hLabel:TextField;
		private var vLabel:TextField;
		
		private var _utility:Utility=Utility.getInstance();//公共属性类
		private var _themeHander:ThemeHander=ThemeHander.getInstance();//主题
		
		public var currentDate:Date;//滑动轴当前点
		
		private var zoomInTimer:Timer=new Timer(30);
		private var zoomOutTimer:Timer=new Timer(30);
		private var zoomSelecterTimer:Timer=new Timer(30);
		public function LBubbleTable()
		{
			super();
			borderShape.x=ThemeHander.style["leftvertical_width"];   
			this.addChild(borderShape);//添加边框
			
			gridShape.x=ThemeHander.style["bubblenode_maxradius"]*0.5;
			gridShape.y=ThemeHander.style["bubblenode_maxradius"]*0.5;
			borderShape.addChild(gridShape);//添加网格
			
			reportShape.x=ThemeHander.style["bubblenode_maxradius"]*0.5;
			reportShape.y=ThemeHander.style["bubblenode_maxradius"]*0.5;
			borderShape.addChild(reportShape);//添加数据
			
			this.addChild(masksShape);//添加遮罩层
			
			leftVerticalAxisShape.x=0;
			this.addChild(leftVerticalAxisShape);//添加左坐标轴
			horizontalAxisShape.y=border_height;
			horizontalAxisShape.x=ThemeHander.style["leftvertical_width"];
			this.addChild(horizontalAxisShape);//添加横坐标
			//选择区域
			this.borderShape.addChild(zoomShape);
			zoomList=new LList();
			zoomList.items=["Zoom in","Cancel"];
			zoomList.visible=false;
			zoomList.miniWidth=100;
			zoomList.miniHeight=40;
			this.addChild(zoomList);
			zoomMinimap.addChild(miniMapSelecter);//小地图选择
			//label
			vLabel=Utility.getInstance().getTextField(0,
				0,14,0x000000,"right")
			vLabel.background=true;
			vLabel.backgroundColor=0xffffff;
			vLabel.borderColor=0x000000;
			vLabel.border=true;
			var vlabelFormat:TextFormat=vLabel.defaultTextFormat;
			vLabel.defaultTextFormat=vlabelFormat;
			vLabel.filters =[new DropShadowFilter(5,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false)];
			vLabel.visible=false;
			
			hLabel=Utility.getInstance().getTextField(0,
				0,14,0x000000,"center")
			hLabel.background=true;
			hLabel.backgroundColor=0xffffff;
			hLabel.borderColor=0x000000;
			hLabel.border=true;
			var hlabelFormat:TextFormat=hLabel.defaultTextFormat;
			hLabel.defaultTextFormat=hlabelFormat;
			hLabel.filters =[new DropShadowFilter(5,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false)];
			hLabel.visible=false;
			
			this.addChild(vLabel);
			this.addChild(hLabel);
			
			//事件添加  纬度改变
			_utility.addEventListener(LEvent.LEFTVERTICALAXISSELECT,leftVerticalAxisChange);//纵坐标
			_utility.addEventListener(LEvent.HORIZONTALAXISSELECT,horizontalAxisChange);//纵坐标
			_utility.addEventListener(LEvent.RADIUSSELECT,radiusChange);//大小
			_utility.addEventListener(LEvent.COLORSELECT,colorChange);//颜色
			this._utility.addEventListener(LEvent.POINTHSLIDERSELECT,pointHSliderSelect);//滑动点选择
			this._utility.addEventListener(LEvent.POINTHSLIDERMOVETO,pointHSliderMoveto);//滑动点选择
			
			borderShape.addEventListener(MouseEvent.MOUSE_DOWN,zoomShapeMouseDown);//放大缩小点击
			
			zoomInTimer.addEventListener(TimerEvent.TIMER,zoomInTimerHander);
			zoomOutTimer.addEventListener(TimerEvent.TIMER,zoomOutTimerHander);
			
			zoomSelecterTimer.addEventListener(TimerEvent.TIMER,zoomSelecterTimerHander);
			
			zoomList.addEventListener(Event.SELECT,zoomListSelect);
			
			zoomMinimap.addEventListener(MouseEvent.MOUSE_DOWN,zoomMinimapMouseDown);
			
			this._utility.addEventListener(LEvent.ZOOMOUT,zoomOutHander);
			
			//节点选择
			this._utility.addEventListener(LEvent.BUBBLELABELMOVEOUT,bubbleLabelMoveOut);
			this._utility.addEventListener(LEvent.BUBBLELABELMOVEIN,bubbleLabelMoveIn);
			
			
		}
		
		/**
		 * ************************
		 * 事件
		 */
		//纵坐标修改
		private function leftVerticalAxisChange(event:LEvent):void{
			trace("leftVerticalAxisChange");
			data["yField"]=event.stanza;
			this.currentMaxYField=data.maximums[data["yField"]];//备份纵坐标最大值数组
			this.currentMinYField=data.minimums[data["yField"]];//备份纵坐标最小值数组
			updateGrid();
			
			this.updateReport(true);
			
			if(this.currentMaxXField==data.maximums[data["xField"]]&&
				this.currentMinXField==data.minimums[data["xField"]]){
				this.isZoomed=false;
				this._utility.dispatchEvent(new LEvent(LEvent.ZOOMOUT,zoomMinimap));
			}
		}
		
		//横坐标修改
		private function horizontalAxisChange(event:LEvent):void{
			trace("horizontalAxisChange");
			data["xField"]=event.stanza;
			this.currentMaxXField=data.maximums[data["xField"]];//备份横坐标最大值数组
			this.currentMinXField=data.minimums[data["xField"]];//备份横坐标最小值数组
			updateGrid();
			
			this.updateReport(true);
			
			if(this.currentMaxYField == data.maximums[data["yField"]]&&
				this.currentMinYField == data.minimums[data["yField"]]){
				this.isZoomed=false;
				this._utility.dispatchEvent(new LEvent(LEvent.ZOOMOUT,zoomMinimap));
			}
		}
		
		//大小改变
		private function radiusChange(event:LEvent):void{
			trace("radiusChange");
			data["radiusField"]=event.stanza;
			
			this.updateReport(true);
		}
		
		//颜色改变
		private function colorChange(event:LEvent):void{
			trace("colorChange");
			data["colorField"]=event.stanza;
			
			this.updateReport(true);
		}
		//滑动点点选 
		private function pointHSliderSelect(event:LEvent):void{
			trace("pointHSliderSelect");
			this.currentDate=event.stanza as Date;
			this.updateReport(true);
		}
		//滑动点移动
		private function pointHSliderMoveto(event:LEvent):void{
			//trace("pointHSliderMoveto");
			this.currentDate=event.stanza as Date;
			this.updateReport();
		}  
		
		//放大缩小面板点击
		private var startZoomPoint:Point=new Point();
		private function zoomShapeMouseDown(event:MouseEvent):void{
			zoomShape.graphics.clear();//清除框和list
			this.zoomList.visible=false;
			
			this.startZoomPoint.x=borderShape.mouseX;//保存点
			this.startZoomPoint.y=borderShape.mouseY;
			
			borderShape.addEventListener(MouseEvent.MOUSE_MOVE,zoomShapeMouseMove);//选择区域事件
			borderShape.addEventListener(MouseEvent.MOUSE_UP,zoomShapeMouseUp);//放大缩小弹起
		}
		
		//放大缩小面板拖动
		private function zoomShapeMouseMove(event:MouseEvent):void{
			if(event.buttonDown){
				var endZoomX:Number=borderShape.mouseX;//结束点
				var endZoomY:Number=borderShape.mouseY;
				
				var startZoomX:Number=startZoomPoint.x;//起始点
				var startZoomY:Number=startZoomPoint.y;
				
				endZoomX=endZoomX<startZoomX?startZoomX:endZoomX;//调整结束点必须大于起始点
				endZoomY=endZoomY<startZoomY?startZoomY:endZoomY;
				
				zoomShape.graphics.clear();//画区域选择框
				zoomShape.graphics.lineStyle(1,0x000000,1);
				zoomShape.x=startZoomX;
				zoomShape.y=startZoomY;
				zoomShape.graphics.drawRect(0,0,endZoomX-startZoomX,endZoomY-startZoomY);
			}
		}
		
		//放大缩小面板缩小
		private var endZoomPoint:Point=new Point();
		private var showZoomOut:Boolean=true;
		private function zoomShapeMouseUp(event:MouseEvent):void{
			var endZoomX:Number=borderShape.mouseX;//结束点
			var endZoomY:Number=borderShape.mouseY;
			var startZoomX:Number=startZoomPoint.x;//起始点
			var startZoomY:Number=startZoomPoint.y;
			
			endZoomPoint.x=endZoomX;//保存结束点
			endZoomPoint.y=endZoomY;
			
			if(endZoomX-startZoomX<20||endZoomY-startZoomY<20){//不满足区域大小限制
				if(this.isZoomed){
					zoomList.items=["Zoom out","Cancel"];
					zoomList.miniHeight=40;
					this.zoomList.x=(this.border_width-endZoomX)>zoomList.width?endZoomX:endZoomX-zoomList.width+40;
					this.zoomList.y=(this.border_height-endZoomY)>zoomList.miniHeight?endZoomY:endZoomY-zoomList.miniHeight;
					this.zoomList.visible=showZoomOut;
					showZoomOut=!showZoomOut;
				}else{
					zoomShape.graphics.clear();
					this.zoomList.visible=false;
				}
			}else{
				if(this.isZoomed){
					zoomList.items=["Zoom in","Zoom out","Cancel"];
					zoomList.miniHeight=60;
				}else{
					zoomList.items=["Zoom in","Cancel"];
					zoomList.miniHeight=40;
				}
				
				this.zoomList.x=(this.border_width-endZoomX)>zoomList.width?endZoomX:endZoomX-zoomList.width+40;
				this.zoomList.y=(this.border_height-endZoomY)>zoomList.miniHeight?endZoomY:endZoomY-zoomList.miniHeight;
				this.zoomList.visible=true;
			}
			borderShape.removeEventListener(MouseEvent.MOUSE_MOVE,zoomShapeMouseMove);//放大缩小拖动移除
			borderShape.removeEventListener(MouseEvent.MOUSE_UP,zoomShapeMouseUp);//放大缩小弹起移除
		}
		
		//zoom out
		private function zoomOutHander(event:LEvent):void{
			trace("zoomout");
			var maxXField:Number=data.maximums[data["xField"]];//备份横坐标最大值数组
			var minXField:Number=data.minimums[data["xField"]];//备份横坐标最小值数组
			var maxYField:Number=data.maximums[data["yField"]];//备份纵坐标最大值数组
			var minYField:Number=data.minimums[data["yField"]];//备份纵坐标最小值数组
			
			zoomMaxXInc=(maxXField-this.currentMaxXField)*0.04;
			zoomMinXInc=-(this.currentMinXField-minXField)*0.04;
			//纵坐标
			zoomMaxYInc=(maxYField-this.currentMaxYField)*0.04;
			zoomMinYInc=-(this.currentMinYField-minYField)*0.04;
			
			zoomOutCount = 0;
			this.zoomOutTimer.start();
		}
		
		//缩放选择
		private function zoomListSelect(event:Event):void{
			if(zoomList.selectedItem=="Zoom in"){
				//横坐标
				var chincremental:Number=currentMaxXField-currentMinXField;
				zoomMaxXInc=-(this.border_width-endZoomPoint.x)/this.border_width*chincremental*0.04;
				zoomMinXInc=this.startZoomPoint.x/this.border_width*chincremental*0.04;
				//纵坐标
				var cvincremental:Number=currentMaxYField-currentMinYField;
				zoomMaxYInc=-this.startZoomPoint.y/this.border_height*cvincremental*0.04;
				zoomMinYInc=(this.border_height-endZoomPoint.y)/this.border_height*cvincremental*0.04;
				
				zoomInCount = 0;
				this.zoomInTimer.start();//打开坐标轴缓动定时器
				zoomSelecterCount = 0;
				this.zoomSelecterTimer.start();//区域选择框zoom定时器
				this._utility.dispatchEvent(new LEvent(LEvent.ZOOMMINIMAPON,zoomMinimap));
				this._utility.dispatchEvent(new LEvent(LEvent.ZOOMIN,zoomMinimap));
				this.isZoomed=true;
				
			}else if(zoomList.selectedItem=="Zoom out"){
				this._utility.dispatchEvent(new LEvent(LEvent.ZOOMOUT,""));
			}else{
				showZoomOut=true;
			}
				this.zoomList.visible=false;
				zoomShape.graphics.clear();
		}
		
		//坐标轴缓动
		private var zoomOutCount:int=0;
		private function zoomOutTimerHander(event:TimerEvent):void{
			zoomOutCount++;
			if(zoomOutCount>24){//设置成25会报错，机器老是死机没法调试，暂时不知道原因
				this.isZoomed=false;
				if(zoomOutTimer.running){
					this.zoomOutTimer.stop();
					
					this.currentMaxYField=data.maximums[data["yField"]];//备份纵坐标最大值数组
					this.currentMinYField=data.minimums[data["yField"]];//备份纵坐标最小值数组
					this.currentMaxXField=data.maximums[data["xField"]];//备份横坐标最大值数组
					this.currentMinXField=data.minimums[data["xField"]];//备份横坐标最小值数组
					this.doUpdate();
					
					this._utility.dispatchEvent(new LEvent(LEvent.ZOOMMINIMAPOFF,zoomMinimap));
				}
			}else{
				this.currentMaxXField+=zoomMaxXInc;
				this.currentMinXField+=zoomMinXInc;
				//纵坐标
				this.currentMaxYField+=zoomMaxYInc;
				this.currentMinYField+=zoomMinYInc;
				this.doUpdate();
			}
		}
		
		private var zoomInCount:int=0;
		private function zoomInTimerHander(event:TimerEvent):void{
			zoomInCount++;
			if(zoomInCount>25){
				showZoomOut=true;
				this.zoomInTimer.stop();
			}else{
				this.currentMaxXField+=zoomMaxXInc;
				this.currentMinXField+=zoomMinXInc;
				//纵坐标
				this.currentMaxYField+=zoomMaxYInc;
				this.currentMinYField+=zoomMinYInc;
				this.doUpdate();
			}
		}
		
		//选择框大小缓动
		private var zoomSelecterCount:int=0;
		private function zoomSelecterTimerHander(event:TimerEvent):void{
			zoomSelecterCount++;
			if(zoomSelecterCount>25){
				zoomShape.graphics.clear();//画区域选择框
				this.zoomSelecterTimer.stop();
			}else{
				var startZoomX:Number=startZoomPoint.x-this.zoomSelecterCount*0.04*startZoomPoint.x;//起始点
				var startZoomY:Number=startZoomPoint.y-this.zoomSelecterCount*0.04*startZoomPoint.y;
				var endZoomX:Number=endZoomPoint.x+(this.border_width-endZoomPoint.x)*this.zoomSelecterCount*0.04;//保存结束点
				var endZoomY:Number=endZoomPoint.y+(this.border_height-this.endZoomPoint.y)*this.zoomSelecterCount*0.04;
				
				zoomShape.graphics.clear();//画区域选择框
				zoomShape.graphics.lineStyle(1,0x000000,1);
				zoomShape.x=startZoomX;
				zoomShape.y=startZoomY;
				zoomShape.graphics.drawRect(0,0,endZoomX-startZoomX,endZoomY-startZoomY);
			}
		}
		
		//小地图选择
		private function zoomMinimapMouseDown(event:MouseEvent):void{
			if(zoomOutTimer.running){
				this.zoomOutTimer.stop();
			}
			
			miniMapSelecter.graphics.clear();
			miniMapSelecter.x=miniMap_minX;//画出选择框
			miniMapSelecter.y=miniMap_minY;
			miniMapSelecter.graphics.clear();
			miniMapSelecter.graphics.lineStyle(1,0x000000);
			var _selectWidth:Number=miniMap_maxX-miniMap_minX;
			var _selectHeight:Number=miniMap_maxY-miniMap_minY;
			miniMapSelecter.graphics.drawRect(0,0,_selectWidth,_selectHeight);
			
			var pointX:Number=zoomMinimap.mouseX;//当前鼠标位置
			var pointY:Number=zoomMinimap.mouseY;
			if(pointX<miniMap_maxX&&pointX>miniMap_minX&&pointY>miniMap_minY&&pointY<miniMap_maxY){
				miniMapSelecter.startDrag(false,
				new Rectangle(0, 0,ThemeHander.style["zoomMinimap_width"]-_selectWidth+1,ThemeHander.style["zoomMinimap_height"]-_selectHeight+1));
			}else{
				miniMapSelecter.x=zoomMinimap.mouseX-_selectWidth*0.5;
				miniMapSelecter.y=zoomMinimap.mouseY-_selectHeight*0.5;
				miniMapSelecter.startDrag(false,
					new Rectangle(0,0,ThemeHander.style["zoomMinimap_width"]-_selectWidth+1,ThemeHander.style["zoomMinimap_height"]-_selectHeight+1));
			}
			
			this._utility.appSprite.addEventListener(MouseEvent.MOUSE_UP,zoomMinimapMouseUp);//放大缩小拖动弹起
		}
		
		//小地图弹起
		private function zoomMinimapMouseUp(event:MouseEvent):void{
			miniMapSelecter.graphics.clear();
			miniMapSelecter.stopDrag();
			var _selectWidth:Number=miniMap_maxX-miniMap_minX;
			var _selectHeight:Number=miniMap_maxY-miniMap_minY;
			//开始点 结束点
			var _startSelectPoint:Point=new Point(miniMapSelecter.x,miniMapSelecter.y);
			var _endSelectPoint:Point=new Point(miniMapSelecter.x+_selectWidth,miniMapSelecter.y+_selectHeight);
			//横坐标
			var chincremental:Number=data.maximums[data["xField"]]-data.minimums[data["xField"]];
			var minXField:Number=data.minimums[data["xField"]];
			
			currentMaxXField=minXField+(_endSelectPoint.x/ThemeHander.style["zoomMinimap_width"])*chincremental;
			currentMinXField=minXField+(_startSelectPoint.x/ThemeHander.style["zoomMinimap_width"])*chincremental;
			//纵坐标
			var cvincremental:Number=data.maximums[data["yField"]]-data.minimums[data["yField"]];
			var maxYField:Number=data.maximums[data["yField"]];
			currentMaxYField=maxYField-(_startSelectPoint.y/ThemeHander.style["zoomMinimap_height"])*cvincremental;
			currentMinYField=maxYField-(_endSelectPoint.y/ThemeHander.style["zoomMinimap_height"])*cvincremental;
			
			this.updateGrid();
			this.updateReport(true);
			this._utility.appSprite.removeEventListener(MouseEvent.MOUSE_UP,zoomMinimapMouseUp);//放大缩小拖动弹起
		}
		
		//选中节点
		private function bubbleLabelMoveOut(event:LEvent):void{
			this.vLabel.visible=false;
			this.hLabel.visible=false;
		}
		
		private function bubbleLabelMoveIn(event:LEvent):void{
			var bubbleNode:LBubbleNode=event.stanza as LBubbleNode; 
			var percents:Array=data.percents;
			var yField:String=data["yField"];
			if(data.types[yField] == "percent"){
				vLabel.text=this._utility.formatNumberToString(bubbleNode.yField*100)+"%";
			}else{
				vLabel.text=this._utility.formatNumberToString(bubbleNode.yField);
			}
			
			var xField:String=data["xField"];
			if(data.types[xField] == "percent"){
				hLabel.text=this._utility.formatNumberToString(bubbleNode.xField*100)+"%";
			}else{
				hLabel.text=this._utility.formatNumberToString(bubbleNode.xField)
			}  
			
			vLabel.x=ThemeHander.style["leftvertical_width"]-vLabel.width;
			vLabel.y=bubbleNode.currentY;
			hLabel.y=this.border_height;
			hLabel.x=bubbleNode.currentX+hLabel.width*0.5;
			this.vLabel.visible=true;
			this.hLabel.visible=true;
		}
		
		/**
		 * 画图表
		 */
		public function doUpdate():void{
			updateBorder();//画边框->无需数据
			updateGrid();//画网格
			updateReport();//画数据
		}
		
		/**
		 * 接收数据
		 */
		public function receiveData(data:Object):void{
			this.data=data;
			this.currentMaxXField=data.maximums[data["xField"]];//备份横坐标最大值数组
			this.currentMinXField=data.minimums[data["xField"]];//备份横坐标最小值数组
			this.currentMaxYField=data.maximums[data["yField"]];//备份纵坐标最大值数组
			this.currentMinYField=data.minimums[data["yField"]];//备份纵坐标最小值数组
		}
		
		//画边框 dotted为是否虚线
		private function updateBorder():void{
			borderShape.graphics.clear();
			borderShape.graphics.lineStyle(ThemeHander.style["table_borderWeight"],ThemeHander.style["table_borderColor"]);
			
			borderShape.graphics.beginFill(0x000000,0);
			borderShape.graphics.drawRect(0,0,border_width,border_height);
			borderShape.graphics.endFill();
		};
		
		//画网格-->需要数据
		private function updateGrid():void{
			gridShape.graphics.clear();
			if(leftVerticalAxisShape&&leftVerticalAxisShape.parent==this){
				this.removeChild(leftVerticalAxisShape);//清空纵坐标所有组件
				leftVerticalAxisShape=null;
			}
			if(horizontalAxisShape&&horizontalAxisShape.parent==this){
				this.removeChild(horizontalAxisShape);//清空横坐标所有组件
				horizontalAxisShape=null;
			}
			
			if(!data){//没有数据返回
				return;
			}
			var percents:Array=data.percents;
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>画纵坐标
			var isVPercent:Boolean=false;
			var yField:String=data["yField"];
			if(percents.indexOf(yField)>-1){
				isVPercent=true;
			}
			//取增量-据当前缩放量
			var maximumYField:Number=currentMaxYField;//最大值
			var minumumYField:Number=currentMinYField;//最小值
			var vincrementalPrefix:Number=_utility.integerNumber([maximumYField,minumumYField]); //倍数
			//设置最大值最小值为整数
			maximumYField*=vincrementalPrefix;
			minumumYField*=vincrementalPrefix;
			//此时最大值最小值均为整数
			var vincremental:Number=maximumYField-minumumYField;//增量 最大值减去最小值
			var vseparate:Number=0.0;//垂直标签间隔数值
			var vdivideNumbers:Array=[];//清空垂直标签数组
			
			if(vincremental==0){
				//画纵坐标
				leftVerticalAxisShape=new Sprite();
				this.addChild(leftVerticalAxisShape);//添加左坐标轴
				//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
				var vdivideTextField0:TextField=Utility.getInstance().getTextField(ThemeHander.style["leftvertical_width"],
					20,12,ThemeHander.style["axis_color"],"right");
				vdivideTextField0.selectable=false;
				vdivideTextField0.y=this.border_height*0.5-10;
				if(isVPercent){
					vdivideTextField0.text=this._utility.formatNumberToString(maximumYField/vincrementalPrefix*100)+"%";
				}else{
					vdivideTextField0.text=this._utility.formatNumberToString(maximumYField/vincrementalPrefix);
				}
				leftVerticalAxisShape.addChild(vdivideTextField0);
			}else if(vincremental==1){
				//画纵坐标
				leftVerticalAxisShape=new Sprite();
				this.addChild(leftVerticalAxisShape);//添加左坐标轴
				
				gridShape.graphics.lineStyle(1,ThemeHander.style["table_gridColor"],0.8);//画横网格
				gridShape.graphics.moveTo(-ThemeHander.style["bubblenode_maxradius"]*0.5, this.border_height*0.5);
				gridShape.graphics.lineTo(border_width, this.border_height*0.5);

				//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
				var vdivideTextField1:TextField=Utility.getInstance().getTextField(ThemeHander.style["leftvertical_width"],
					20,12,ThemeHander.style["axis_color"],"right");
				vdivideTextField1.selectable=false;
				vdivideTextField1.y=this.border_height*0.5-10;
				if(isVPercent){
					vdivideTextField1.text=this._utility.formatNumberToString((maximumYField-vincremental*0.5)/vincrementalPrefix*100)+"%";
				}else{
					vdivideTextField1.text=this._utility.formatNumberToString((maximumYField-vincremental*0.5)/vincrementalPrefix);
				}
				leftVerticalAxisShape.addChild(vdivideTextField1);
			}else{
				var vincrementalString:String=vincremental.toString();//增量number->字符串
				var vfirstnumber:int=new Number(vincrementalString.charAt(0));//增量的第一个数字  左边第一个不为0的数
				if(vfirstnumber>=5){//首位数大于5 以5*分割
					vseparate=5*Math.pow(10,vincrementalString.length-1);
					var v5separate:Number=vseparate*(Math.ceil(minumumYField/vseparate));
					while(v5separate<=maximumYField){
						vdivideNumbers.push(v5separate);
						v5separate+=vseparate;
					}
				}else if(vfirstnumber==4){//首位大于等于4 小于5 以2*分割
					vseparate=2*Math.pow(10,vincrementalString.length-1);
					var v2separate:Number=vseparate*(Math.ceil(minumumYField/vseparate));
					while(v2separate<=maximumYField){
						vdivideNumbers.push(v2separate);
						v2separate+=vseparate;
					}
				}else{//大于1  小于4>>  以1*分割
					vseparate=1*Math.pow(10,vincrementalString.length-1);
					var v1separate:Number=vseparate*(Math.ceil(minumumYField/vseparate));
					while(v1separate<=maximumYField){
						vdivideNumbers.push(v1separate);
						v1separate+=vseparate;
					}  
				}
			
				//画纵坐标
				leftVerticalAxisShape=new Sprite();
				this.addChild(leftVerticalAxisShape);//添加左坐标轴
				for(var j:int=0;j<vdivideNumbers.length;j++){
					var vdivideNumber:Number=vdivideNumbers[j];
					
					gridShape.graphics.lineStyle(1,ThemeHander.style["table_gridColor"],0.8);//画横网格
					var vy:Number=((maximumYField-vdivideNumber)/vincremental)*(this.border_height-ThemeHander.style["bubblenode_maxradius"]);
					gridShape.graphics.moveTo(0-ThemeHander.style["bubblenode_maxradius"]*0.5, vy);
					gridShape.graphics.lineTo(border_width, vy);
					
					//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
					var vdivideTextField:TextField=Utility.getInstance().getTextField(ThemeHander.style["leftvertical_width"],
						20,12,ThemeHander.style["axis_color"],"right");
					vdivideTextField.selectable=false;
					vdivideTextField.y=vy;
					
					
					if(isVPercent){
						vdivideTextField.text=this._utility.formatNumberToString(vdivideNumber/vincrementalPrefix*100)+"%";
					}else{
						vdivideTextField.text=this._utility.formatNumberToString(vdivideNumber/vincrementalPrefix);
					}
					leftVerticalAxisShape.addChild(vdivideTextField);
				}
			}
			
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>画横坐标
			//画横坐标
			horizontalAxisShape=new Sprite();
			horizontalAxisShape.x=ThemeHander.style["leftvertical_width"];
			horizontalAxisShape.y=border_height+5;
			this.addChild(horizontalAxisShape);//添加横坐标
			
			var xField:Object = data["xField"];
			if(data.types[xField] == "date"){//判断字段是否为时间类型
				//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
				var dateTextField:TextField=Utility.getInstance().getTextField(40,
					20,12,ThemeHander.style["axis_color"],"center");
				dateTextField.selectable=false;
				dateTextField.x=this.border_width*0.5;
				
				var mindate:Date=new Date();
				var maxdate:Date = new Date();
				mindate.setTime(this.currentMinXField);
				maxdate.setTime(this.currentMaxXField);
				dateTextField.text = mindate.toDateString()+"-"+maxdate.toDateString();
				horizontalAxisShape.addChild(dateTextField);
			}else{
				var isHPercent:Boolean=false;
				if(data.types[xField] == "percent"){
					isHPercent=true;
				}
				//取增量
				var maximumXField:Number=this.currentMaxXField;//最大值
				var minumumXField:Number=this.currentMinXField;//最小值
				var hincrementalPrefix:Number=_utility.integerNumber([maximumXField,minumumXField]); //倍数
				//设置最大值最小值为整数
				maximumXField*=hincrementalPrefix;
				minumumXField*=hincrementalPrefix;
				//**此时最大值最小值均为整数**
				var hincremental:Number=maximumXField-minumumXField;//增量 最大值减去最小值
				var hseparate:Number=0.0;//垂直标签间隔数值
				var hdivideNumbers:Array=[];//清空垂直标签数组
				if(hincremental==0){
					//画横坐标
					horizontalAxisShape=new Sprite();
					horizontalAxisShape.x=ThemeHander.style["leftvertical_width"];
					horizontalAxisShape.y=border_height+5;
					this.addChild(horizontalAxisShape);//添加横坐标
					
					//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
					var hdivideTextField0:TextField=Utility.getInstance().getTextField(40,
						20,12,ThemeHander.style["axis_color"],"center");
					hdivideTextField0.selectable=false;
					hdivideTextField0.x=this.border_width*0.5;
					
					if(isHPercent){
						hdivideTextField0.text=this._utility.formatNumberToString(minumumXField/hincrementalPrefix*100)+"%";
					}else{
						hdivideTextField0.text=this._utility.formatNumberToString(minumumXField/hincrementalPrefix);
					}
					horizontalAxisShape.addChild(hdivideTextField0);
				}else if(hincremental==1){
					//画横坐标
					horizontalAxisShape=new Sprite();
					horizontalAxisShape.x=ThemeHander.style["leftvertical_width"];
					horizontalAxisShape.y=border_height+5;
					this.addChild(horizontalAxisShape);//添加横坐标
					
					gridShape.graphics.lineStyle(1,ThemeHander.style["table_gridColor"],0.8);//画横网格
					gridShape.graphics.moveTo(this.border_width*0.5, 0-ThemeHander.style["bubblenode_maxradius"]*0.5);
					gridShape.graphics.lineTo(this.border_width*0.5, this.border_height);
					
					//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
					var hdivideTextField1:TextField=Utility.getInstance().getTextField(40,
						20,12,ThemeHander.style["axis_color"],"center");
					hdivideTextField1.selectable=false;
					hdivideTextField1.x=this.border_width*0.5;
					
					if(isHPercent){
						hdivideTextField1.text=this._utility.formatNumberToString((maximumXField-hincremental*0.5)/hincrementalPrefix*100)+"%";
					}else{
						hdivideTextField1.text=this._utility.formatNumberToString((maximumXField-hincremental*0.5)/hincrementalPrefix);
					}
					horizontalAxisShape.addChild(hdivideTextField1);
				}else{
					var hincrementalString:String=hincremental.toString();//增量number->字符串
					var hfirstnumber:int=new Number(hincrementalString.charAt(0));//增量的第一个数字  左边第一个不为0的数
					if(hfirstnumber>=8){//首位数大于8 以2*分割
						hseparate=2*Math.pow(10,hincrementalString.length-1);
						var h2separate:Number=hseparate*(Math.ceil(minumumXField/hseparate));
						while(h2separate<=maximumXField){
							hdivideNumbers.push(h2separate);
							h2separate+=hseparate;
						}
					}else if(hfirstnumber>4&&hfirstnumber<8){//首位大于等于5 小于8 以1*分割
						hseparate=Math.pow(10,hincrementalString.length-1);
						var h1separate:Number=hseparate*(Math.ceil(minumumXField/hseparate));
						while(h1separate<=maximumXField){
							hdivideNumbers.push(h1separate);
							h1separate+=hseparate;
						}
					}else if(hfirstnumber>=2&&hfirstnumber<=4){//大于等于2  小于等于4>>  以0.5*分割
						hseparate=0.5*Math.pow(10,hincrementalString.length-1);
						var h_5separate:Number=hseparate*(Math.ceil(minumumXField/hseparate));
						while(h_5separate<=maximumXField){
							hdivideNumbers.push(h_5separate);
							h_5separate+=hseparate;
						}
					}else if(hfirstnumber==1){//等于1  以0.2分割
						hseparate=0.2*Math.pow(10,hincrementalString.length-1);
						var h_2separate:Number=hseparate*(Math.ceil(minumumXField/hseparate));
						while(h_2separate<=maximumXField){
							hdivideNumbers.push(h_2separate);
							h_2separate+=hseparate;
						}
					}
					
					for(var hj:int=0;hj<hdivideNumbers.length;hj++){
						var hdivideNumber:Number=hdivideNumbers[hj];
						
						gridShape.graphics.lineStyle(1,ThemeHander.style["table_gridColor"],0.8);//画横网格
						var hw:Number=((hdivideNumber-minumumXField)/hincremental)*(this.border_width-ThemeHander.style["bubblenode_maxradius"]);
						gridShape.graphics.moveTo(hw, 0-ThemeHander.style["bubblenode_maxradius"]*0.5);
						gridShape.graphics.lineTo(hw, this.border_height);
						
						//宽度，高度，文字大小，字体颜色，对齐方式   获取textfiled
						var hdivideTextField:TextField=Utility.getInstance().getTextField(40,
							20,12,ThemeHander.style["axis_color"],"center");
						hdivideTextField.selectable=false;
						hdivideTextField.x=hw;
						
						if(isHPercent){
							hdivideTextField.text=this._utility.formatNumberToString(hdivideNumber/hincrementalPrefix*100)+"%";
						}else{
							hdivideTextField.text=this._utility.formatNumberToString(hdivideNumber/hincrementalPrefix);
						}
						horizontalAxisShape.addChild(hdivideTextField);
					}
				}
			}
		}
		//取最近的大于的时间
		private function getMinBigData(items:Array,currentDate:Date):Array{
			var index:int=data.columnsindexs[data["slidingShaft"]];
			var _array:Array;
			for(var i:int=0;i<items.length;i++){
				var _date:Date=items[i][index];
				if(_date.getTime()>=currentDate.getTime()){
					if(_array){
						if(_date.getTime()<_array[index].getTime()){
							_array=items[i];
						}
					}else{
						_array=items[i];
					}
				}
			}
			return _array;
		}
		//取最近的小于的时间
		private function getMaxSmallData(items:Array,currentDate:Date):Array{
			var index:int=data.columnsindexs[data["slidingShaft"]];
			var _array:Array;
			for(var i:int=0;i<items.length;i++){
				var _date:Date=items[i][index];
				if(_date.getTime()<=currentDate.getTime()){
					if(_array){
						if(_date.getTime()>_array[index].getTime()){
							_array=items[i];
						}
					}else{
						_array=items[i];
					}
				}
			}
			return _array;
		}
		
		/**
		 * 画报表
		 */
		private function updateReport(useTweener:Boolean = false):void{
			zoomMinimap.graphics.clear();
			if(!data){//没有数据返回
				return;
			}
			//添加数据
			
			var rows:Object=data.rows;
			for(var rowID:String in rows){//每个节点对应的
					var items:Array=rows[rowID];//每个displayName对应的数据列表
					//根据当前时间获取前后最接近的两组数
					var maxSmallArray:Array=getMaxSmallData(items,currentDate);//最大的小于
					var minBigArray:Array=getMinBigData(items,currentDate);//大于
					if(!maxSmallArray||!minBigArray){
						return;
					}
					var bubbleNode:LBubbleNode=BubbleNodePool.getInstance().pop(rowID);
					bubbleNode.data=data;
					bubbleNode.currentDate=this.currentDate;
					
					var slidingShaftIndex:int=data.columnsindexs[data["slidingShaft"]];//求时间差值
					var bigTimer:Number=minBigArray[slidingShaftIndex].getTime();//最小的大于时间
					var smallTimer:Number=maxSmallArray[slidingShaftIndex].getTime();//最大的小于时间
					var dincremental:Number=bigTimer-smallTimer;//前后时间的差值
					var _dincremental:Number=this.currentDate.getTime()-smallTimer;//当前时间与最小时间的差值
					var dincrementalPersent:Number=_dincremental/dincremental;//当前时间差的比例
					//x轴值
					var xFieldIndex:int=data.columnsindexs[data["xField"]];
					var minBigXField:Number=minBigArray[xFieldIndex];//下一时间点值
					var maxSmallXField:Number=maxSmallArray[xFieldIndex];//上一时间点值
					var _hincremental:Number=Math.abs(minBigXField-maxSmallXField);//增量
					var currentXField:Number;
					if(dincremental!=0){
						if(minBigXField>maxSmallXField){//下一时间点大于上一时间点
							currentXField=maxSmallXField+dincrementalPersent*_hincremental;
						}else{
							currentXField=maxSmallXField-dincrementalPersent*_hincremental;
						}
					}else{
						currentXField=maxSmallXField;
					}
					
					var xField:String=data["xField"];
					var maximumXField:Number=this.currentMaxXField;//最大值
					var minumumXField:Number=this.currentMinXField;//最小值
					var hincremental:Number=maximumXField-minumumXField;//增量
					var xPoint:Number=(currentXField-minumumXField)/hincremental*(this.border_width-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放宽度
					
					//y轴
					var yFieldIndex:int=data.columnsindexs[data["yField"]];
					var minBigYField:Number=minBigArray[yFieldIndex];//最大值
					var maxSmallYField:Number=maxSmallArray[yFieldIndex];//最小值
					var _vincremental:Number=Math.abs(minBigYField-maxSmallYField);//增量
					var currentYField:Number;
					if(dincremental!=0){
						if(minBigYField>maxSmallYField){//下一时间点大于上一时间点
							currentYField=maxSmallYField+dincrementalPersent*_vincremental;
						}else{
							currentYField=maxSmallYField-dincrementalPersent*_vincremental;
						}
					}else{
						currentYField=maxSmallYField;
					}
					
					var yField:String=data["yField"];
					var maximumYField:Number=this.currentMaxYField;//最大值
					var minumumYField:Number=this.currentMinYField;//最小值
					var vincremental:Number=maximumYField-minumumYField;//增量
					var yPoint:Number=(maximumYField-currentYField)/vincremental*(this.border_height-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放高度
					
					//大小
					var radiusFieldIndex:int=data.columnsindexs[data["radiusField"]];
					var minBigRadiusField:Number=minBigArray[radiusFieldIndex];//大值
					var maxSmallRadiusField:Number=maxSmallArray[radiusFieldIndex];//小值
					var _rincremental:Number=Math.abs(minBigRadiusField-maxSmallRadiusField);
					var currentRadiusField:Number;
					if(dincremental!=0){
						if(minBigRadiusField>maxSmallRadiusField){//下一时间点大于上一时间点
							currentRadiusField=maxSmallRadiusField+dincrementalPersent*_rincremental;
						}else{
							currentRadiusField=maxSmallRadiusField-dincrementalPersent*_rincremental;
						}
					}else{
						currentRadiusField=maxSmallRadiusField;
					}
					
					var radiusField:String=data["radiusField"];
					var maximumRadiusField:Number=data.maximums[radiusField];//最大值
					var minumumRadiusField:Number=data.minimums[radiusField];//最小值
					var rincremental:Number=maximumRadiusField-minumumRadiusField;
					var maximumRadius:Number=ThemeHander.style["bubblenode_maxradius"];
					var minumumRadius:Number=ThemeHander.style["bubblenode_minradius"];
					var radius:Number=minumumRadius+((currentRadiusField-minumumRadiusField)/rincremental*(maximumRadius-minumumRadius));
					
					//颜色
					var color:uint=0x00ff00;
					
					var colorField:String=data["colorField"];
					if((data.enumAttribuye as Array).indexOf(colorField)>-1){//判断字段是否为枚举类型
						
						var indexColorEnum:int=data.columnsindexs[colorField];
						var colors:Array=data.colorEnums[colorField];
						for(var c:int=0;c<colors.length;c++){
							var enumItem:EnumItem=colors[c];
							if(enumItem.key==maxSmallArray[indexColorEnum]){
								color=enumItem.value;
								break;
							}
						}
					}else{
						var colorFieldIndex:int=data.columnsindexs[data["colorField"]];
						var minBigColorField:Number=minBigArray[colorFieldIndex];//最大值
						var maxSmallColorField:Number=maxSmallArray[colorFieldIndex];//最小值
						var _cincremental:Number=Math.abs(minBigColorField-maxSmallColorField);
						var currentColorField:Number;
						if(dincremental!=0){
							if(minBigColorField>maxSmallColorField){//下一时间点大于上一时间点
								currentColorField=maxSmallColorField+dincrementalPersent*_cincremental;
							}else{
								currentColorField=maxSmallColorField-dincrementalPersent*_cincremental;
							}
						}else{
							currentColorField=maxSmallColorField;
						}
						
						var maximumColorField:Number=data.maximums[colorField];//最大值
						var minumumColorField:Number=data.minimums[colorField];//最小值
						var cincremental:Number=maximumColorField-minumumColorField;
						
						
						if(cincremental!=0){
							var maximumColor:uint=0xff0000;
							var minumumColor:uint=0x00ffff;
							var cpercent:Number=(currentColorField-minumumColorField)/cincremental;
							color=getBetweenColor(minumumColor,maximumColor,(1-cpercent));
						}else{
						}
					}
					
					//给node赋值
					bubbleNode.xField=currentXField;
					bubbleNode.yField=currentYField;
					bubbleNode.colorField=currentColorField;
					bubbleNode.radiusField=currentRadiusField;
					
					bubbleNode.radius=radius;
					bubbleNode.fillColor=color;
					bubbleNode.currentX=xPoint;
					bubbleNode.currentY=yPoint;
					
					bubbleNode.border_width=this.border_width;
					bubbleNode.border_height=this.border_height;
					
					//更新初始轨迹
					if(bubbleNode.isSelect&&bubbleNode.isTrails){
						//更新用于轨迹的控制点列表
						if(!bubbleNode.startTrail.startTrailsDate || bubbleNode.startTrail.startTrailsDate.getTime() > this.currentDate.getTime()){
							trace("setStartTrails");
							bubbleNode.setStartTrails();
						}else{
							trace("updateStartTrails");
							updateStartTrails(items,bubbleNode);
						}
						//算出共跨过了几个节点
						var controlPointFields:Array=getAcrossDatas(items,bubbleNode.startTrail.startTrailsDate);
						var _controlPoints:Array=[];
						for(var cpf:int=0;cpf<controlPointFields.length;cpf++){
							_controlPoints.push(controlPoints(controlPointFields[cpf]));  
						}
						bubbleNode.controlPoints=_controlPoints;
					}else{
						
					}
					
					//运动特效
					if(useTweener){
						bubbleNode.drawByTweener();
					}else{
						bubbleNode.draw();
					}
					
					
					if(this.isZoomed){//画缩略图的点位
					//生成缩略图
						var maximumXField_total:Number=data.maximums[data["xField"]];
						var minumumXField_total:Number=data.minimums[data["xField"]];
						var maximumYField_total:Number=data.maximums[data["yField"]];
						var minumumYField_total:Number=data.minimums[data["yField"]];
						var hincremental_MiniMap:Number=maximumXField_total-minumumXField_total;
						var vincremental_MiniMap:Number=maximumYField_total-minumumYField_total;
						var miniMapXPoint:Number=(currentXField-minumumXField_total)/hincremental_MiniMap*(ThemeHander.style["zoomMinimap_width"]);//根据原始宽度
						var miniMapYPoint:Number=(maximumYField_total-currentYField)/vincremental_MiniMap*(ThemeHander.style["zoomMinimap_height"]);//根据原始宽度
						zoomMinimap.graphics.beginFill(color,1);
						zoomMinimap.graphics.drawCircle(miniMapXPoint,miniMapYPoint,2);
						zoomMinimap.graphics.endFill();
					}
					
					this.reportShape.addChild(bubbleNode);
			}
			
			if(this.isZoomed){//小地图边框 内边框
				miniMap_minX=(this.currentMinXField-minumumXField_total)/(maximumXField_total-minumumXField_total)*(ThemeHander.style["zoomMinimap_width"]);
				miniMap_maxX=(this.currentMaxXField-minumumXField_total)/(maximumXField_total-minumumXField_total)*(ThemeHander.style["zoomMinimap_width"]);
				
				miniMap_minY=(maximumYField_total-this.currentMaxYField)/(maximumYField_total-minumumYField_total)*(ThemeHander.style["zoomMinimap_height"]);
				miniMap_maxY=(maximumYField_total-this.currentMinYField)/(maximumYField_total-minumumYField_total)*(ThemeHander.style["zoomMinimap_height"]);
				
				zoomMinimap.graphics.lineStyle(1,0x000000);//画灰色部分
				zoomMinimap.graphics.beginFill(0x000000,0.1);
				zoomMinimap.graphics.drawRect(0,0,ThemeHander.style["zoomMinimap_width"],ThemeHander.style["zoomMinimap_height"]);
				zoomMinimap.graphics.drawRect(miniMap_minX,miniMap_minY,miniMap_maxX-miniMap_minX,miniMap_maxY-miniMap_minY);
				zoomMinimap.graphics.endFill();
				
				zoomMinimap.graphics.beginFill(0xffffff,0.0)//画中间白色区域
				zoomMinimap.graphics.drawRect(miniMap_minX,miniMap_minY,miniMap_maxX-miniMap_minX,miniMap_maxY-miniMap_minY);
				zoomMinimap.graphics.endFill();
			}
		}
		
		private function updateStartTrails(items:Array,bubbleNode:LBubbleNode):void{
			var startTrailsDate:Date = bubbleNode.startTrail.startTrailsDate as Date;
			trace(startTrailsDate.getMonth()+":"+startTrailsDate.getDate()+":"+startTrailsDate.getHours());
			//根据当前时间获取前后最接近的两组数
			var maxSmallArray:Array=getMaxSmallData(items,startTrailsDate);//最大的小于
			var minBigArray:Array=getMinBigData(items,startTrailsDate);//大于
			if(!maxSmallArray||!minBigArray){
				return;
			}
			
			var slidingShaftIndex:int=data.columnsindexs[data["slidingShaft"]];//求时间差值
			var bigTimer:Number=minBigArray[slidingShaftIndex].getTime();//最小的大于时间
			var smallTimer:Number=maxSmallArray[slidingShaftIndex].getTime();//最大的小于时间
			var dincremental:Number=bigTimer-smallTimer;//前后时间的差值
			var _dincremental:Number=startTrailsDate.getTime()-smallTimer;//当前时间与最小时间的差值
			var dincrementalPersent:Number=_dincremental/dincremental;//当前时间差的比例
			//x轴值
			var xFieldIndex:int=data.columnsindexs[data["xField"]];
			
			var minBigXField:Number=minBigArray[xFieldIndex];//下一时间点值
			var maxSmallXField:Number=maxSmallArray[xFieldIndex];//上一时间点值
			var _hincremental:Number=Math.abs(minBigXField-maxSmallXField);//增量
			var currentXField:Number;
			if(dincremental!=0){
				if(minBigXField>maxSmallXField){//下一时间点的值大于上一时间点
					currentXField=maxSmallXField+dincrementalPersent*_hincremental;
				}else{
					currentXField=maxSmallXField-dincrementalPersent*_hincremental;
				}
			}else{
				currentXField=maxSmallXField;
			}
			
			var xField:String=data["xField"];
			var maximumXField:Number=this.currentMaxXField;//最大值
			var minumumXField:Number=this.currentMinXField;//最小值
			var hincremental:Number=maximumXField-minumumXField;//增量
			var xPoint:Number=(currentXField-minumumXField)/hincremental*(this.border_width-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放宽度
			
			//y轴
			var yFieldIndex:int=data.columnsindexs[data["yField"]];
			var minBigYField:Number=minBigArray[yFieldIndex];//最大值
			var maxSmallYField:Number=maxSmallArray[yFieldIndex];//最小值
			var _vincremental:Number=Math.abs(minBigYField-maxSmallYField);//增量
			var currentYField:Number;
			if(dincremental!=0){
				if(minBigYField>maxSmallYField){//下一时间点大于上一时间点
					currentYField=maxSmallYField+dincrementalPersent*_vincremental;
				}else{
					currentYField=maxSmallYField-dincrementalPersent*_vincremental;
				}
			}else{
				currentYField=maxSmallYField;
			}
			
			var yField:String=data["yField"];
			var maximumYField:Number=this.currentMaxYField;//最大值
			var minumumYField:Number=this.currentMinYField;//最小值
			var vincremental:Number=maximumYField-minumumYField;//增量
			var yPoint:Number=(maximumYField-currentYField)/vincremental*(this.border_height-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放高度
			
			//大小
			var radiusFieldIndex:int=data.columnsindexs[data["radiusField"]];
			var minBigRadiusField:Number=minBigArray[radiusFieldIndex];//大值
			var maxSmallRadiusField:Number=maxSmallArray[radiusFieldIndex];//小值
			var _rincremental:Number=Math.abs(minBigRadiusField-maxSmallRadiusField);
			var currentRadiusField:Number;
			if(dincremental!=0){
				if(minBigRadiusField>maxSmallRadiusField){//下一时间点大于上一时间点
					currentRadiusField=maxSmallRadiusField+dincrementalPersent*_rincremental;
				}else{
					currentRadiusField=maxSmallRadiusField-dincrementalPersent*_rincremental;
				}
			}else{
				currentRadiusField=maxSmallRadiusField;
			}
			
			var radiusField:String=data["radiusField"];
			var maximumRadiusField:Number=data.maximums[radiusField];//最大值
			var minumumRadiusField:Number=data.minimums[radiusField];//最小值
			var rincremental:Number=maximumRadiusField-minumumRadiusField;
			var maximumRadius:Number=ThemeHander.style["bubblenode_maxradius"];
			var minumumRadius:Number=ThemeHander.style["bubblenode_minradius"];
			var radius:Number=minumumRadius+((currentRadiusField-minumumRadiusField)/rincremental*(maximumRadius-minumumRadius));
			
			//颜色
			var color:uint=0x00ff00;
			
			var colorField:String=data["colorField"];
			if(data.types[colorField] == "enum"){//判断字段是否为枚举类型
				var indexColorEnum:int=data.columnsindexs[colorField];
				var colors:Array=data.colorEnums[colorField];
				for(var c:int=0;c<colors.length;c++){
					var enumItem:EnumItem=colors[c];
					if(enumItem.key==maxSmallArray[indexColorEnum]){
						color=enumItem.value;
						break;
					}
				}
			}else{
				var colorFieldIndex:int=data.columnsindexs[data["colorField"]];
				var minBigColorField:Number=minBigArray[colorFieldIndex];//最大值
				var maxSmallColorField:Number=maxSmallArray[colorFieldIndex];//最小值
				var _cincremental:Number=Math.abs(minBigColorField-maxSmallColorField);
				var currentColorField:Number;
				if(dincremental!=0){
					if(minBigColorField>maxSmallColorField){//下一时间点大于上一时间点
						currentColorField=maxSmallColorField+dincrementalPersent*_cincremental;
					}else{
						currentColorField=maxSmallColorField-dincrementalPersent*_cincremental;
					}
				}else{
					currentColorField=maxSmallColorField;
				}
				
				var maximumColorField:Number=data.maximums[colorField];//最大值
				var minumumColorField:Number=data.minimums[colorField];//最小值
				var cincremental:Number=maximumColorField-minumumColorField;
				
				
				if(cincremental!=0){
					var maximumColor:uint=0xff0000;
					var minumumColor:uint=0x00ffff;
					var cpercent:Number=(currentColorField-minumumColorField)/cincremental;
					color=getBetweenColor(minumumColor,maximumColor,(1-cpercent));
				}else{
				}
			}
			
			
			bubbleNode.startTrail.radius=radius;
			bubbleNode.startTrail.fillColor=color;
			bubbleNode.startTrail.currentX=xPoint;
			bubbleNode.startTrail.currentY=yPoint;
		}
		
		//根据轨迹起始时间和当前时间算出跨越的时间节点
		private function getAcrossDatas(items:Array,startTrailsDate:Date):Array{
			var index:int=data.columnsindexs[data["slidingShaft"]];
			var _array:Array=[];
			for(var i:int=0;i<items.length;i++){
				var _date:Date=items[i][index];
				if(startTrailsDate && _date.getTime() > startTrailsDate.getTime() && this.currentDate && _date.getTime() < this.currentDate.getTime()){
					_array.push(items[i]);
				}
			}
			return _array;
		}
		
		private function controlPoints (currentObjectArray:Array):Object{
				//x轴值
				var xFieldIndex:int=data.columnsindexs[data["xField"]];
				var currentXField:Number=currentObjectArray[xFieldIndex];
				
				var maximumXField:Number=this.currentMaxXField;//最大值
				var minumumXField:Number=this.currentMinXField;//最小值
				var hincremental:Number=maximumXField-minumumXField;//增量
				var xPoint:Number=(currentXField-minumumXField)/hincremental*(this.border_width-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放宽度
				
				//y轴
				var yFieldIndex:int=data.columnsindexs[data["yField"]];
				var currentYField:Number=currentObjectArray[yFieldIndex];
				
				var maximumYField:Number=this.currentMaxYField;//最大值
				var minumumYField:Number=this.currentMinYField;//最小值
				var vincremental:Number=maximumYField-minumumYField;//增量
				var yPoint:Number=(maximumYField-currentYField)/vincremental*(this.border_height-ThemeHander.style["bubblenode_maxradius"]);//根据当前缩放高度
				
				
				//大小
				var radiusField:String=data["radiusField"];
				var radiusFieldIndex:int=data.columnsindexs[radiusField];
				var currentRadiusField:Number=currentObjectArray[radiusFieldIndex];
				
				var maximumRadiusField:Number=data.maximums[radiusField];//最大值
				var minumumRadiusField:Number=data.minimums[radiusField];//最小值
				var rincremental:Number=maximumRadiusField-minumumRadiusField;
				var maximumRadius:Number=ThemeHander.style["bubblenode_maxradius"];
				var minumumRadius:Number=ThemeHander.style["bubblenode_minradius"];
				var radius:Number=minumumRadius+((currentRadiusField-minumumRadiusField)/rincremental*(maximumRadius-minumumRadius));
				
				//颜色
				var color:uint=0x00ff00;
				
				var colorField:String=data["colorField"];
				var colorFieldIndex:int=data.columnsindexs[data["colorField"]];
				
				if((data.enumAttribuye as Array).indexOf(colorField)>-1){//判断字段是否为枚举类型
					
					var colors:Array=data.colorEnums[colorField];
					for(var c:int=0;c<colors.length;c++){
						var enumItem:EnumItem=colors[c];
						if(enumItem.key==currentObjectArray[colorFieldIndex]){
							color=enumItem.value;
							break;
						}
					}
				}else{
					var currentColorField:Number=currentObjectArray[colorFieldIndex];
					
					var maximumColorField:Number=data.maximums[colorField];//最大值
					var minumumColorField:Number=data.minimums[colorField];//最小值
					var cincremental:Number=maximumColorField-minumumColorField;
					
					
					if(cincremental!=0){
						var maximumColor:uint=0xff0000;
						var minumumColor:uint=0x00ffff;
						var cpercent:Number=(currentColorField-minumumColorField)/cincremental;
						color=getBetweenColor(minumumColor,maximumColor,(1-cpercent));
					}else{
					}
				}
				
				
				var slidingShaftField:String=data["slidingShaft"];
				var slidingShaftFieldIndex:int=data.columnsindexs[slidingShaftField];
				var currentDate:Date=currentObjectArray[slidingShaftFieldIndex];
				
				var control:Object=new Object();
				
				
				control.currentDate=currentDate;
				control.currentX=xPoint;
				control.currentY=yPoint;
				control.radius=radius;
				control.fillColor=color;
				return control;
		}
		
		//颜色渐变  color1小于color2
		public function getBetweenColor(color1:uint,color2:uint, percent:Number):uint
		{
			//分别计算R,G,B的总变化量
			var dRed:Number = (color1 >> 16) - (color2 >> 16);
			var dGreen:Number = ((color1 >> 8) & 0xff) - ((color2 >> 8) & 0xff);
			var dBlue:Number = (color1 & 0xff) - (color2 & 0xff);
			
			//计算变化后的R,G,B的值
			var tempRed:Number = (color2 >> 16) + dRed * percent;
			var tempGreen:Number = ((color2 >> 8) & 0xff) + dGreen * percent;
			var tempBlue:Number = (color2 * 0xff) + dBlue * percent;
			
			return tempRed << 16 | tempGreen << 8 | tempBlue;
		}
		
		public function doResize(width:Number,height:Number):void{
			if(!width||!height){
				return;
			}
			var _width:Number=width-ThemeHander.style["table_x"]-ThemeHander.style["table_right"];
			var _height:Number=height-ThemeHander.style["table_y"]-ThemeHander.style["table_bottom"];
			this.border_width=_width-ThemeHander.style["leftvertical_width"];
			this.border_height=_height-ThemeHander.style["horizontal_height"];
			
			masksShape.graphics.clear();//背景
			masksShape.graphics.beginFill(0xffffff,1);
			masksShape.graphics.drawRect(-ThemeHander.style["table_x"],-20,width,height);
			masksShape.graphics.drawRect(ThemeHander.style["leftvertical_width"],0,border_width+1,border_height+1);
			masksShape.graphics.endFill();
			
			doUpdate();//重画图表
		}
	}
}