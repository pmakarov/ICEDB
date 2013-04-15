package com.ads {
	
	public class Node{
	
	private var val:Object;
	public var neighborList:Array;
	private var childrenList:Array;
	private var currentNode:Node;
	private var parentList:Array;
	private var siblingList:Array;
	public var count:Number;
	public var isVisited:Boolean;
	public var hasSibling:Boolean;
	public var key:Number;
	private static var nodeList:Array = new Array();
	
	public function Node(nodeVal:Object) 
	{
		this.val = nodeVal;
		nodeList.push(this);
		currentNode = this;
		isVisited = false;
		hasSibling = false;
		count = 0;
		key= 0;
		
		neighborList = new Array();
		childrenList = new Array();
		parentList = new Array();
		siblingList = new Array();
		
	}

	public function getName():String 
	{
		return this.val.title;
	}
	public function getId():String
	{
		return this.val.id;
	}
	public function getNodeValue():Object 
	{
		return this.val;
	}
	
	public function addParent(parentNode:Node):void
	{
		for (var i:uint = 0; i < parentList.length; i++)
		{
			if(parentList[i].getNodeValue()==parentNode.getNodeValue())
			return;
		}
		parentList.push(parentNode);
	
	}
	
	public function addSibling(siblingNode:Node):void
	{
		
		for (var i:uint = 0; i < siblingList.length; i++)
		{
			if(siblingList[i].getNodeValue()==siblingNode.getNodeValue())
			return;
		}
		siblingList.push(siblingNode);
	
	}

	public static function getNodes():Array 
	{
		return nodeList;
	}
	
	public function containsNode(neighbor:Node) : int
	{
		var arrayData:Array = currentNode.getNeighbors();
		for (var i:uint = 0; i < arrayData.length; i++) 
		{
			if (arrayData[i] == neighbor) 
			{
				return i;
			}
		}
		return -1;
	}

	public function getNeighbors():Array 
	{
		return neighborList;
	}
	
	public function getKey():Number 
	{
		return this.key;
	}
		
	
	public function getAffected():Array 
	{
		return childrenList;
	}
	
	public function getChildren(children:Node):void
	{
		if(children.isVisited == true)
		return;
		
		children.isVisited = true;
     	var i:uint = 0;
     	while (i < children.count) 
		{
		 	getChildren(children.neighborList[i]);
         	i++;
     	}
		children.isVisited = false;
		addChildNode(children);    // create the list of affected children nodes (no duplicates)
 }
 
 
  
	public function getParent():Array
	{
		return parentList;
	}
	
	public function getSibling():void
	{
			
		for (var i:uint = 0; i < this.parentList.length; i++)
		{
			var temp:Array = new Array();
			temp = this.parentList[i].neighborList;
			
			
			for (var j:uint = 0; j < temp.length; j++)
			{
				if(temp[j].getNodeValue()!=this.getNodeValue()){
					trace(this.getName() + " is a sibling of  " + temp[j].getName());
					this.addSibling(temp[j]);
					this.hasSibling=true;
					temp[j].hasSibling=true;
					//trace(this.siblingList.length);
					
				}
				
			}
					
		}
	
	}
	public function getSiblingList():Array
	{
		return this.siblingList;
	}
	
	public function getChild():Array
	{		
		return this.neighborList;
	}
	
	public function addChildNode(child:Node):void
	{
		//trace("in addChild");
		for (var i:uint = 0; i < childrenList.length; i++)
		{
			if(childrenList[i].getNodeValue()==child.getNodeValue())
			return;
		}
		childrenList.push(child);
	}
  }
}