package UI.base
{
	import UI.bubblechart.LBubbleNode;
	
	import flash.utils.Dictionary;
	
	import utils.ThemeHander;

	public class BubbleNodePool
	{
		public function BubbleNodePool() {
		}
		private static var instance:BubbleNodePool;
		public static function getInstance():BubbleNodePool {
			if (instance == null) {
				instance = new BubbleNodePool();
			}
			return instance;
		}
		private var objPoolDict:Dictionary = new Dictionary();
		/**
		 * 向对象池中放入对象，以便重复利用
		 *
		 */
		public function push(oldObj:LBubbleNode):void {
			if (oldObj == null) {
				return ;
			}
			if (this.objPoolDict[oldObj.nodeID]== null) {
				this.objPoolDict[oldObj.nodeID] =oldObj;
			}
		}
		/**
		 * 从对象池中取出需要的对象
		 *
		 */
		public function pop(nodeID:String):LBubbleNode {
			if (this.objPoolDict[nodeID]) {
				return this.objPoolDict[nodeID];
			}
			var bubbleNode:LBubbleNode=new LBubbleNode();
			bubbleNode.nodeID=nodeID;
			bubbleNode.x=0;
			bubbleNode.y=0;
			push(bubbleNode);
			return bubbleNode;
		}

	}
}