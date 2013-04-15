package com.Amtrak.ICE.components
{
	import com.greensock.TweenMax;
	import com.Amtrak.ICE.Evaluation;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class FillInTheBlank extends Evaluation implements IEvaluationDisplayable
	{
		private var inputBoxes:Array = [];
		private var questions:Array = [];
		private var questionTextFormat:TextFormat;
		
		public function FillInTheBlank(xml:XML = null)
		{	
			super(xml);
			for each ( var remediation:XML in xml..remediationText )
			{
				var remediationObject:Object = new Object();
				remediationObject.value = remediation.@valueID;
				remediationObject.text = remediation.toString();
				remediationList.push( remediationObject );
			}
		}
		override public function handleContentLoaded(e:Event):void
		{
		/*	questionTextFormat = new TextFormat();
            questionTextFormat.font = FontManager.segoe.fontName;
            questionTextFormat.color = 0x000000;
            questionTextFormat.size = 14;
            questionTextFormat.underline = false;	
			parseQuestionText(questionText);
			display();*/
		}
		public function parseQuestionText(str:String):void 
		{
			var myPattern:RegExp = /<input[^>]+>/ig 
			var result:Object = myPattern.exec(str);
			while (result != null) 
			{
				//trace( result.index, "\t", result);
				//this scrubs out all double quotes and replaces them with single quotes
				//result = String(result).replace(/"([^"]*)"/g, "'$1'" );
				//trace(result);
				var xml:XML = XML(result);
				var textArea:TextArea = new TextArea();
				textArea.name = xml.@id;
				inputBoxes.push(textArea);
				result = myPattern.exec(str);
			 }
			
			str = stripHTML(str);
			questions = str.split("~~~");
			
			var tmp:Array = new Array();
			for (var i:uint = 0; i < questions.length; i++)
			{
				if (questions[i] != "")
				{
					tmp.push(questions[i]);
					
				}
			}
			questions = tmp;
		}
		public static function stripHTML(value:String):String
		{	
			return value.replace(/<.*?>/g, "~~~");
		}
		override public function display():void
		{
			questionTextFormat = new TextFormat();
            questionTextFormat.font = FontManager.segoe.fontName;
            questionTextFormat.color = 0x000000;
            questionTextFormat.size = 14;
            questionTextFormat.underline = false;	
			parseQuestionText(questionText);
			
			
			var background_mc:fibBG = new fibBG();
			background_mc.alpha = 0;
			addChild(background_mc);
			TweenMax.to(background_mc, .75, { alpha:1 } );
			
			titleText_mc= new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			titleText_mc.embedFonts = true;
			var format:TextFormat = new TextFormat();
            format.font = FontManager.bgM.fontName;
            format.color = 0xFFFFFF;
            format.size = 22;
            format.underline = false;
            titleText_mc.defaultTextFormat = format;
			titleText_mc.text = titleText;
			titleText_mc.x = (background_mc.width - titleText_mc.width)/2;
			titleText_mc.y = 9;
			titleText_mc.alpha = 0;
			background_mc.addChild(titleText_mc);
			TweenMax.to(titleText_mc, .75, { delay:.6, alpha:1});
			
			instructionText_mc = new TextField();
			instructionText_mc.autoSize = TextFieldAutoSize.LEFT;
            instructionText_mc.background = false; //use true for doing generic labels
            instructionText_mc.border = false;      // ** same
			instructionText_mc.embedFonts = true;
			instructionText_mc.antiAliasType = "advanced";
			instructionText_mc.sharpness = -300;
			instructionText_mc.thickness = -50;
			var format2:TextFormat = new TextFormat();
            format2.font = FontManager.segoeItalic.fontName;
            format2.color = 0xFFFFFF;
            format2.size = 14;
			format2.italic = true;
            format2.underline = false;
            instructionText_mc.defaultTextFormat = format2;
			instructionText_mc.text = instructionText;
			instructionText_mc.x = (this.width - instructionText_mc.width) / 2;
			instructionText_mc.y = 44;
			instructionText_mc.alpha = 0;
			background_mc.addChild(instructionText_mc);
			TweenMax.to(instructionText_mc, .75, { delay: 1.2, alpha:1 } );
			
			var wb:whiteBox = new whiteBox();
			wb.width = 754;
			wb.height = 316;
			wb.x = (this.width - wb.width) / 2;
			wb.y = instructionText_mc.y + 30;
			background_mc.addChild(wb);
			wb.alpha = 0;
			TweenMax.to(wb, .75, { delay:1.6, alpha:.85 } );
			TweenMax.to(wb, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			
			
			if (instructionText_mc.text != "" )
			{
				wb.y = instructionText_mc.y + 30;
			}
			else 
			{
				wb.y = 44;
			}
			var spacer:Number = wb.y + 5;
			var totalTextHeight:Number = 0;
			if (layout == "vertical")
			{
				for (var i:uint = 0; i < questions.length; i++)
				{
					var tF:TextField = new TextField();
					tF.autoSize = TextFieldAutoSize.LEFT;
					tF.background = false; //use true for doing generic labels
					tF.border = false;      // ** same
					tF.embedFonts = true;
					tF.antiAliasType = "advanced";
					tF.sharpness = -300;
					tF.thickness = -50;
					tF.wordWrap = true;
					tF.width = wb.width - 10;
					tF.defaultTextFormat = questionTextFormat;
					tF.htmlText = questions[i];
					tF.x = wb.x + 5;
					tF.y = spacer;
					tF.alpha = 0;
					background_mc.addChild(tF);
					questions[i] = tF;
					spacer += tF.height + 5;
					totalTextHeight += tF.height;
					inputBoxes[i].setStyle("textFormat", questionTextFormat);
					//*** set it to NO SCROLL AS A REQUEST!!! 10/13/10
					inputBoxes[i].verticalScrollPolicy = ScrollPolicy.OFF;
					inputBoxes[i].x = wb.x +5;
					inputBoxes[i].y = spacer;
					inputBoxes[i].width = tF.width;
					inputBoxes[i].height = 20;
					inputBoxes[i].alpha = 0;
					background_mc.addChild(inputBoxes[i]);
					spacer += 20 + 5;
				}
				spacer = wb.y + 5;
				for (var j:uint = 0; j < questions.length; j++)
				{
					inputBoxes[j].height = (wb.height - totalTextHeight - (5*(2*questions.length + 1))) / questions.length;
					questions[j].x = wb.x + 5;
					questions[j].y = spacer;
					spacer += questions[j].height + 5;
					inputBoxes[j].x = wb.x + 5;
					inputBoxes[j].y = spacer;
					spacer += inputBoxes[j].height + 5;
					
					if (j < questions.length - 1)
					{
						TweenMax.to(questions[j], .75, { delay:2.0 + (j+1*.6), alpha:1 } );
						TweenMax.to(inputBoxes[j], .75, { delay:2.4 + (j+1*.6), alpha:1 } );
					}
					else
					{
						TweenMax.to(questions[j], .75, { delay:2.0 + (j+1*.6), alpha:1 } );
						TweenMax.to(inputBoxes[j], .75, { delay:2.4 + (j+1*.6), alpha:1 , onComplete:fadeInButton, onCompleteParams:[background_mc] });
					}
					
				}
			}
			else
			{
				for (var y:uint = 0; y < questions.length; y++)
				{
					var textF:TextField = new TextField();
					textF.autoSize = TextFieldAutoSize.LEFT;
					textF.background = false; //use true for doing generic labels
					textF.border = false;      // ** same
					textF.embedFonts = true;
					textF.antiAliasType = "advanced";
					textF.wordWrap = true;
					textF.width = wb.width - 10;
					textF.defaultTextFormat = questionTextFormat;
					textF.text = questions[y];
					textF.x = wb.x + 5;
					textF.alpha = 0;
					textF.y = spacer;
					background_mc.addChild(textF);
					questions[y] = textF;
					spacer += textF.height + 5;
					totalTextHeight += textF.height;
					inputBoxes[i].setStyle("textFormat", questionTextFormat);
					//*** set it to NO SCROLL AS A REQUEST!!! 10/13/10
					inputBoxes[y].verticalScrollPolicy = ScrollPolicy.OFF;
					inputBoxes[y].x = wb.x +5;
					inputBoxes[y].y = spacer;
					inputBoxes[y].width = textF.width;
					inputBoxes[y].height = 20;
					inputBoxes[y].alpha = 0;
					background_mc.addChild(inputBoxes[y]);
					spacer += 20 + 5;
				}
				spacer = wb.y + 5;
				for (var z:uint = 0; z < questions.length; z++)
				{
					inputBoxes[z].height = (wb.height - totalTextHeight - (5*(2*questions.length + 1))) / questions.length;
					TweenMax.to(questions[z], .75, { delay:1.2 + (z+1*.6), alpha:1 } );
					questions[z].x = wb.x + 5;
					questions[z].y = spacer;
					spacer += questions[z].height + 5;
					inputBoxes[z].x = wb.x + 5;
					inputBoxes[z].y = spacer;
					TweenMax.to(inputBoxes[z], .75, { delay:1.8 + (z+1*.6), alpha:1 } );
					spacer += inputBoxes[z].height + 5;
				}
			}
			
			
			
			var submit:greenGlassButton = new greenGlassButton();
			var format4:TextFormat = new TextFormat();
			format4.font = FontManager.bgM.fontName;
            format4.color = 0xFFFFFF;
            format4.size = 22;
			submit.label.embedFonts = true;
			submit.label.defaultTextFormat = format4;
			submit.label.text = "Next";
			submit.label.mouseEnabled = false;
			submit.alpha = 0;
			submit.name = "submit";
			//submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
			//submit.buttonMode = true;
			submit.useHandCursor = true;
			submit.mouseChildren = false;
			submit.x = this.width - (submit.width + 10);
			submit.y = 432 - (submit.height + 10);
			background_mc.addChild(submit);
			TweenMax.to(submit, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );
			
			var remIcon:remediationIcon = new remediationIcon();
			remIcon.x = wb.x + 5;
			remIcon.y = submit.y + 4;
			remIcon.alpha = 0;
			remIcon.name = "remIcon";
			background_mc.addChild(remIcon);
			
			var remediationText:TextField = new TextField();
			remediationText.autoSize = TextFieldAutoSize.LEFT;
			remediationText.background = false; //use true for doing generic labels
			remediationText.border = false;      // ** same
			remediationText.embedFonts = true;
			remediationText.antiAliasType = "advanced";
			remediationText.sharpness = -300;
			remediationText.thickness = - 50;
			remediationText.wordWrap = true;
			remediationText.width = wb.width - submit.width-40;
			remediationText.defaultTextFormat = FontManager.instructionTextFormatWhite;
			remediationText.htmlText = '<a href="event:">' + remediation.linkText +  '</a>';
			remediationText.addEventListener(TextEvent.LINK, handleRemediationLink);
			remediationText.x = wb.x + 25;
			remediationText.y = remIcon.y;
			remediationText.alpha = 0;
			remediationText.name = "remediationText";
			background_mc.addChild(remediationText);
			
		}
		public function fadeInButton(background_mc:MovieClip):void 
		{
			var submit:MovieClip = background_mc.getChildByName("submit") as MovieClip;
			TweenMax.to(submit, .25, {alpha:1});
			submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
			submit.buttonMode = true;
			submit.label.mouseEnabled = false;
			if (remediationList.length > 0)
			{
			var remIcon:MovieClip = background_mc.getChildByName("remIcon") as MovieClip;
			var remediationText:TextField = background_mc.getChildByName("remediationText") as TextField;
			
			TweenMax.to(remIcon, .25, { delay:.6, alpha:1 } );
			TweenMax.to(remediationText, .25, { delay:1.2, alpha:1 } );
			}
		}
		public function  handleRemediationLink(e:TextEvent):void 
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			//tmp.text = "One or more text fields are empty. FILL THEM OUT NOW!!!";
			var bling:String = "";
			for (var i:uint = 0; i < questions.length; i++)
			{
				
				if (remediationList[i].text != "")
				{
				 bling += '<b>'+questions[i].text + '</b>'+ "\r" + remediationList[i].text + "\r\n";
				//tmp.text += remediationList[i].text; 
				}
			}
			//trace(bling);
			tmp.text = bling;
			tmp.value = false;
			tmp.windowType = "REMEDIATION";
			dispatchEvent(new FeedbackEvent(tmp));
		}
		override public function evaluate():void
		{
			
			for (var i:uint = 0; i < inputBoxes.length; i++)
			{
				var tmp:Object = new Object();
				tmp.title = titleText;
				if (inputBoxes[i].text == "")
				{
					tmp.title = "Not Enough Information Supplied!";
					tmp.text = "You have not fulfilled the requirements for completing this interaction. Please check the screen instructions for more information. Click OK to continue."; 
					tmp.value = false;
					tmp.windowType = "CAUTION";
					dispatchEvent(new FeedbackEvent(tmp));
					return;
				}
			}
			
			var isCorrect:Boolean = false;
			
			evalData = evalData as Array ;
			evalData = new Array();
			for (var j:uint; j < inputBoxes.length; j++)
			{
			//trace("Answer ID: " + userSelection[a].id +  "\nanswerText : " +userSelection[a].Data);
			//trace(steps[stepNumber].component.evalData[i].Data);
				evalData.push({"answerID":inputBoxes[j].name, "answerData":inputBoxes[j].text});
			}
			//evalData = { "answerID":"c1","answerText":tA.text};
			
			//Currently only can have one type of feedback; defaults to the first feedback
			if (feedbackList.length > 0)
			{
				tmp.text = this.feedbackList[0].text;
				tmp.value = this.feedbackList[0].value;
				tmp.windowType = "EVALUATION";
				dispatchEvent(new FeedbackEvent(tmp));						
			}
			else
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
			}
		}
	}
	
}