package com.Amtrak.ICE.components
{
	import fl.containers.ScrollPane;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.xml.XMLNode;
	//import mx.events.*;
	
	public class Tree extends Sprite
	{
		[Bindable(event="onXMLChange")]
		private var _dataSource:XML;
		private var _vSpace:uint;
		private var _hSpace:uint;
		private var treeTextFormat:TextFormat;
		private var treeTextFormat2:TextFormat;
		private var sl:ScrollPane;
		private var _selectedNode:MovieClip;
		private var parentClip:MovieClip;
		private var _childrenList:Array = [];
		private var _tree:Array = [];
		private var counter:int = 0;
		
		
		
		public function Tree()
		{
			_dataSource = null;
			_selectedNode = null;
			parentClip = null;
			_vSpace = 0;
			_hSpace = 10;
			treeTextFormat = new TextFormat();
			treeTextFormat.font = "Verdana";
			treeTextFormat.color = 0xCFCFCF;
            treeTextFormat.size = 11;
			treeTextFormat.bold = true;
			
			treeTextFormat2 = new TextFormat();
			treeTextFormat2.font = "Verdana";
			treeTextFormat2.color = 0xFFFFFF;
            treeTextFormat2.size = 11;
			treeTextFormat2.bold = true;
			
			sl = new ScrollPane();
			sl.width = 215;
			sl.height = 662;
			
			var newSkinClip:MovieClip = new MovieClip();
			newSkinClip.graphics.clear();
			newSkinClip.graphics.beginFill(uint(0x000000), 0.6);
			newSkinClip.graphics.drawRect(0,0,272.0, 191.0);
			newSkinClip.graphics.endFill();
			sl.setStyle( "skin", newSkinClip ); //ScrollPane_upSkin
			sl.setStyle( "upSkin", newSkinClip );
			addChild(sl);
			this.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onXMLChange);
		}
		private function traceTree(arr:Array, str:String):void
		{
			str += "\t";
			for(var i:uint = 0; i < arr.length; i++)
			{
				
				trace( str + arr[i].data.title);
				if (arr[i].children.length > 0)
				{
					
					traceTree(arr[i].children, str);
				}
			}
			
			return;
		}
		
		private function buildTreeUI(arr:Array, mc:MovieClip):void 
		{
			
			for(var i:uint = 0; i < arr.length; i++)
			{
				
				var nodeClip:MovieClip = new MovieClip();
				var nodeText:TextField = new TextField();
				nodeText.autoSize = TextFieldAutoSize.LEFT;
				nodeText.background = false; //use true for doing generic labels
				nodeText.border = false;      // ** same
				nodeText.borderColor = 0x00CCFF;
				nodeText.embedFonts = true;
				nodeText.antiAliasType = "advanced";
				nodeText.gridFitType = GridFitType.PIXEL;
				nodeText.sharpness = -200;
				nodeText.wordWrap = false;
				nodeText.defaultTextFormat = treeTextFormat;
				nodeText.selectable = false;
				nodeText.text = arr[i].data.title;
				nodeText.x =  15;
				nodeText.name = "label";
				nodeClip.label = arr[i].data.title;
				nodeClip.node = arr[i];
				var lateral:MovieClip = new MovieClip();
				lateral.name = "lateral";
				if (arr[i].isBranch)
				{
					var fci:MovieClip 
					if (arr[i].expanded)
					{
						fci = new folderOpenIcon();
					}
					else
					{
						fci = new folderClosedIcon();
					}
					fci.name = "icon";
					lateral.addChild(fci);
					lateral.addChild(nodeText);
					lateral.addEventListener(MouseEvent.CLICK, handleBranchClick);
					
				}
				else
				{
					var fi:fileIcon = new fileIcon();
					lateral.addChild(fi);
					lateral.addChild(nodeText);
					lateral.addEventListener(MouseEvent.CLICK, handleLeafClick);
				}
				lateral.buttonMode = true;
				lateral.mouseChildren = false;	
				nodeClip.addChild(lateral);
				nodeClip.x = _hSpace *(arr[i].data.level-1);
				nodeClip.y = _vSpace;
				_vSpace += 20;
				mc.addChild(nodeClip);
				if (arr[i].children.length > 0 && arr[i].expanded)
				{
					buildTreeUI(arr[i].children, mc);
				}
			}
			
			return;
		}
		
		private function buildInitialTreeUI(arr:Array):void 
		{
			
			for(var i:uint = 0; i < arr.length; i++)
			{
				
				var nodeClip:MovieClip = new MovieClip();
				var nodeText:TextField = new TextField();
				nodeText.autoSize = TextFieldAutoSize.LEFT;
				nodeText.background = false; //use true for doing generic labels
				nodeText.border = false;      // ** same
				nodeText.borderColor = 0x00CCFF;
				nodeText.embedFonts = true;
				nodeText.antiAliasType = "advanced";
				nodeText.gridFitType = GridFitType.PIXEL;
				nodeText.sharpness = -200;
				nodeText.wordWrap = false;
				nodeText.defaultTextFormat = treeTextFormat;
				nodeText.selectable = false;
				nodeText.text = arr[i].data.title;
				nodeText.x =  15;
				nodeText.name = "label";
				nodeClip.label = arr[i].data.title;
				nodeClip.node = arr[i];
				nodeClip.node.parentNode = parentClip;
				var lateral:MovieClip = new MovieClip();
				lateral.name = "lateral";
				if (arr[i].isBranch)
				{
					var fci:folderClosedIcon = new folderClosedIcon();
					fci.name = "icon";
					lateral.addChild(fci);
					lateral.addChild(nodeText);
					lateral.addEventListener(MouseEvent.CLICK, handleBranchClick);
					
				}
				else
				{
					var fi:fileIcon = new fileIcon();
					lateral.addChild(fi);
					lateral.addChild(nodeText);
					lateral.addEventListener(MouseEvent.CLICK, handleLeafClick);
				}
				lateral.buttonMode = true;
				lateral.mouseChildren = false;	
				nodeClip.addChild(lateral);
				nodeClip.x = _hSpace * (arr[i].data.level-1);
				nodeClip.y = _vSpace;
				_vSpace += 20;
					if (arr[i].children.length > 0)
					{
						parentClip = nodeClip;
						buildInitialTreeUI(arr[i].children);
					}
					else if(!arr[i].isBranch)
					{
						_childrenList.push(nodeClip);
					}
			}
			
			return;
		}
		
		private function onXMLChange(e:PropertyChangeEvent):void
		{
			var count:uint = 0;
			var treePanel:MovieClip = new MovieClip();
			//trace(_dataSource[0].children()[1].children()[1]);
			buildDataTree(_dataSource[0].children()[1].children()[1], _tree, counter);
			buildInitialTreeUI(_tree);
			//reset _vSpace
			_vSpace = 0;
			buildTreeUI(_tree, treePanel);
			sl.source = treePanel;
			sl.update();
		}
		
		private function getChildrenByLevel(num:uint):Array
		{
			var tmp:Array = new Array();
			for (var i:uint = 0; i < _tree.length; i++)
			{
				if (_tree[i].data.level == num)
				{
					tmp.push(_tree[i]);
				}
			}
			return tmp;
		}
		
		private function buildDataTree(xml:XML, arr:Array, counter:int):void
        {
			var nodeList:XMLList = xml.node;
			var count:Number = 0;
			counter++;
			for each(var n:XML in nodeList)
			{
				var node:Node = new Node();
				node.data = new Object();
				node.data.title = n.title.toString();
				node.data.index = count;
				node.data.level = counter;
				arr.push(node);
				
				//if(n.hasOwnProperty("node-collection") && !n.hasOwnProperty("file"))
				if(n.hasOwnProperty("node-collection"))
				{
					node.isBranch = true;
					node.expanded = false;
					buildDataTree(n["node-collection"][0], node.children, counter);
				}
				count++;
			}
            return;
        }

		public function set dataSource(value:XML):void
		{
				if (value == this._dataSource) 
				{
					trace("no change");
					return; // don't want to dispatch a change if it didn't change
				}

			    var oldValue:XML = value;
				this._dataSource = value;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "foo", oldValue, value));
		}
		
		private function getNodeDepth(node:XML, currentDepth:Number):Number 
		{
			if(node.parent() != undefined){
				currentDepth = getNodeDepth(node.parent(), currentDepth + 1);
			}
			
			return currentDepth;	
		}
		
		private function handleLeafClick(e:MouseEvent):void
		{
			var currentClip:MovieClip = e.target.parent as MovieClip;
			selectNode(currentClip);	
		}
		
		private function handleBranchClick(e:MouseEvent):void
		{
			var currentClip:MovieClip = e.target.parent as MovieClip;
			var tree:MovieClip = sl.content as MovieClip;
			
			tree = new MovieClip();
			_vSpace = 0;
			
			if (!currentClip.node.expanded)
			{
				currentClip.node.expanded = true;
			}
			else
			{
				currentClip.node.expanded = false;
			}

			var tmp:MovieClip = _selectedNode;
			
			buildTreeUI(_tree, tree);
			sl.source = tree;
			sl.update();
			
			highLightLeaf(tmp);
			
		}

		public function selectNodeByIndex(num:uint):void
		{
			if (_childrenList[num] == _selectedNode)
			return;
			
			_selectedNode = _childrenList[num];
			
			if (_selectedNode.node.parentNode != null)
			{	
				_selectedNode.node.parentNode.node.expanded = true;
				//*Hack LINE**
				if (_selectedNode.node.parentNode.node.parentNode)
				{
					_selectedNode.node.parentNode.node.parentNode.node.expanded = true;
				}
				/* TODO : Write a recursive function that traverses the node parent hierarch
				 * and sets the node property expanded to true up to the root
				 */
				//_selectedNode.node.expanded = true;
				var tmp:MovieClip = _selectedNode;
				var tree:MovieClip = new MovieClip();
				_vSpace = 0;
				buildTreeUI(_tree, tree);
				sl.source = tree;
				sl.update();
			}
			
			highLightLeaf(_selectedNode);
		}
		
		public function selectNode(sn:MovieClip):void
		{
			if (sn == _selectedNode)
			return;

			_selectedNode = sn;
			highLightLeaf(_selectedNode);
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		private function highLightLeaf(node:MovieClip):void
		{
			var tree:MovieClip = sl.content as MovieClip;
			var mc:MovieClip;
			for (var i:uint = 0; i < tree.numChildren; i++)
			{
				mc = tree.getChildAt(i) as MovieClip;
				var lateral:MovieClip = mc.getChildByName("lateral") as MovieClip;
				var text:TextField = lateral.getChildByName("label") as TextField;
				if (node.node == mc.node)
				{
					text.border = true;
					text.setTextFormat(treeTextFormat2);
				}
				else
				{
					text.border = false;
					text.setTextFormat(treeTextFormat);
				}
			}
			
		}
		
		public function get selectedNode():MovieClip
		{
			return _selectedNode;
		}
		public function get selectedIndex():uint
		{
			var count:int = 0;
			if (_selectedNode == null)
			{
				return 0;
			}
			
			else
			{
				for (var i:uint = 0; i < _childrenList.length; i++)
				{
					if (_selectedNode.node == _childrenList[i].node)
					{
						return i;
					}
				}
			}
			
			return 0;
		}
		public function get selectedLabel():String
		{
			if (_selectedNode == null)
			{
				return "";
			}
			else
			{
				return _selectedNode.label;
			}	
		}
		
	}
}