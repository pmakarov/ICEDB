package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.FontManager;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class  RadioChoice extends  MovieClip
	{
		private var radioChoiceContainer:MovieClip;
		private var radioButton:amtrakRadioButton;
		private var choiceText:TextField;
		private var selected:Boolean;
		public var id:String;
		public var valueId:String;
		public var data:String;
				
		public function RadioChoice(text:String = ""):void
		{
			selected = false; 
			id = "";
			valueId = "";
			data = "";
				
			radioChoiceContainer = new MovieClip();
			
			radioButton = new amtrakRadioButton();
			radioButton.addEventListener(MouseEvent.ROLL_OVER, doButtonOver);
			radioButton.addEventListener(MouseEvent.ROLL_OUT, doButtonOut);
			radioButton.addEventListener(MouseEvent.CLICK, doButtonClick);
			
			radioChoiceContainer.addChild(radioButton);
			//radioButton.scaleX = radioButton.scaleY = .9;
			
			
			choiceText = new TextField();
			choiceText.autoSize = TextFieldAutoSize.LEFT;
           // choiceText.background = true; //use true for doing generic labels
            choiceText.border = false;      // ** same
			choiceText.embedFonts = true;
			choiceText.antiAliasType = "advanced";
			choiceText.sharpness = -300;
			choiceText.thickness = -50;
			choiceText.wordWrap = true;
			choiceText.width = 360;
			choiceText.selectable = false;
			choiceText.mouseEnabled = false;
			
            choiceText.defaultTextFormat = FontManager.choiceTextFormatWhite;
			choiceText.htmlText = text;
			radioChoiceContainer.addChild(choiceText);
			choiceText.x = radioButton.x + 4;
			choiceText.y = 0;
			radioButton.height = Math.ceil(choiceText.height) + 22;
			//radioButton.y = (choiceText.textHeight - radioButton.height)/2 + 4;
			choiceText.y = radioButton.y + (radioButton.height - choiceText.height)/2 - 2;
			trace(radioButton.height + " : " +choiceText.textHeight + " : " +  choiceText.height );
			addChild(radioChoiceContainer);
		}
		
		public function doButtonOver(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("_over");
		}
		public function doButtonOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("_out");
		}
		public function doButtonClick(e:MouseEvent):void
		{
			var button:MovieClip = e.target as MovieClip;
			if (button.currentLabel == "UP")
			{
				button.gotoAndStop("_over");
				selected = true;
			}
			else
			{
				button.gotoAndStop("_up");
				selected = false;
			}
		}
		public function get State():String
		{
			return radioButton.currentLabel;
		}
		public function set State(state:String):void
		{
			this.radioButton.gotoAndStop(state);
			/*if (state == "OVER")
			{
				selected = true;
			}
			else
			{
				selected = false;
			}*/
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
			return this.radioButton;
		}
		public function set ChoiceTextLength(num:Number):void
		{
			this.choiceText.width = num;
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
		public function set Color(color:uint):void
		{
			this.choiceText.backgroundColor = color;
		}
		public function getTextHeight():Number
		{
			return this.choiceText.textHeight;
		}
	}
	
}