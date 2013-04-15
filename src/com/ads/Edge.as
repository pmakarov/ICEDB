package com.ads{
	
	public class Edge {
	private var edgeName:String;
	private var nodeOne:Node;
	private var nodeTwo:Node;
	private var weight:int;
	private var currentEdge:Edge;
	private static var edgeList:Array = new Array();
	
	public function Edge(from:Node, to:Node, edgeName:String, weight:int) 
	{
		
		//trace(edgeName + " with a weight of " + weight);
		this.nodeOne = from;
		this.nodeTwo = to;
		
		var edgeKey:String = from.getName() + to.getName();
		var edgePair:Array = new Array();
		
		this.weight = weight;
		
		edgePair.push(edgeKey);
		edgePair.push(this);
		edgeList.push(edgePair);
		
		this.edgeName = edgeName;
		currentEdge = this;
		
		
	}
	
	public function getName():String 
	{
		return edgeName;
	}
	
	public function getWeight():Number
	{
		return weight;
	}
	
	public function getFromNode():Node
	{
		return this.nodeOne;
	}
	
	public function getToNode():Node
	{
		return this.nodeTwo;
	}
	
	public function getDistance():Number {
		var dx:Number = 0;
		var dy:Number = 0;
		
		//dx = Math.abs(nodeOne.getX() - nodeTwo.getX());
		//dy = Math.abs(nodeOne.getY() - nodeTwo.getY());
		
		//return Math.round(Math.sqrt((dx*dx) + (dy*dy)));
		return 1;
	}
	
	public static function getEdgeList(node1:Node, node2:Node):Array 
	{
		var keyName:String = node1.getName() + node2.getName();
		var gettingEdge:Array = new Array();
		
		for (var i:uint = 0; i < edgeList.length; i++) 
		{
			var itemList:Array = new Array();
			itemList = edgeList[i];
			
			if (itemList[0] == keyName) 
			{
				gettingEdge.push(itemList[1]);
			}
		}
		return gettingEdge;
	}
	
	
	
	}
}
		
		
		
		