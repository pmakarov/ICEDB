package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.MediaLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class  RadioImage extends MovieClip
	{
		private var radioChoiceContainer:MovieClip;
		private var checkbox:myPrimeRadioButton;
		private var selected:Boolean;
		public var id:String;
		public var valueId:String;
		public var ml:MediaLoader;
		private var bBox:whiteBox;
		private var src:String;
		
		public function RadioImage(src:String = ""):void
		{
			selected = false; 
			id = "";
			valueId = "";
			checkbox = new myPrimeRadioButton();
			bBox = new whiteBox();
			ml = new MediaLoader();
			ml.addEventListener("ASSET_LOADED", buildInterface);
			radioChoiceContainer = new MovieClip();
			
			this.src = src;
			addChild(radioChoiceContainer);
		}
		public function buildInterface(e:Event):void 
		{
			
			bBox.width = 175;
			bBox.height = 235;
			bBox.x = 0;
			bBox.y = 0;
			ml.x = bBox.x + 5;
			ml.y = bBox.y + 5;
			ml.loader.content.width  = 165;
			ml.loader.content.height = 190;
			checkbox.x = bBox.width / 2 - checkbox.width / 2;
			checkbox.y = bBox.height - (5 + checkbox.height);
			checkbox.scaleX = checkbox.scaleY = .9;
			radioChoiceContainer.addChild(bBox);
			radioChoiceContainer.addChild(ml);
			radioChoiceContainer.addChild(checkbox);
		}
		
		public function doButtonClick(e:MouseEvent):void
		{
			
			var button:MovieClip = e.target as MovieClip;
			if (button.currentLabel == "_up")
			{
				button.gotoAndStop("_down");
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
		public function get Data():String
		{
			return this.src;
		}
		public function setColor(color:ColorTransform):void 
		{
			this.bBox.transform.colorTransform = color;
		}
	}
	
}