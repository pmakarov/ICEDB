package com.Amtrak.ICE.utils
{
	import fl.controls.listClasses.CellRenderer
	import fl.controls.listClasses.ICellRenderer;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	
	public class ColorRenderer extends CellRenderer implements ICellRenderer 
	{

		public function ColorRenderer():void 
		{
			super();
		}

		public static function getStyleDefinition():Object 
		{
			return CellRenderer.getStyleDefinition();
		}

		override protected function drawBackground():void 
		{
			var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 10;
            format.underline = false;
			format.bold = true;

			setStyle("textFormat",format);
			super.drawBackground();
		}
	}
}