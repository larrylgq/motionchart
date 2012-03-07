package utils
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.globalization.LocaleID;
	import flash.globalization.NumberFormatter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	  

	public class Utility extends EventDispatcher
	{
		public var appSprite:Sprite;//最上层容器
		  
		private static var __instance:Utility=null;
		private var nf:NumberFormatter = new NumberFormatter("en-US"); 
		public function Utility(){
			nf.negativeNumberFormat = 0; 
			nf.fractionalDigits = 2; 
			nf.trailingZeros = false;   
		}
		public static function getInstance():Utility
		{
			if(__instance == null)
			{
				__instance=new Utility();
			}
			return __instance;
		}  
		
		//嵌入字体
		[Embed(source="/assets/pf_ronda_seven.ttf", embedAsCFF="false", fontName="PF Ronda Seven", mimeType="application/x-font")]
		public var Ronda:Class;
		
		/**
		 * 生产一个TextField
		 * 宽度，高度，文字大小，字体颜色，对齐方式
		 */
		public function getTextField(
			width:Number=100,height:Number=25,size:Number=12,textColor:uint=0x000000,autoSize:String="center",font:String=null):TextField{
			var textField:TextField = new TextField();//添加纵轴标尺文本框
			textField.selectable=false;
			textField.textColor =textColor;
			textField.height=height;
			textField.width=width;
			textField.autoSize=autoSize;
			
			var format:TextFormat = new TextFormat();
			if(font){
				format.font=font;
			}else{
				format.font=ThemeHander.style["font"];
			}
			format.size = size;     
			textField.defaultTextFormat = format;
			return textField;
		}
		
		/**
		 * 将字符串转化成时间
		 * 年月日分隔符  -
		 * 时间分隔符   	:
		 */
		public function timeStrToDate(timeStr:String):Date {
			var tempArr:Array = timeStr.split(" ", 2);
			var dayStr:String=tempArr[0];
			if(dayStr){
				var dateArr:Array = dayStr.split("-", 3);
			}else{
				return null;
			}
			var hoursStr:String=tempArr[1];
			if(hoursStr){
			}else{
				hoursStr="00:00:00";
			}
			var timeArr:Array = hoursStr.split(":", 3);
			return new Date(Number(dateArr[0]), Number(dateArr[1])-1, Number(dateArr[2]), Number(timeArr[0]), Number(timeArr[1]), Number(timeArr[2]));
		}
		
		/**
		 * 将number类型格式化
		 * 单位  万  百万  千万 亿
		 */
		
		public function formatNumberToString(number:Number):String{
			if(1000000<number&&number<100000000){
				return nf.formatNumber(number*0.000001)+"M";
			}else if(number>=100000000){
				return nf.formatNumber(number*0.00000001)+"B";
			}else{
				return nf.formatNumber(number);
			}
		}
		
		/**
		 * 将number取整
		 */
		public function integerNumber(_array:Array):Number{
			var incrementalPrefix:Number=1.0; //倍数
			for(var i:int=0;i<_array.length;i++){
				var currentNumber:Number=_array[i];
				var numberString:String=currentNumber.toString();
				var indexPoint:int=numberString.indexOf(".");
				if(indexPoint>=1){
					var _incrementalPrefix:Number=Math.pow(10,numberString.length-indexPoint-1);
					if(_incrementalPrefix>incrementalPrefix){
						incrementalPrefix=_incrementalPrefix;
					}
				}
			}
			return incrementalPrefix;
		}
		
		/**
		 * 随机颜色值
		 */
		public function RandRGB():uint {
			
			return (Math.random() * 0xffffff + 0x000000);
			
			}
		}
}  