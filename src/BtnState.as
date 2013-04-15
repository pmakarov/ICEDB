package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	//States for transition buttons
	
	class BtnState extends Sprite
	{
		public var btnLabel:TextField;
		public function BtnState(color:uint, color2:uint, btnLabelText:String)
		{
			btnLabel = new TextField;
			btnLabel.text = btnLabelText;
			btnLabel.x = 5;
			btnLabel.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat("Verdana");
			format.size = 12;
			btnLabel.setTextFormat(format);
			var btnWidth:Number = btnLabel.textWidth + 10;
			var background:Shape = new Shape;
			background.graphics.beginFill(color);
			background.graphics.lineStyle(2, color2);
			background.graphics.drawRect(0, 0, btnWidth, 18);
			addChild(background);
			addChild(btnLabel);
		}
	}
}