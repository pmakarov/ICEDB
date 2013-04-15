package com.ads
{
	
	public class Graph
	{
		
		private var sourceNode:Node;
		private var eL:Array;
		private var partList:Array;
		private var path:Array;
		private var totalPartsList:Array;
		private var count:Number;
		private var currentWeight:int;
		public var logFile:String;
		
		public function Graph()
		{
			partList = new Array();
			path = new Array();
			totalPartsList = new Array();
			eL = new Array();
			count = 0;
			currentWeight = 100;
			sourceNode = null;
		}
		
		public function getPartList():Array
		{
			trace("getting PartList");
			return partList;
		}
		
		public function toArray():Array
		{
			return totalPartsList;
		}
		
		public function displayNodeList():void
		{
			for (var i:uint = 0; i < totalPartsList.length; i++)
			{
				trace(totalPartsList[i].getName());
			}
		}
		
		public function getPathList():Array
		{
			return path;
		}
		
		public function getNodeValue(node:Node):Object
		{
			return node.getNodeValue();
		}
		
		public function setNodeValue(node:Node, nodeValue:Boolean):void
		{
			node.isVisited = nodeValue;
		}
		
		public function addNode(nodeVal:Object):void
		{
			var node:Node = new Node(nodeVal);
			totalPartsList.push(node);
		}
		
		public function find(nodeName:String):Node
		{
			for (var i:uint = 0; i < totalPartsList.length; i++)
			{
				if (totalPartsList[i].getName() == nodeName)
				{
					return totalPartsList[i];
				}
			}
			return null;
		}
		
		public function getNodeById(id:String):Node
		{
			for (var i:uint = 0; i < totalPartsList.length; i++)
			{
				if (totalPartsList[i].getId() == id)
				{
					return totalPartsList[i];
				}
			}
			return null;
		}
		
		public function addEdge(parentNode:Node, childNode:Node, edgeName:String, weight:Number):void
		{
			var edgeOne:Edge = new Edge(parentNode, childNode, edgeName, weight);
			parentNode.neighborList.push(childNode);
			childNode.addParent(parentNode);
			parentNode.count++;
			eL.push(edgeOne);
		}
		
		public function getPath(node:Node):Array
		{
			node.getChildren(node);
			var temp:Array = new Array();
			temp = node.getAffected();
			temp.reverse();
			/*for(var i=0; i<temp.length; i++){
			   trace(i+1 + " " +temp[i].getName() + " : " + temp[i].getNodeValue());
			
			   }
			 */
			//path = temp;
			return temp;
		
		}
		
		public function Clear():void
		{
			for (var i:uint = 0; i < path.length; i++)
			{
				path[i].isVisited = false;
				//deadPath[i].isVisited = false;
				delete path[i];
					//delete deadpath[i];
			}
			count = 0;
			path = new Array();
		
		}
		
		public function setSource(node:Node):void
		{
			sourceNode = node;
			
			partList = sourceNode.getNeighbors();
		
		}
		
		public function pathFinder(start:Node, end:Node):Number
		{
			trace("IN F'N PATHFINDER");
			/*if(start.getName()==end.getName()){
			   return 0;
			   }
			 */
			var temp:Array = new Array();
			temp = start.getAffected();
			temp.reverse();
			trace(temp.length);
			for (var i:uint = 0; i < temp.length; i++)
			{
				trace(temp[i].getName());
				if (temp[i] == sourceNode)
				{
					trace("Hit the pump, you suck!");
						//return -1;
				}
				
				if (temp[i] == end)
				{
					trace("Stop the list at this point");
						//return 1;
				}
				
					//return -1;
				
			}
			
			return -999;
		
		}
		
		public function getChronological(node:Node):void
		{
		/*if(node.isVisited== true){
		   return;
		   }
		   if(!node.isVisited){
		   node.isVisited=true;
		
		   addPath(node);
		   count++;
		
		   var temp:Array = new Array();
		   temp = node.getEdgeList(node);
		   temp.sort(OrderByWeight);		// sort the weighted edges so that shortest edge will be processed first
		   for(var i = 0; i<temp.length; i++){
		   if(temp[i].nodeOne.isOn || temp[i].nodeOne.percentOpen!=0){// *** Use this if statement to stip flow path of nodes that will not receive flow
		   addPath(temp[i].nodeTwo);
		   }
		
		
		
		   }
		   if(path[count].isVisited == false){
		   getChronological(path[count]);
		   }
		   else
		   return;
		
		   }
		 */
		
		}
		
		public function addPath(node:Node):void
		{
			for (var i:uint = 0; i < path.length; i++)
			{
				if (path[i].getName() == node.getName())
				{ //***ensure no duplicate entries
					return;
				}
			}
			
			path.push(node);
		}
		
		public function OrderByWeight(edge1:Edge, edge2:Edge):int
		{
			var length1:Number = edge1.getWeight();
			var length2:Number = edge2.getWeight();
			if (length1 < length2)
			{
				return -1;
			}
			else if (length1 > length2)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		
		}
		
		public function parentList(sourceNode:Node):void
		{
			
			sourceNode.getParent();
		}
		
		public function siblingList(sourceNode:Node):void
		{
			
			sourceNode.getSibling();
		}
		
		public function childrenList(sourceNode:Node):Array
		{
			var temp:Array = new Array();
			temp = sourceNode.getChild();
			return temp;
		}
		
		public function cleanUp(messy:Array):Array
		{
			var temp:Array = new Array();
			for (var i:uint = 0; i < messy.length; i++)
			{
				if (messy[i].getName() != undefined)
				{
					temp.push(messy[i]);
				}
			}
			
			return temp;
		}
		
		public function getKey(node:Node):Number
		{
			var key:Number = node.getKey();
			return key;
		}
		
		public function useKey(number:Number):Node
		{
			for (var i:uint = 0; i < partList.length; i++)
			{
				if (number == partList[i].key)
				{
					return partList[i];
				}
			}
			return null;
		}
		
		public function Relationship(firstNode:Node, secondNode:Node):int
		{
			trace("-------------------Finding Relationship-----------------------------");
			//trace(firstNode.getName() + " compared to " + secondNode.getName()+ " ?");
			//trace("Parents List of :" + firstNode.getName());
			if (firstNode.getName() == secondNode.getName())
			{
				//trace(firstNode.getName() + " is itself, return 0");
				return 0;
			}
			siblingList(firstNode);
			var sL:Array = firstNode.getSiblingList();
			//trace(sL.length + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			if (sL.length > 0)
			{
				for (var x:uint = 0; x < sL.length; x++)
				{
					//trace("getting siblings of : " + firstNode.getName());
					if (secondNode.getName() == sL[x].getName())
					{
						//trace(secondNode.getName()+ " is a sibling of " + firstNode.getName());
						return 0;
					}
				}
					//delete sL;
			}
			else
			{
				//delete sL;
				//trace(firstNode.getName() + " has no siblings");
			}
			
			var temp:Array = new Array();
			temp = firstNode.getParent();
			for (var i:uint = 0; i < temp.length; i++)
			{
				if (secondNode.getName() == temp[i].getName())
				{
					//trace(firstNode.getName() + " is a child of " + secondNode.getName() + " value=1");
					return 1;
				}
			}
			
			//delete temp;
			
			var temp2:Array = new Array();
			temp2 = secondNode.getParent();
			for (var j:uint = 0; j < temp2.length; j++)
			{
				if (firstNode.getName() == temp2[j].getName())
				{
					//trace(firstNode.getName() + " is a parent of " + secondNode.getName() + " value=-1");
					return -1;
				}
			}
			
			//delete temp;
			//return comp(firstNode,secondNode);
			return 8;
		
		}
		
		public function comp(nodeA:Node, nodeB:Node):Number
		{
			/*var x:Number = -1;
			   nodeA.getChildren(nodeA);
			   var temp:Array = new Array();
			   temp = partList;
			
			   //temp = nodeA.getAffected();
			   //temp.reverse();
			   trace("Listing Full Path of " + nodeA.getName());
			   for(var i=0; i<temp.length; i++){
			   trace(temp[i].getName());
			   if(temp[i]== sourceNode && nodeA.getName()!=sourceNode.getName()){
			   //We know the nodeA is not a parent
			   trace("Hit the pump!!!! " + nodeA.getName() + " is not a parent of " + nodeB.getName());
			   return -1;
			   }
			
			   if(temp[i].getName()==nodeB.getName()){
			   //nodeA is a parent of nodeB
			   trace(nodeA.getName() + " is a parent of " + nodeB.getName());
			   return -1;
			   }
			
			   }
			
			
			 */
			trace(nodeA.getName() + " compared to " + nodeB.getName() + " ? ");
			if (nodeA.getKey() > nodeB.getKey())
			{
				trace(nodeA.getName() + " is a parent of " + nodeB.getName());
				return 1;
			}
			
			else
			{
				trace(nodeA.getName() + " is NOT parent of " + nodeB.getName());
				
				return -1;
			}
		
			//return 9;
		
		}
		
		public function shortestPath(source:Node, destination:Node):void
		{
			/* 1. Create a distance list, a previous vertex list, a visited list, and a current vertex.
			   2. All the values in the distance list are set to infinity except the starting vertex which is set to zero.
			   3. All values in visited list are set to false.
			   4. All values in the previous vertex list are set to a special value signifying that they are undefined, such as null.
			   5. Current vertex is set as the starting vertex.
			   6. Mark the current vertex as visited.
			   7. Update distance and previous lists based on those vertices which can be immediately reached from the current vertex.
			   8. Update the current vertex to the unvisited vertex that can be reached by the shortest path from the starting vertex.
			   9. Repeat (from step 6) until all nodes are visited.
			   setup the openlist (an array)
			   setup the closedlist (an array)
			   push the starting node to the open list (node is a square in our grid)
			   while the openlist is not empty
			   Look for the lowest 'f' cost node on the open list and pop from the openlist and name it 'current'
			   if the current node is the goal then we found the solution, exit the while loop
			   for each of the node adjacent to the current node (8 is we allow diagonal movement)
			   set the parent of this adjacent to 'current'
			   if a node with the same position as the adjacent node is in the open list /
			   and its 'f' is lower than the node adjacent
			   then skip current adjacent node
			   if a node with the same position is in closedlist /
			   and its 'f' is lower
			   then skip current adjacent node
			   otherwise push the current node to the open list
			   remove occurences of adjacent node from OPEN and CLOSED list
			   Add adjacent node to the OPEN list
			   end for
			   add the current node to the closed list
			   end while
			 */
			
			var dist:Number = 0;
			var origin:Node = source;
			
			// Creating our Open and Closed Lists
			var closedList:Array = new Array();
			var openList:Array = new Array();
			// Adding our starting point to Open List
			openList.push(origin);
			// Loop while openList contains some data.
			while (openList.length != 0)
			{
				
				// Loop while openList contains some data.
				
				var n:Node = Node(openList.shift());
				// Check if node is Destination
				if (n == destination)
				{
					closedList.push(destination);
					trace("Closed!");
					finalPath(closedList, source, destination);
					break;
				}
				openList = remove(n, openList);
				if (closedList.length > 0)
				{
					if ((contains(n, closedList)) != -1)
						continue;
				}
				// Add current node to closedList
				closedList.push(n);
				// Store n's neighbors in array
				var neighbors:Array = n.getNeighbors();
				var nLength:Number = neighbors.length;
				
				neighbors.reverse();
				// Add each neighbor to the end of our openList
				
				for (var i:int = 0; i < nLength; i++)
				{
					
					openList.unshift(neighbors[i]);
					
				}
				
				trace(openList[0].getName() + " is the top of the queue");
				
			} //end while
		}
		
		public function finalPath(input:Array, origin:Node, destination:Node):void
		{
			var finalAnswer:Array = new Array();
			for (var i:uint = 0; i < input.length; i++)
			{
				var node1:Node = input[i];
				var node2:Node = null;
				for (var j:int = i + 1; j < input.length; j++)
				{
					if (node1.containsNode(input[j]) != -1)
					{
						node2 = input[j];
						i = j - 1;
					}
				}
				if (node2 != null)
				{
					finalAnswer.push(node2);
					if (node2 == destination)
					{
						break;
					}
				}
			}
			finalAnswer.unshift(origin);
			
			for (var t:int = 0; t < finalAnswer.length; t++)
			{
				trace(finalAnswer[t].getName());
			}
		
		}
		
		public function findShortestEdgeFrom(start:Node):Node
		{

			var shortestEdge:Edge = null;
			for (var i:int = 0; i < eL.length; i++)
			{
				if (eL[i].getFromNode().getName() == start.getName())
				{
					
					if (eL[i].getWeight() < currentWeight)
					{
						currentWeight = eL[i].getWeight();
						shortestEdge = eL[i];
							//trace("found: "+eL[i].getName()+ " with a weight of "+eL[i].getWeight());
					}
						//return eL[i];
				}
			}
			//return null;
			currentWeight = 100;
			if (shortestEdge != null)
			{
				trace(shortestEdge.getName() + " has a weight of: " + shortestEdge.getWeight());
				return shortestEdge.getToNode();
			}
			else
			{
				trace(start.getName() + " does not have any edges");
				return null;
			}
		
		}
		
		public function findShortestEdgeTo(destination:Node):Node
		{
			var shortestEdge:Edge = null;
			for (var i:int = 0; i < eL.length; i++)
			{
				if (eL[i].getToNode().getName() == destination.getName())
				{
					
					if (eL[i].getWeight() < currentWeight)
					{
						currentWeight = eL[i].getWeight();
						shortestEdge = eL[i];
						trace("found: " + eL[i].getName() + " with a weight of " + eL[i].getWeight());
					}
					
				}
			}
			currentWeight = 100;
			if (shortestEdge != null)
			{
				trace(shortestEdge.getName() + " has a weight of: " + shortestEdge.getWeight());
				return shortestEdge.getFromNode();
			}
			else
			{
				trace(destination.getName() + " does not have any edges");
				return null;
			}
		
		}
		
		/*public function order(a, b):Number {
		   //trace(a.getWeight() + " compared to " + b.getWeight());
		   //var name1:String = a.split(":")[0];
		   //for(var i=0; i<eL.length; i++){
		   //if(eL[i].getToNode().getName()== destination.getName()){
		   //var name2:String = b.split(":")[0];
		
		   if (a.getWeight()<b.getWeight()) {
		   return -1;
		   }
		   else if (a.getWeight()>b.getWeight())
		   {
		   return 1;
		   }
		   else {
		   return 0;
		   }
		   }
		 */
		public function Dijkstra(source:Node, destination:Node):void
		{
			for (var i:int = 0; i < eL.length; i++)
			{
				trace(eL[i].getName() + " has a weight of " + eL[i].getWeight());
			}
		}
		
		public function contains(input:Node, arrayData:Array):int
		{
			for (var i:int = 0; i < arrayData.length; i++)
			{
				if (arrayData[i] == input)
				{
					return i;
				}
			}
			return -1;
		}
		
		public function remove(num:Node, input:Array):Array
		{
			var final:Array = new Array();
			for (var i:int = 0; i < input.length; i++)
			{
				if (input[i] != num)
				{
					final.push(input[i]);
				}
			}
			return final;
		}
		
		
	
	}
}