package UI.bubblechart
{
	import caurina.transitions.Tweener;
	
	import events.LEvent;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.ThemeHander;
	import utils.Utility;
	
	public class LBubbleNode extends Sprite
	{
		public var radius:Number=ThemeHander.style["bubblenode_minradius"];
		public var fillColor:uint=0xFF0000;
		public var borderColor:uint=0x000000;
		
		public var xField:Number=0;
		public var yField:Number=0;
		public var colorField:Number=0;
		public var radiusField:Number=0;
		
		public var gardenShape:Sprite=new Sprite();
		private var circleShape:Shape=new Shape();
		private var borderShape:Shape=new Shape();
		public var labelTextField:Sprite=new Sprite();
		private var labelText:TextField;
		
		public var border_width:Number=1.0;//边框宽度
		public var border_height:Number=1.0;//边框高度
		
		private var labelShadowFilters:Array=[];
		private var labelShadowFilter:DropShadowFilter
		=new DropShadowFilter(3,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false);
		
		
		private var gardenShapeShadowFilters:Array=[];
		private var gardenShapeShadowFilter:DropShadowFilter
		=new DropShadowFilter(5,45,0x000000,0.8,8,8,0.65,BitmapFilterQuality.LOW,false,false);
		
		private var _utility:Utility=Utility.getInstance();
		
		
		private var labelRelativeX:Number;//标签的相对位置
		private var labelRelativeY:Number;
		
		public var isSelect:Boolean=false;
		public var isTrails:Boolean=false;
		
		private var trailsShape:Shape=new Shape();//轨迹层
		
		public var data:Object=new Object();//数据
		
		//当前轨迹起始点
		public var startTrail:Object=new Object();
		public var currentDate:Date;
		
		public var controlPoints:Array=[];//跨过的节点
		/**
		 * 
		 * 初始化
		 */
		public function LBubbleNode()
		{
			super();
			gardenShape.buttonMode=true;//鼠标手型
			gardenShape.useHandCursor=true;
			labelTextField.buttonMode=true;
			labelTextField.useHandCursor=true;
			labelTextField.mouseChildren=true;
			
			this.addChild(trailsShape);
			
			//阴影
			gardenShape.graphics.beginFill(this.fillColor,1);
			gardenShape.graphics.drawCircle(0,0,radius);
			gardenShape.graphics.endFill();
			gardenShapeShadowFilters.push(gardenShapeShadowFilter);
			gardenShape.filters =gardenShapeShadowFilters;
			this.addChild(gardenShape);
			//边框
			borderShape.graphics.lineStyle(0.5,0x000000);
			borderShape.graphics.drawCircle(0,0,radius);
			this.addChild(borderShape);
			
			circleShape.graphics.beginFill(fillColor,1);
			circleShape.graphics.drawCircle(0,0,radius+4);
			circleShape.graphics.drawCircle(0,0,radius+6);
			circleShape.graphics.endFill();
			this.addChild(circleShape);
			circleShape.visible=false;
			
			//标签
			labelText=Utility.getInstance().getTextField(0,
				0,14,0x000000,"left")
			labelTextField.addChild(labelText);
			labelText.background=true;
			labelText.backgroundColor=0xffffff;
			labelText.borderColor=0x000000;
			labelText.border=true;
			var labelFormat:TextFormat=labelText.defaultTextFormat;
			labelFormat.bold=true;
			labelText.defaultTextFormat=labelFormat;
			
			labelShadowFilters.push(labelShadowFilter);
			labelTextField.filters =labelShadowFilters;
			
			
			//事件
			gardenShape.addEventListener(MouseEvent.MOUSE_OVER,gardenShapeMouseOver);//鼠标移入
			gardenShape.addEventListener(MouseEvent.MOUSE_OUT,gardenShapeMouseOut);//鼠标移除
			//gardenShape.addEventListener(MouseEvent.MOUSE_DOWN,gardenShapeMouseDown);//鼠标落下
			gardenShape.addEventListener(MouseEvent.CLICK,gardenShapeClick);//鼠标点击
			
			labelTextField.addEventListener(MouseEvent.MOUSE_DOWN,labelMouseDown);//标签鼠标落下
			labelTextField.addEventListener(MouseEvent.MOUSE_OVER,labelMouseOver);//标签鼠标移入
			labelTextField.addEventListener(MouseEvent.MOUSE_OUT,labelMouseOut);//标签鼠标移除
			
			
			//轨迹选择
			_utility.addEventListener(LEvent.TRAILS,trailsFunction);
		}
		
		private var _nodeID:String="";
		public function set nodeID(_nodeID:String):void{
			labelText.text=_nodeID;
			this._nodeID=_nodeID;
			_utility.addEventListener(LEvent.NODESELECT+this._nodeID,nodeSelectFunction);
		}
		
		public function get nodeID():String{
			return _nodeID;
		}
		
		
		public var currentX:Number=0;
		public var currentY:Number=0;
		//更新（使用特效）
		public function drawByTweener():void{
			Tweener.addTween(gardenShape, 
				{ x:currentX, y:currentY,_color:fillColor,width:2*radius,height:2*radius,time:1,onUpdate:onUpdate} );
			Tweener.addTween(circleShape, 
				{ x:currentX, y:currentY,_color:fillColor,width:3*radius,height:3*radius,time:1} );
			Tweener.addTween(borderShape, 
				{ x:currentX, y:currentY,width:2*radius,height:2*radius,time:1} );
		}
		public function draw():void{
			drawByTweener();
		}
		
		private function onUpdate():void{
			
			this.currentX=gardenShape.x;
			this.currentY=gardenShape.y;
			
			showLabel(this.currentX+labelRelativeX,this.currentY+labelRelativeY);
			
			if(this.isSelect&&this.isTrails){
				trailsShape.graphics.clear();
				
				
				var x1:Number = this.startTrail.currentX;//轨迹开始点
				var y1:Number = this.startTrail.currentY;
				var r1:Number = this.startTrail.radius;
				var fillColor1:uint = this.startTrail.fillColor;
				
				//在开始轨迹点处画圆
				trailsShape.graphics.beginFill(this.startTrail.fillColor,1);
				trailsShape.graphics.drawCircle(x1,y1,r1);
				trailsShape.graphics.endFill();
			
				
				for(var i:int = 0;i < controlPoints.length;i++){//轨迹经过的几个点
					var point:Object = controlPoints[i];
					
					var _x:Number = point.currentX;
					var _y:Number = point.currentY;
					var _r:Number = point.radius;
					var _fillColor:uint = point.fillColor;
					
					//在连接点出画圆
					trailsShape.graphics.beginFill(_fillColor,1);
					trailsShape.graphics.drawCircle(_x,_y,_r);
					trailsShape.graphics.endFill();
					
					doTrails(x1,y1,r1,fillColor1,_x,_y,_r,_fillColor);
					
					x1 = _x;
					y1 = _y;
					r1 = _r; 
					fillColor1 = _fillColor;
				}// end  controlPoints
				
				
				var x2:Number = this.currentX;//结尾点
				var y2:Number = this.currentY;
				var r2:Number = this.radius;
				var fillColor2:uint = this.fillColor;
				doTrails(x1,y1,r1,fillColor1,x2,y2,r2,fillColor2);
			}
		}
		
		private var a1:Point = new Point();//四个切点
		private var a2:Point = new Point();
		private var a3:Point = new Point();
		private var a4:Point = new Point();
		
		/**
		 * 画轨迹线
		 */
		private function doTrails(x1:Number,y1:Number,r1:Number,fillColor1:uint,x2:Number,y2:Number,r2:Number,fillColor2:uint):void{
			var d:Number = Math.pow((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1),0.5);
			if(d == 0){//两圆重合
				return;
			}
			if(x1 == x2){//两圆心在y轴上
				a1.x = x1+r1*-1;
				a2.x = x2+r2*-1;
				a3.x = x1+r1*1;
				a4.x = x2+r2*1; 
				
				a1.y = y1;
				a2.y = y2;
				a3.y = y1;
				a4.y = y2;
			}
			//α
			var a:Number = Math.acos((r2-r1)/d);
			//β
			var b:Number = Math.atan((y2-y1)/(x2-x1));
			
			a1.x = (x1+r1*Math.cos(a+b));
			a2.x = (x2+r2*Math.cos(a+b));
			a3.x = (x1+r1*Math.cos(b-a));
			a4.x = (x2+r2*Math.cos(b-a)); 
			
			a1.y = (y1+r1*Math.sin(a+b));
			a2.y = (y2+r2*Math.sin(a+b));
			a3.y = (y1+r1*Math.sin(b-a));
			a4.y = (y2+r2*Math.sin(b-a));
			
			var minX:Number = Math.min(a1.x,a2.x,a3.x,a4.x);
			var maxX:Number = Math.max(a1.x,a2.x,a3.x,a4.x);
			
			var minY:Number = Math.min(a1.y,a2.y,a3.y,a4.y);
			var maxY:Number = Math.max(a1.y,a2.y,a3.y,a4.y);
			
			var _disX:Number = maxX-minX;
			var _disY:Number = maxY-minY;
			
			var colorField:String=data["colorField"];
			if(data.types[colorField] != "enum"){
				var matix:Matrix =new Matrix()//矩阵
				matix.createGradientBox(_disX,_disY ,Math.atan2((y2-y1),(x2-x1)),minX,minY);
				trailsShape.graphics .beginGradientFill(GradientType.LINEAR,[fillColor1,fillColor2],[1,1],[0,255],matix);
			}else{
				trailsShape.graphics .beginFill(fillColor1,1);
			}
			
			trailsShape.graphics.moveTo(a1.x,a1.y);
			trailsShape.graphics.lineTo(a3.x,a3.y);
			trailsShape.graphics.lineTo(a4.x,a4.y);
			trailsShape.graphics.lineTo(a2.x,a2.y);
			trailsShape.graphics.lineTo(a1.x,a1.y);
			
			trailsShape.graphics.endFill();
		}
		
		//轨迹选择 
		private function trailsFunction(event:LEvent):void{
			var isTrails:Boolean=event.stanza as Boolean;
			this.isTrails=isTrails;
			updateStartTrails();
		}
		
		//更新初始轨迹点-->当初始点大于当前时间点的时候
		public function updateStartTrails():void{
			trace("updateStartTrails node");
			setStartTrails();
			if(isTrails&&this.isSelect){
			}else{
				trailsShape.graphics.clear();
			}
		}
		//设置初始轨迹的值
		public function setStartTrails():void{
			this.startTrail.startTrailsDate=currentDate;
			this.startTrail.currentX=currentX;
			this.startTrail.currentY=currentY;
			this.startTrail.radius=this.radius;
			this.startTrail.fillColor=this.fillColor;
		}
		
		//鼠标移入
		private function gardenShapeMouseOver(event:MouseEvent=null):void{
				
			if(!labelRelativeX){
				labelRelativeX=radius*2;
			}
			if(!labelRelativeY){
				labelRelativeY=-(this.radius*2+this.labelTextField.height);
			}
			showLabel(this.currentX+labelRelativeX,this.currentY+labelRelativeY);
			this.addChild(labelTextField);
			labelText.borderColor=this.fillColor;
			circleShape.visible=true;
			
			_utility.dispatchEvent(new LEvent(LEvent.BUBBLELABELMOVEIN,this));
		}
		
		//鼠标移除
		private function gardenShapeMouseOut(event:MouseEvent=null):void{
			if(this.isSelect){
				showLabel(this.currentX+labelRelativeX,this.currentY+labelRelativeY);
				this.addChild(labelTextField);
			}else{
				if(labelTextField.parent&&labelTextField.parent==this){
					this.removeChild(labelTextField);
				}
			}
			labelText.borderColor=0x000000;
			circleShape.visible=false;
			
			_utility.dispatchEvent(new LEvent(LEvent.BUBBLELABELMOVEOUT,this));
		}
		
		//鼠标按下
		/*private function gardenShapeMouseDown(event:MouseEvent):void{
			event.stopImmediatePropagation();
		}*/
		
		//鼠标点击
		private function gardenShapeClick(event:MouseEvent):void{
			this._utility.dispatchEvent(new LEvent(LEvent.NODESELECT+this._nodeID,!this.isSelect));
		}
		
		//选中，非选中切换
		private function nodeSelectFunction(event:LEvent):void{
			if(!labelRelativeX){
				labelRelativeX=radius*2;
			}
			if(!labelRelativeY){
				labelRelativeY=-(this.radius*2+this.labelTextField.height);
			}
			this.isSelect=event.stanza as Boolean;
			if(isSelect){
				showLabel(this.currentX+labelRelativeX,this.currentY+labelRelativeY);
				this.addChild(labelTextField);
				lintTo();
			}else{
				if(labelTextField.parent&&labelTextField.parent==this){
					this.removeChild(labelTextField);
				}
				this.graphics.clear();
			}
			//更新轨迹初始点
			updateStartTrails();
		}
		
		//显示标签
		private var minX:Number=-ThemeHander.style["bubblenode_maxradius"]*0.5;
		private var minY:Number=-ThemeHander.style["bubblenode_maxradius"]*0.5;
		
		private var maxX:Number=border_width-ThemeHander.style["bubblenode_maxradius"]*0.5;
		private var maxY:Number=border_height-ThemeHander.style["bubblenode_maxradius"]*0.5;
		
		private function showLabel(x:Number,y:Number):void{
			if(x<minX){
				x=minX;
			}else if((x+labelTextField.width)>(border_width-ThemeHander.style["bubblenode_maxradius"]*0.5)){
				x=(border_width-ThemeHander.style["bubblenode_maxradius"]*0.5)-labelTextField.width;
			}
			
			if(y<minY){
				y=minY;
			}else if((y+labelTextField.height)>(border_height-ThemeHander.style["bubblenode_maxradius"]*0.5)){
				y=(border_height-ThemeHander.style["bubblenode_maxradius"]*0.5)-labelTextField.height;
			}
			
			labelTextField.x=x;
			labelTextField.y=y;
			
			//是否需要连线
			if(isSelect){
				lintTo();
			}else{
				this.graphics.clear();
			}
		}
		private function lintTo():void{
			if(this.isSelect){
				this.graphics.clear();
				this.graphics.lineStyle(1,0x000000);
				this.graphics.moveTo(labelTextField.x+labelTextField.width*0.5,labelTextField.y+labelTextField.height*0.5);
				this.graphics.lineTo(this.currentX,this.currentY);
			}
		}
		
		//标签移入
		private function labelMouseOver(event:MouseEvent):void{
			gardenShapeMouseOver();
		}
		//标签移除
		private function labelMouseOut(event:MouseEvent):void{
			gardenShapeMouseOut()
		}
		
		//标签按下
		private function labelMouseDown(event:MouseEvent):void{
			event.stopImmediatePropagation();
			this._utility.appSprite.addEventListener(Event.ENTER_FRAME,labelDrag);
			this._utility.appSprite.addEventListener(MouseEvent.MOUSE_UP,labelStopDrag);
		}
		
		private function labelDrag(event:Event):void{
			showLabel(this.mouseX-this.labelTextField.width*0.5,this.mouseY-this.labelTextField.height*0.5);
			labelRelativeX=(this.mouseX-this.labelTextField.width*0.5)-this.currentX;
			labelRelativeY=(this.mouseY-this.labelTextField.height*0.5)-this.currentY;
		}
		private function labelStopDrag(event:MouseEvent):void{
			showLabel(this.mouseX-this.labelTextField.width*0.5,this.mouseY-this.labelTextField.height*0.5);
			labelRelativeX=(this.mouseX-this.labelTextField.width*0.5)-this.currentX;
			labelRelativeY=(this.mouseY-this.labelTextField.height*0.5)-this.currentY;
			this._utility.appSprite.removeEventListener(Event.ENTER_FRAME,labelDrag);
			this._utility.appSprite.removeEventListener(MouseEvent.MOUSE_UP,labelStopDrag);
		}
		
	}
}
