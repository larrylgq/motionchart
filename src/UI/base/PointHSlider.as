package UI.base
{
	import events.LEvent;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.ThemeHander;
	import utils.Utility;
	
	public class PointHSlider extends Sprite
	{
		public static const millisecondsPerMinute:int = 1000 * 60;
		public static const millisecondsPerHour:int = 1000 * 60 * 60;
		public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;
		private var _utility:Utility=Utility.getInstance();//公共属性类
		private var playButton:Sprite = new Sprite();//播放按钮
		private var suspendButton:Sprite = new Sprite();//暂停按钮
		
		[Embed(source = "images/play.png")] 
		public var playClass:Class; 
		
		[Embed(source = "images/suspend.png")] 
		public var suspendClass:Class; 
		
		private var slider:HSliderThumb=new HSliderThumb();//滑动轨迹条
		
		private var currentDateTextField:TextField;
		

		
		public var startPoint:Date;//开始时间点
		public var endPoint:Date;//结束时间点
		public var dincremental:Number=0;//时间差
		public var dateIncremental:Number=0;//天的差值
		
		public var _width:Number=72;//默认宽度
		public var _height:Number=30;//默认高度 *
		public var sliderWidth:Number=32;//默认轨迹条宽度
		public var sliderThumbWidth:Number=16;//默认手柄宽度
		
		public function PointHSlider()
		{
			super();
			currentDateTextField=Utility.getInstance().getTextField(60,
				20,14,0x555555,"left");
			var labelFormat:TextFormat=currentDateTextField.defaultTextFormat;
			labelFormat.bold=true;
			currentDateTextField.defaultTextFormat=labelFormat;
			currentDateTextField.y=-10;
			this.addChild(currentDateTextField);
			
			this.buttonMode=true;
			this.useHandCursor=true;
			
			playButton.addChild(new playClass());  
			
			suspendButton.addChild(new suspendClass());; 
			
			this.addChild(slider);
			
			//添加滑块事件
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);//跳至某一点
			slider.addEventListener(MouseEvent.MOUSE_DOWN,sliderMouseDown);//滑动块按下
			playButton.addEventListener(MouseEvent.CLICK,playButtonHander);//播放
			suspendButton.addEventListener(MouseEvent.CLICK,suspendButtonHander);//暂停
			
			this.addChild(playButton);
			slider.x=40;
			slider.y=7;
			this.addChild(slider);
		}
		
		/**
		 * 设置最小，最大时间
		 */
		public function setDate(startDate:Date,endDate:Date):void{
			currentDate=startDate;
			this.startPoint=startDate;
			this.endPoint=new Date(endDate.getFullYear(),endDate.getMonth(),endDate.getDate()+1);
			
			if(startPoint && this.endPoint){
				dincremental=endPoint.getTime()-startPoint.getTime();
				dateIncremental=Math.floor(dincremental/millisecondsPerDay);
			}
			doDraw();
		}
		
		//显示
		public function doDraw():void{
			if(startPoint && this.endPoint && dateIncremental > 0){
				this.graphics.clear();
				this.graphics.beginFill(0xffffff,1);
				this.graphics.drawRect(0,0,this._width,this._height);
				this.graphics.endFill();
				
				this.graphics.lineStyle(5,ThemeHander.style["table_borderColor"],0.8);
				this.graphics.moveTo(40, 15);
				this.graphics.lineTo(this._width, 15);
				this.graphics.lineStyle(1,0x333333,0.8);
				this.graphics.moveTo(40, 13);
				this.graphics.lineTo(this._width, 13);
				/*this.graphics.moveTo(40, 7);
				this.graphics.lineTo(40, 23);
				this.graphics.moveTo(this._width, 7);
				this.graphics.lineTo(this._width, 23);*/
				
				var _sliderWidth:Number=this.sliderWidth/dateIncremental;//重画滑动条
				sliderThumbWidth=_sliderWidth<16?16:_sliderWidth;
				slider.setSize(sliderThumbWidth,16);
				
				//初始化图表
				setPoint(40);//重置当前时间点
			}else{
				this.graphics.clear();
				playButton.visible=false;
				slider.visible=false;
			}
		}
		
		/**
		 * 设置位置
		 */
		private var oldPointX:Number;
		private var currentDate:Date=new Date();
		private function setPoint(pointX:Number,useTweener:Boolean=false):void{
			if(pointX==oldPointX){
				return;
			}
			if(pointX<40){
				pointX=40;
			}
			if(pointX>this._width-sliderThumbWidth){
				pointX=this._width-sliderThumbWidth;
			}
			
			slider.x=pointX;
			oldPointX=pointX;
			
			
			var currentTimer:Number=startPoint.getTime()+(pointX-40)/this.sliderWidth*dincremental;
			currentDate=new Date(currentTimer);
			
			var currentDateTextFieldX:Number=pointX+this.sliderThumbWidth*0.5-30;
			currentDateTextField.x=currentDateTextFieldX<40?40:currentDateTextFieldX;
			currentDateTextField.text=currentDate.getFullYear()+"-"+(currentDate.getMonth()+1)+"-"+currentDate.getDate();
			if(useTweener){
				this._utility.dispatchEvent(new LEvent(LEvent.POINTHSLIDERSELECT,currentDate));
			}else{
				this._utility.dispatchEvent(new LEvent(LEvent.POINTHSLIDERMOVETO,currentDate));
			}
		}
		
		/**
		 * 事件
		 */
		//跳至某一点
		private function mouseDown(event:MouseEvent):void{
			if(this.mouseX>=40 && this.mouseX<=this._width){
				suspendButtonHander();
				var pointX:Number=this.mouseX-(sliderThumbWidth*0.5);
				setPoint(pointX,true);
				_utility.appSprite.addEventListener(MouseEvent.MOUSE_UP,sliderMouseUp);
				
			}
		}
		
		//滑动块按下
		private function sliderMouseDown(event:MouseEvent):void{
			if(_utility.appSprite){
				suspendButtonHander();
				_utility.appSprite.addEventListener(MouseEvent.MOUSE_MOVE,sliderMouseMove);
				_utility.appSprite.addEventListener(MouseEvent.MOUSE_UP,sliderMouseUp);
			}
		}
		
		/**
		 * 鼠标在滑块上弹起
		 */
		private function sliderMouseUp(event:MouseEvent=null):void{
			if(_utility.appSprite){
				_utility.appSprite.removeEventListener(MouseEvent.MOUSE_MOVE,sliderMouseMove);
				
				var movetoTimer:Number=startPoint.getTime()+(oldPointX+this.sliderThumbWidth*0.5-40)/this.sliderWidth*dincremental;
				var movetoDate:Date=new Date(movetoTimer);
				var integerDate:Date=new Date(movetoDate.getFullYear(),movetoDate.getMonth(),movetoDate.getDate());
				var currentPointX:Number=40+(integerDate.getTime()-startPoint.getTime())/this.dincremental*this.sliderWidth;
				this.setPoint(currentPointX,true);//使用特效
				
				_utility.appSprite.removeEventListener(MouseEvent.MOUSE_UP,sliderMouseUp);//移除监听
			}
		}
		
		//滑动块滑动
		private function sliderMouseMove(event:MouseEvent):void{
			if(!event.buttonDown){
				sliderMouseUp();
				return;
			}
			var pointX:Number = this.mouseX - (sliderThumbWidth * 0.5);
			setPoint(pointX);
		}
		
		//播放
		private function playButtonHander(event:MouseEvent = null):void{
			this.addEventListener(Event.ENTER_FRAME,playNextPoint);
			this.addChild(this.suspendButton);
			if(this.slider.x + 1 > this._width - sliderThumbWidth){
				this.setPoint(40);
			}
		}
		
		//暂停
		private function suspendButtonHander(event:MouseEvent = null):void{
			this.removeEventListener(Event.ENTER_FRAME , playNextPoint);
			this.addChild(this.playButton);
		}
		
		//执行播放
		private function playNextPoint(event:Event):void{
			var currentPoint:Number=this.slider.x+1;
			if(currentPoint >= this._width - sliderThumbWidth){
				this.setPoint(this._width - sliderThumbWidth);
				this.suspendButtonHander();
			}else{
				this.setPoint(currentPoint);
			}
		}
		
		public function doResize(width:Number , height:Number):void{
			if(!width || !height){
				return;
			}
			this._width = width;
			this._height = _height;
			this.sliderWidth = width-40;//轨迹条长度
			
			doDraw();//重画大小
		}
	}
}