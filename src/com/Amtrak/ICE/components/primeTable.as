package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.MediaLoader;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;

	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class primeTable extends Sprite
	{
		private var rowCount:uint = 0;
		private var container:MovieClip;
		private var padding:Number    = 0;
		private var table:MovieClip;
		private var size:uint         = 80;
		private var cellHeight:Number = 30;
		private var cellWidth:Number = 700;
        private var bgColor:uint      = 0xD1D6D8;
        private var borderColor:uint  = 0xFFFFFF;
        private var borderSize:uint   = 0;
        private var cornerRadius:uint = 9;
        private var gutter:uint       = 0;
		private var distractors:Array;
		private var tableHeight:Number = 0;
		public function primeTable(list:Array):void
		{
			//drawHalfCirlce();
			//doDrawRect();
			//doDrawRoundRect();
			//refreshLayout();
			distractors = list;
			padding = 6;
			container = new MovieClip();
			addChild(container);
			
			if (list.length == 1)
			{
				trace("one");
				var wb:whiteBox = new whiteBox();
				container.addChild(wb);
				wb.width = cellWidth;
				wb.height = cellHeight;
			}
			else
			{
				var prevHeight:Number = 0;
				var rc:MovieClip;
				var newColorTransform:ColorTransform = new ColorTransform();
				for (var i:uint = 0; i < list.length; i++)
				{
					rc = list[i];
					newColorTransform.color  = (i % 2 != 0) ? 0xDFE2E7 : 0xFFFFFF ;
					//trace(list[i].height);
					if (i == 0)
					{
						var wt:whiteTop = new whiteTop();
						wt.transform.colorTransform = newColorTransform;
						wt.name = "cell";
						container.addChild(wt);
						wt.height = list[i].height+padding;
						wt.width = 750;
						rc.y  = wt.y + (wt.height - rc.height)/2;
						rc.x += padding;
						prevHeight += list[i].height + padding;
						rc.name = list[i].id;
						container.addChild(rc);
					}
					else if (i == list.length - 1)
					{
						var wbot:whiteBottom = new whiteBottom();
						wbot.transform.colorTransform = newColorTransform;
						wbot.name = "cell";
						container.addChild(wbot);
						wbot.height = list[i].height+padding;
						wbot.width = 750;
						wbot.y = prevHeight;
						rc.y = wbot.y + (wbot.height - rc.height)/2;
						rc.x += padding;
						rc.name = list[i].id;
						container.addChild(rc);
						prevHeight += list[i].height+padding;
					}
					
					else
					{
						var child:Shape = new Shape();
						child.graphics.beginFill(newColorTransform.color);
						//child.graphics.lineStyle(borderSize, borderColor);
						child.graphics.drawRect(0, 0, 750, list[i].height+padding);
						child.graphics.endFill();
						child.name = "cell";
						container.addChild(child);
						child.y = prevHeight;
						rc.name = list[i].id;
						container.addChild(rc);
						rc.y  = child.y + (child.height - rc.height)/2;
						rc.x += padding;
						prevHeight += list[i].height+padding;
					}
					rowCount++;
				}
				tableHeight = prevHeight;
			}
			
		
		}
		public function addItem(mc:MovieClip):void
		{
			trace("adding item to table");
			
		}
		public function addMediaLeft(ml:MediaLoader):void
		{
			
		    while (container.numChildren)
		    {
			    container.removeChildAt(0);
		    }
            
		    var wb:whiteBox = new whiteBox();
			this.container.addChild(wb);
			
			//trace(ml.loader.content.width + " : " + ml.loader.content.height);
			//trace("rowcount: " + rowCount);
			var tHeight:Number = this.container.height;
			ml.name = "media";
			this.container.addChild(ml);
			ml.x = 5;
			ml.y = 5;
			var base:Number = 16 + (6 * (rowCount-1));
			var offSet:Number = ((ml.loader.content.height+(base)-tableHeight)/rowCount);
			//var offSet:Number = (ml.loader.content.height + 10) * (padding / tableHeight);
			var newPadding:Number = offSet / (2 + rowCount);
			var prevHeight:Number = 0;
			
			var rc:MovieClip;
			var newColorTransform:ColorTransform = new ColorTransform();
			
			padding = offSet;
			//trace("**** " + tableHeight);
			for (var i:uint = 0; i < distractors.length; i++)
				{
					rc = distractors[i];
					newColorTransform.color  = (i % 2 != 0) ? 0xDFE2E7 : 0xFFFFFF ;
					//trace(list[i].height);
					if (i == 0)
					{
						var wt:whiteTop = new whiteTop();
						
						wt.transform.colorTransform = newColorTransform;
						wt.name = "cell";
						container.addChild(wt);
						wt.x = 265;
						//wt.height = distractors[i].height+padding;
						wt.height = distractors[i].height + padding;
						wt.width = 482;
						rc.y  = wt.y + (wt.height - rc.height)/2;
						rc.x += 270;
						prevHeight += distractors[i].height + padding;
						rc.name = distractors[i].id;
						container.addChild(rc);
					}
					else if (i == distractors.length - 1)
					{
						var wbot:whiteBottom = new whiteBottom();
						wbot.transform.colorTransform = newColorTransform;
						wbot.name = "cell";
						container.addChild(wbot);
						wbot.x = 265;
						wbot.height = distractors[i].height+padding;
						wbot.width = 482;
						wbot.y = prevHeight;
						rc.y = wbot.y + (wbot.height - rc.height)/2;
						rc.x += 270;
						rc.name = distractors[i].id;
						container.addChild(rc);
						
					}
					
					else
					{
						var child:Shape = new Shape();
						child.graphics.beginFill(newColorTransform.color);
						//child.graphics.lineStyle(borderSize, borderColor);
						child.graphics.drawRect(0, 0, 482, distractors[i].height+padding);
						child.graphics.endFill();
						child.name = "cell";
						container.addChild(child);
						child.x = 265;
						child.y = prevHeight;
						rc.name = distractors[i].id;
						container.addChild(rc);
						rc.y  = child.y + (child.height - rc.height)/2;
						rc.x += 270;
						prevHeight += distractors[i].height+padding;
					}
				}
			
			
			
			
			
			/*for (var i:uint = 0; i < distractors.length; i++)
			{
				
				container.addChild(distractors[i]);
				distractors[i].x += 270;
				//trace(i * offSet);
				//distractors[i].y = i * offSet;
				distractors[i].y = i * offSet;
				
			}*/
			
            /*for (var i:uint = 0; i < ln; i++)
			{
                child = container.getChildAt(i);
				if (child.name != "media")
				{
					//trace(child.name);
					child.x += 270;
					if (child.name != "cell" && child.name != "media")
					{
						child.visible = false;
						for (var j:uint = 1; j < distractors.length-1; j++)
						{
							
							distractors[j].y = j * 77.2 - distractors[j].height / 2;
							container.addChild(distractors[j]);
						}
						//prevHeight += child.height;
					}
					
					if (child.name == "cell")
					{
						child.visible = false;
						child.width = 482;
						child.x -= 5;
						
					}
				}
               
                lastChild = child;
            }*/
			
			ml.name = "media";
			this.container.addChild(ml);
			ml.x = 5;
			ml.y = 5;
			
			wb.width = 747;
			wb.height = 10 + ml.loader.content.height;
			
			//trace("height: " + wb.height);
		}
		public function set Color(color:uint):void
		{
			
		}
		public function get Height():Number
		{
			return this.container.height;
		}
		public function set Height(height:Number):void 
		{
			this.container.height = height;
		}
		public function get Width():Number 
		{
			return this.container.width;
		}
		public function set Width(width:Number):void 
		{
			this.container.width = width;
		}
		private function drawHalfCirlce():void 
		{
			var child:Shape = new Shape();
			child.graphics.beginFill(0xFF0000);
			var x:Number = 200;
			var y:Number  = 200;
			var r:Number = 100;
			var c1:Number=r * (Math.SQRT2 - 1);
			var c2:Number=r * Math.SQRT2 / 2;
			child.graphics.moveTo(x+r,y);
			child.graphics.curveTo(x+r,y+c1,x+c2,y+c2);
			child.graphics.curveTo(x+c1,y+r,x,y+r);
			child.graphics.curveTo(x-c1,y+r,x-c2,y+c2);
			child.graphics.curveTo(x-r,y+c1,x-r,y);
			// comment in for full circle
			/*g.curveTo(x-r,y-c1,x-c2,y-c2);
			g.curveTo(x-c1,y-r,x,y-r);
			g.curveTo(x+c1,y-r,x+c2,y-c2);
			g.curveTo(x+r,y-c1,x+r,y);*/
			addChild(child);
		}

		 private function doDrawRoundRect():void 
		 {
            var child:Shape = new Shape();
           /* child.graphics.beginFill(bgColor);
            child.graphics.lineStyle(borderSize, borderColor);
            child.graphics.drawRoundRect(0, 0, cellWidth, cellHeight, cornerRadius);
            child.graphics.endFill();*/
            addChild(child);
        }

        private function doDrawRect():void 
		{
            var child:Shape = new Shape();
            child.graphics.beginFill(0xFFFFFF);
            child.graphics.lineStyle(borderSize, borderColor);
            child.graphics.drawRect(5, 5, 235, 265);
            child.graphics.endFill();
            container.addChild(child);
        }
		 private function refreshLayout():void 
		 {
            var ln:uint = this.numChildren;
            var child:DisplayObject;
            var lastChild:DisplayObject = getChildAt(0);
            lastChild.x = gutter;
            lastChild.y = gutter;
            for (var i:uint = 1; i < ln; i++) {
                child = getChildAt(i);
                //child.x = gutter + lastChild.x + lastChild.width;
               // child.x = lastChild.x;
                //child.y = gutter + lastChild.y + lastChild.height;
                lastChild = child;
            }
        }
		
		public function setWidth(num:Number):void
		{
			for (var i:uint = 0; i < container.numChildren; i++)
			{
				var tmp:DisplayObject = container.getChildAt(i);
				if (tmp.name == "cell")
				{
					tmp.width = num;
				}
			}
		}


	}
	
}