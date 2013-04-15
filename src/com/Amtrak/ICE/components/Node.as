package com.Amtrak.ICE.components
{
	
	import flash.display.Sprite;
	
	public class Node extends Sprite
	{
		public var data:Object;
		public var children:Array;
		public var isBranch:Boolean;
		public var expanded:Boolean;
		public var parentNode:Object;
		
		public function Node()
		{
			isBranch = false;
			expanded = false;
			parentNode = new Object();
			children = new Array();
		}
		public function addNode(obj:Object):void 
		{
			children.push(obj);
		}
		public function removeNode(obj:Object):void 
		{
			for (var i:uint = 0; i < children.length; i++)
			{
				if (obj == children[i])
				{
					children.splice(obj, i);
					break;
				}
			}
		}
		/*public function set data(obj:Object):void 
		{
			this.data = obj;
		}*/
	}
}