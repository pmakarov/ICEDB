package com.Amtrak.ICE
{
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	

	
	public class FontManager extends Sprite
	{		
		public static var futura:futuraNormal = new futuraNormal();
		public static var goodtimes:goodTimes = new goodTimes();
		
		public static var QuestionTextFormatWhite:TextFormat = new TextFormat();
		QuestionTextFormatWhite.font = FontManager.futura.fontName;
        QuestionTextFormatWhite.size = 20;
        QuestionTextFormatWhite.color = 0xFFFFFF;
		
		public static var choiceTextFormatWhite:TextFormat = new TextFormat();
		choiceTextFormatWhite.font = FontManager.futura.fontName;
        choiceTextFormatWhite.size = 18;
        choiceTextFormatWhite.color = 0xFFFFFF;
		
		public static var ButtonTextFormatWhite:TextFormat = new TextFormat();
		ButtonTextFormatWhite.font = FontManager.goodtimes.fontName;
        ButtonTextFormatWhite.size = 16;
        ButtonTextFormatWhite.color = 0xFFFFFF;
		
		/*public static var bgM:BankGothicMedium = new BankGothicMedium();
		public static var segoeItalic:SegoeItalic = new SegoeItalic();
		
		public static var titleTextFormatBlack:TextFormat = new TextFormat();
		titleTextFormatBlack.font = FontManager.bgM.fontName;
        titleTextFormatBlack.size = 22;
		titleTextFormatBlack.color = 0x000000;
		
		public static var titleTextFormatWhite:TextFormat = new TextFormat();
		titleTextFormatWhite.font = FontManager.bgM.fontName;
        titleTextFormatWhite.size = 22;
        titleTextFormatWhite.color = 0xFFFFFF;

		public static var instructionTextFormat:TextFormat = new TextFormat();
		instructionTextFormat.font = FontManager.segoeItalic.fontName
		instructionTextFormat.size = 14;
		instructionTextFormat.italic = true;*/
		
		
	}
	
}