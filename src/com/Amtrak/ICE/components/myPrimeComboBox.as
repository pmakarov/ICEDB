package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.FontManager;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class myPrimeComboBox extends MovieClip
	{
		
		private var container:MovieClip;
		private var arrow:myPrimeComboBoxListButton;
		private var selectionList:Array;
		private var clicked:Boolean;
		private var selectedField:TextField;
		private var selectionFormat:TextFormat;
		private var dropDownList:MovieClip;
		public var selectedItem:Object;
		
		public function myPrimeComboBox():void
		{
			clicked = false;
			container = new MovieClip();
			addChild(container);
			
			var wb:whiteBox = new whiteBox();
			wb.width = 60;
			wb.height = 26;
			
			var boundingBox:MovieClip = new MovieClip();
			boundingBox.graphics.lineStyle(4, 0x777777, .5);
			boundingBox.graphics.drawRoundRect(wb.x, wb.y, wb.width - .1, wb.height -.1, 10, 10);
			container.addChild(boundingBox);
			container.addChild(wb);
			arrow = new myPrimeComboBoxListButton();
			arrow.addEventListener(MouseEvent.MOUSE_DOWN, handleArrowClick);
			container.addChild(arrow);
			
			selectionFormat= new TextFormat();
            selectionFormat.font = FontManager.segoe.fontName;
            selectionFormat.color = 0x000000;
            selectionFormat.size = 14;
            selectionFormat.underline = false;
			selectedField = new TextField();
			selectedField.autoSize = TextFieldAutoSize.LEFT;
			selectedField.background = false; //use true for doing generic labels
			selectedField.border = false;      // ** same
			selectedField.embedFonts = true;
			selectedField.antiAliasType = "advanced";
			selectedField.wordWrap = true;
			selectedField.width = 30;
			selectedField.sharpness = -300;
			selectedField.thickness = -50;
			selectedField.defaultTextFormat = selectionFormat;
			selectedField.text = "...";
			container.addChild(selectedField);
			selectedField.x = arrow.x + arrow.width + 6;
			
			selectionList = new Array();
			
			dropDownList = new MovieClip();
			dropDownList.name = "list";
			//container.addChild(dropDownList);
			//dropDownList.x = 0;
			//dropDownList.y = arrow.y + arrow.height;
			
		}
		public function addItem(obj:Object):void
		{
			selectionList.push(obj);
		}
		
		public function handleArrowClick(e:MouseEvent):void 
		{
			if (selectionList.length)
			{
				displayList();
				clicked = true;
			}
			
		}
		public function displayList():void
		{
			var spacer:Number = 2;
			if (container.parent.parent.parent.getChildByName("list") != null)
			{
				container.parent.parent.parent.removeChild(container.parent.parent.parent.getChildByName("list"));
				dropDownList.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			}
			var blah:MovieClip = new MovieClip();
			dropDownList.addChild(blah);
			for (var i:uint = 0; i < selectionList.length; i++)
			{
				//trace(selectionList[i].label + " : " + selectionList[i].data);
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.background = true; //use true for doing generic labels
				if (selectionList[i].label == selectedField.text)
				{
					tf.backgroundColor = 0xA4B0B9;
				}
				else
				{
				tf.backgroundColor = 0xDBDDDF;
				}
				tf.border = false;      // ** same
				tf.embedFonts = true;
				tf.antiAliasType = "advanced";
				tf.wordWrap = true;
				tf.sharpness = -300;
				tf.thickness = -50;
				tf.mouseEnabled = true;
				tf.selectable = false;
				tf.defaultTextFormat = selectionFormat;
				tf.text = selectionList[i].label;
				tf.width = tf.textWidth + 10;
				tf.x += spacer;
				tf.y = 4;
				tf.name = "text";
				tf.addEventListener(MouseEvent.MOUSE_OVER, handleSelectionRollOver);
				tf.addEventListener(MouseEvent.MOUSE_OUT, handleSelectionRollOut);
				tf.addEventListener(MouseEvent.CLICK, handleSelectionClick);
				dropDownList.addChild(tf);
				spacer += tf.width;
			}
			
			
			blah.graphics.beginFill(0xDBDDDF);
			blah.graphics.drawRect(0, 0, spacer+2, 30);
			blah.graphics.endFill();
			
			//blah.addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
			//blah.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
			dropDownList.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
			blah.mouseChildren = false;
			container.parent.parent.parent.addChild(dropDownList);
			dropDownList.x = 5;
			dropDownList.y = container.parent.parent.y + 30;
		}
		public function handleSelectionRollOver(e:MouseEvent):void
		{
			if (TextField(e.currentTarget).text != selectedField.text)
			{
				TextField(e.currentTarget).backgroundColor = 0xA7BA89;
			}
		}
		public function handleSelectionRollOut(e:MouseEvent):void
		{
			if (TextField(e.currentTarget).text != selectedField.text)
			{
				TextField(e.currentTarget).backgroundColor = 0xDBDDDF;
			}
		}
		public function handleSelectionClick(e:MouseEvent):void 
		{
			for (var i:uint = 0; i < dropDownList.numChildren; i++)
			{
				
				if (dropDownList.getChildAt(i).name == "text")
				{
					TextField(dropDownList.getChildAt(i)).backgroundColor = 0xDBDDDF;
				}
			}
			TextField(e.currentTarget).backgroundColor = 0xA4B0B9;
			if (selectedField.text == "...")
			{
				dispatchEvent(new Event("SELECTION_COMPLETE"));
			}
			selectedField.text = TextField(e.currentTarget).text;
			
			for (var j:uint = 0; j < selectionList.length; j++)
			{
				//trace("sl " + selectionList[j].label);
				if (TextField(e.currentTarget).text == selectionList[j].label)
				{
					selectedItem = selectionList[j];
					
				}
			}
			
		}
		public function hideList():void
		{
			//container.parent.parent.parent.removeChild(container.parent.parent.parent.getChildByName("list"));
		}
		public function handleMouseOver(e:MouseEvent):void 
		{
			
		}
		public function handleMouseOut(e:MouseEvent):void
		{
			dropDownList.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			container.parent.parent.parent.removeChild(container.parent.parent.parent.getChildByName("list"));
			
		}		
		
		public function set Selected(b:Boolean):void 
		{
			
		}
		
		
	}
	
}