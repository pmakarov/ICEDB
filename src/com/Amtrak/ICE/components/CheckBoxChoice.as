package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.FontManager;
	import fl.controls.RadioButton;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class  CheckBoxChoice extends MovieClip
	{
		private var checkChoiceContainer:MovieClip;
		private var checkbox:myPrimeCheckBox;
		private var choiceText:TextField;
		private var selected:Boolean;
		public var id:String;
		public var valueId:String;
		
		public function CheckBoxChoice(text:String = ""):void
		{
			selected = false; 
			id = "";
			valueId = "";
			
			checkChoiceContainer = new MovieClip();
			
			checkbox = new myPrimeCheckBox();
			//radioButton.addEventListener(MouseEvent.ROLL_OVER, doButtonOver);
			//radioButton.addEventListener(MouseEvent.ROLL_OUT, doButtonOut);
			//radioButton.addEventListener(MouseEvent.CLICK, doButtonClick);
			checkChoiceContainer.addChild(checkbox);
		    checkbox.scaleX = checkbox.scaleY = .9;
			choiceText = new TextField();
			choiceText.autoSize = TextFieldAutoSize.LEFT;
            //choiceText.background = true; //use true for doing generic labels
            choiceText.border = false;      // ** same
			choiceText.embedFonts = true;
			choiceText.antiAliasType = "advanced";
			choiceText.sharpness = -300;
			choiceText.thickness = -50;
			choiceText.wordWrap = true;
			choiceText.width = 700;
			
            choiceText.defaultTextFormat = FontManager.choiceTextFormatBlack;
			choiceText.htmlText = text;
			checkChoiceContainer.addChild(choiceText);
			choiceText.x = checkbox.x + checkbox.width+4;
			choiceText.y = 0;
			checkbox.y = (choiceText.textHeight - checkbox.height)/2 + 4;
			
			//trace(choiceText.height + " is teh height ");
			//radioChoiceContainer.height = choiceText.height + 4;
			//radioChoiceContainer.width
			addChild(checkChoiceContainer);
		}
		
		public function doButtonOver(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("OVER");
		}
		public function doButtonOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("OUT");
		}
		public function doButtonClick(e:MouseEvent):void
		{
			
			var button:MovieClip = e.target as MovieClip;
			if (button.currentLabel == "UP")
			{
				button.gotoAndStop("OVER");
				selected = true;
			}
			else
			{
				button.gotoAndStop("UP");
				selected = false;
			}
		}
		public function get State():String
		{
			return checkbox.currentLabel;
		}
		public function set State(state:String):void
		{
			this.checkbox.gotoAndStop(state);
			if (state == "OVER")
			{
				selected = true;
			}
			else
			{
				selected = false;
			}
		}
		public function get Selected():Boolean
		{
			return this.selected;
		}
		public function set Selected(b:Boolean):void 
		{
			this.selected = b;
		}
		public function get RadioButtonInstance():MovieClip
		{
			return this.checkbox;
		}
		public function set ChoiceTextLength(num:Number):void
		{
			this.choiceText.width = num;
			checkbox.y = (choiceText.textHeight - checkbox.height)/2 + 4;
		}
		public function get Data():String
		{
			//data = choiceText.text;
			return choiceText.text;
		}
		public function set Data(str:String):void
		{
			this.choiceText.text = str;
		}
	}
	
}