package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.Evaluation
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import com.Amtrak.ICE.MediaLoader;
	import fl.controls.TextArea;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import mx.events.MoveEvent;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class ReflectionQuestion extends Evaluation implements IEvaluationDisplayable
	{
		private var tA:TextArea;
		public var templateType:String;
		private var background_mc:MovieClip;
		
		public function ReflectionQuestion(xml:XML = null)
		{
			tA = new TextArea();
			templateType = (xml.@templateType == undefined) ? "default" : xml.@templateType;
			super(xml);
		}
		public function displayAfterDynamicContent(e:Event):void
		{
			if (dependentData)
			{
				for (var i:uint = 0; i < dependentData.length; i++)
				{
					trace("textArea = " + dependentData[i].answerID + " : " + dependentData[i].answerData);
					tA.text += dependentData[i].answerData;
				}
			}
			displayInterface();
		}
		public function handleRepostData(e:Event):void
		{	
			repostData = dependentData;
			displayInterface();
		}
		override public function handleContentLoaded(e:Event):void 
		{
			
			this.addEventListener("DYNAMIC_DATA_LOADED", displayAfterDynamicContent);
			this.addEventListener("REPOST", handleRepostData);
			if (dataDependencyID != "")
			{
				var tmp:Object = new Object();
				tmp.componentID = dataDependencyID;
				dispatchEvent(new ComponentDataRequestEvent(tmp));
			}
			else
			{
				displayInterface();
			}
		}
		
		override public function display():void
		{
			this.addEventListener("DYNAMIC_DATA_LOADED", displayAfterDynamicContent);
		    if (dataDependencyID != "")
			{
				var tmp:Object = new Object();
				tmp.componentID = dataDependencyID;
				dispatchEvent(new ComponentDataRequestEvent(tmp));
				
			}
			else
			{
				displayInterface();
			}
			
			
		}
		public function displayInterface():void
		{
			background_mc = new MovieClip();
			if (templateType != "default")
			{
				background_mc = new noteBG();
				background_mc.gotoAndStop(parseInt(choiceList[0].text));
				
				var congrats:TextField = new TextField();
				congrats.autoSize = TextFieldAutoSize.LEFT;
				congrats.background = false; //use true for doing generic labels
				congrats.border = false;      // ** same
				congrats.embedFonts = true;
				congrats.antiAliasType = "advanced";
				congrats.wordWrap = true;
				congrats.width = 400;
				
				var titleTextFormatWhite:TextFormat = new TextFormat();
				titleTextFormatWhite.font = FontManager.bgM.fontName;
				titleTextFormatWhite.size = 37;
				titleTextFormatWhite.color = 0xFFFFFF;

				congrats.defaultTextFormat = titleTextFormatWhite;
				congrats.text = "congratulations!";
				congrats.x = background_mc.width/2 - congrats.textWidth/2;
				congrats.y = background_mc.height/3;
				congrats.alpha = 1;
				congrats.name = "congratsText";
				background_mc.addChild(congrats);
				
				
				var completed:TextField = new TextField();
				completed.autoSize = TextFieldAutoSize.LEFT;
				completed.background = false; //use true for doing generic labels
				completed.border = false;      // ** same
				completed.embedFonts = true;
				completed.antiAliasType = "advanced";
				completed.wordWrap = true;
				completed.width = 500;
				
				var completedFormatWhite:TextFormat = new TextFormat();
				completedFormatWhite.font = FontManager.bgM.fontName;
				completedFormatWhite.size = 25;
				completedFormatWhite.color = 0xFFFFFF;

				completed.defaultTextFormat = completedFormatWhite;
				completed.text = "you have completed Lesson:";
				completed.x = background_mc.width/2 - completed.textWidth/2;
				completed.y = congrats.y + congrats.height + 2;
				completed.alpha = 1;
				completed.name = "completedText";
				background_mc.addChild(completed);
				
				var lesson:TextField = new TextField();
				lesson.autoSize = TextFieldAutoSize.LEFT;
				lesson.background = false; //use true for doing generic labels
				lesson.border = false;      // ** same
				lesson.embedFonts = true;
				lesson.antiAliasType = "advanced";
				lesson.wordWrap = true;
				lesson.width = background_mc.width;
				
				
				var lessonFormatWhite:TextFormat = new TextFormat();
				lessonFormatWhite.font = FontManager.bgM.fontName;
				lessonFormatWhite.size = 37;
				lessonFormatWhite.color = 0xFFFFFF;
				lessonFormatWhite.align = "center";
				
				var lessonFormatWhite2:TextFormat = new TextFormat();
				lessonFormatWhite2.font = FontManager.bgM.fontName;
				lessonFormatWhite2.size = 27;
				lessonFormatWhite2.color = 0xFFFFFF;
				lessonFormatWhite2.align = "center";
				
				lesson.defaultTextFormat = lessonFormatWhite;
				
				lesson.text = questionText;
				lesson.x = 0;
				lesson.y = completed.y + completed.height + 2;
				lesson.alpha = 1;
				lesson.name = "lessonText";
				background_mc.addChild(lesson);
				if (lesson.textWidth > 600)
				{
					lesson.setTextFormat(lessonFormatWhite2);
				}
				
				var remediationText:TextField = new TextField();
				remediationText.autoSize = TextFieldAutoSize.LEFT;
				remediationText.background = false; //use true for doing generic labels
				remediationText.border = false;      // ** same
				remediationText.embedFonts = true;
				remediationText.antiAliasType = "advanced";
				remediationText.sharpness = -300;
				remediationText.thickness = - 50;
				remediationText.wordWrap = true;
				remediationText.width = 600;
				remediationText.defaultTextFormat = FontManager.noteTextFormatWhite;
				remediationText.htmlText = 'Want to remember something about this lesson? <a href="event:"><font color="#FFFF99"><u>Click here!</u></font> </a>';
				//remediationText.text = '<a href="event:">Want some ideas to help you answer these questions? <font color="#FFFF99"><u>Click here for some suggestions.</u></font> </a>';
				remediationText.addEventListener(TextEvent.LINK, handleRemediationLink);
				remediationText.x = background_mc.width/2 - remediationText.textWidth/2;
				remediationText.y = 295;
				remediationText.alpha = 1;
				remediationText.name = "remediationText";
				background_mc.addChild(remediationText);
				addChild(background_mc);
				
				
				
				var next:greenGlassButton = new greenGlassButton();
				var format8:TextFormat = new TextFormat();
				format8.font = FontManager.bgM.fontName;
				format8.color = 0xFFFFFF;
				format8.size = 22;
				next.label.embedFonts = true;
				next.label.defaultTextFormat = format8;
				next.label.text = "next";
				next.label.mouseEnabled = false;
				//next.addEventListener(MouseEvent.CLICK, handleEvaluation);
				next.buttonMode = false;
				next.mouseChildren = false;
				next.useHandCursor = true;
				next.x = this.width - (next.width + 15);
				next.y = this.height - (next.height + 10);
				next.alpha = 0;
				background_mc.addChild(next);
				TweenMax.to(next, .15, {glowFilter:{color:0xFFFFFF, alpha:.8, blurX:10, blurY:10, quality:1}});
				TweenMax.to(next, .75, { delay:1, alpha:1, onComplete:activateControls, onCompleteParams:[next]} );
			
			}
			else
			{
				background_mc = new reflectionBG();
				background_mc.name = "bg";
				if (customBG != "")
				{
					var ml:MediaLoader = new MediaLoader();
					ml.loadMedia(customBG.toString());
					background_mc.addChild(ml);
				}
				background_mc.alpha = 0;
				addChild(background_mc);
				
				
				addChild(background_mc);
				TweenMax.to(background_mc, .75, { alpha:1});

				titleText_mc= new TextField();
				titleText_mc.autoSize = TextFieldAutoSize.LEFT;
				titleText_mc.background = false; //use true for doing generic labels
				titleText_mc.border = false;      // ** same
				titleText_mc.embedFonts = true;            
				titleText_mc.defaultTextFormat = FontManager.titleTextFormatBlack;
				titleText_mc.text = titleText;
				titleText_mc.x = (background_mc.width - titleText_mc.width)/2;
				titleText_mc.y = 19;
				titleText_mc.alpha = 0;
				background_mc.addChild(titleText_mc);
				TweenMax.to(titleText_mc, .75, { delay:.6, alpha:1});
				
				instructionText_mc = new TextField();
				instructionText_mc.autoSize = TextFieldAutoSize.LEFT;
				instructionText_mc.background = false; //use true for doing generic labels
				instructionText_mc.border = false;      // ** same
				instructionText_mc.embedFonts = true;
				instructionText_mc.wordWrap = true;
				instructionText_mc.antiAliasType = "advanced";
				instructionText_mc.sharpness = -300;
				instructionText_mc.thickness = -50;
				instructionText_mc.defaultTextFormat = FontManager.instructionTextFormatBlack;
				//instructionText_mc.text = instructionText;
				//instructionText_mc.width = this.width - 20;
				instructionText_mc.x = (this.width - instructionText_mc.textWidth) / 2;
				instructionText_mc.y = 54;
				instructionText_mc.alpha = 0;
				background_mc.addChild(instructionText_mc);
				TweenMax.to(instructionText_mc, .75, { delay: 1.2, alpha:1 } );
				
				var wb:whiteBox = new whiteBox();
				wb.width = 700;
				wb.x = (this.width - wb.width) / 2;
				wb.y = instructionText_mc.y + 30;
				wb.alpha = 0;
				background_mc.addChild(wb);
				
				if (instructionText_mc.text != "" )
				{
					wb.y = instructionText_mc.y + 30;
				}
				else 
				{
					wb.y = 59;
				}
				questionText_mc = new TextField();
				questionText_mc.autoSize = TextFieldAutoSize.LEFT;
				questionText_mc.background = false; //use true for doing generic labels
				questionText_mc.border = false;      // ** same
				questionText_mc.embedFonts = true;
				questionText_mc.antiAliasType = "advanced";
				questionText_mc.sharpness = -300;
				questionText_mc.thickness = -50;
				questionText_mc.wordWrap = true;
				questionText_mc.width = wb.width - 8;
				questionText_mc.defaultTextFormat = FontManager.choiceTextFormatBlack;
				questionText_mc.text = questionText;
				questionText_mc.x = wb.x + 4;
				questionText_mc.y = wb.y + 2;
				questionText_mc.alpha = 0;
				wb.height = questionText_mc.height + 4;
				TweenMax.to(wb, .75, { delay:1.2, alpha:1 } );
				TweenMax.to(wb, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
				TweenMax.to(questionText_mc, .75, { delay:1.2, alpha:1 } );
				background_mc.addChild(questionText_mc);
				
				
				var wb2:whiteBox = new whiteBox();
				wb2.width = 600;
				wb2.x = (this.width - wb2.width) / 2;
				wb2.y = wb.y + wb.height + 10;
				wb2.alpha = 0;
				background_mc.addChild(wb2);
				
				tA.width = 590;
				tA.height = 240;
				tA.setStyle("textFormat", FontManager.choiceTextFormatBlack);
				tA.setStyle("borderStyle", "none");
				//tA.setStyle("focusRectSkin",new Sprite());
				tA.setStyle("upSkin", new Sprite ());
				//var tFF:TextFormat = tA.getStyle("textFormat") as TextFormat;
				//trace(tFF.font + " : is the font");
				
				tA.x = wb2.x +5;
				tA.y = wb2.y + 5;
				tA.alpha = 0;
				tA.name = "c1";
				tA.editable = false;
				wb2.height = tA.height + 10;
				TweenMax.to(wb2, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
				background_mc.addChild(tA);
				TweenMax.to(wb2, .75, { delay:1.8, alpha:1 } );
				TweenMax.to(tA, .75, { delay:1.8, alpha:1 } );
		
				var submit:greenGlassButton = new greenGlassButton();
				var format4:TextFormat = new TextFormat();
				format4.font = FontManager.bgM.fontName;
				format4.color = 0xFFFFFF;
				format4.size = 22;
				submit.label.embedFonts = true;
				submit.label.defaultTextFormat = format4;
				submit.label.text = "Submit";
				submit.label.mouseEnabled = false;
				//submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
				submit.buttonMode = false;
				submit.mouseChildren = false;
				submit.useHandCursor = true;
				submit.x = (this.width - submit.width)/2;
				submit.y = this.height - (submit.height + 20);
				submit.alpha = 0;
				background_mc.addChild(submit);
				TweenMax.to(submit, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );
				TweenMax.to(submit, .75, { delay:3, alpha:1, onComplete:activateControls, onCompleteParams:[submit]} );
				
			}
		}
		public function activateControls(mc:MovieClip):void
		{
			tA.editable = true;
			mc.buttonMode  = true;
			mc.addEventListener(MouseEvent.CLICK, handleEvaluation);
			if (repostData)
			{
				if (repostData.length>0)
				{
					tA.text = repostData[0].answerData;
				}
			}
			
		}
		override public function evaluate():void
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			if (tA.text == "" && templateType!="notes")
			{
				tmp.title = "No Information Supplied!";
				tmp.text = "You did not provide a response. \nClick 'YES' to skip. Click 'NO' to return to the question.";
				tmp.value = false;
				tmp.windowType = "yesNo";
				dispatchEvent(new FeedbackEvent(tmp));
				return;
			}
			else if (templateType == "notes" && tA.text == "")
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
				return;
			}
			var isCorrect:Boolean = false;
			evalData = evalData as Array;
			evalData = new Array();
			evalData.push({ "answerID":tA.name,"answerData":tA.text});
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
		public function  handleRemediationLink(e:TextEvent):void 
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			//tmp.text = "One or more text fields are empty. FILL THEM OUT NOW!!!";
			//var bling:String = "ddddddddddddddddddddddddd";
			
				
			//trace(bling);
			tmp.text = "Enter your notes in the text box below, then click Save.";
			tmp.value = false;
			tmp.windowType = "NOTE";
			/*dispatchEvent(new FeedbackEvent(tmp));*/
			
			var feedbackContainer:MovieClip = new MovieClip();
			feedbackContainer.name = "feedback";
			addChild(feedbackContainer);
			feedbackContainer.visible = false;
			
			var wb:whiteBox = new whiteBox();
			wb.width = 520;
			wb.height = 210;
			wb.x = 0;
			wb.y = 0
			wb.alpha = 0;
			feedbackContainer.addChild(wb);

			
		    var titleText_mc:TextField = new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			titleText_mc.embedFonts = true;
			titleText_mc.antiAliasType = "advanced";
			titleText_mc.gridFitType = GridFitType.PIXEL;
			titleText_mc.sharpness = -200;
			titleText_mc.wordWrap = true;
			var format:TextFormat = new TextFormat();
            format.font = FontManager.segoeBold.fontName;
            format.color = 0x000000;
            format.size = 14;
			format.bold = true;
            titleText_mc.defaultTextFormat = format;
			titleText_mc.text = tmp.title;
			titleText_mc.x = wb.x + 100;
			titleText_mc.y = wb.y + 15;
			titleText_mc.width = wb.width - 40;
			titleText_mc.alpha = 0;
			feedbackContainer.addChild(titleText_mc);
			
			var feedBackText_mc:TextField = new TextField();
			feedBackText_mc.autoSize = TextFieldAutoSize.LEFT;
            feedBackText_mc.background = false; //use true for doing generic labels
            feedBackText_mc.border = false;      // ** same
			feedBackText_mc.embedFonts = true;
			feedBackText_mc.antiAliasType = "advanced";
			feedBackText_mc.gridFitType = GridFitType.PIXEL;
			feedBackText_mc.sharpness = -300; //-400:400
			feedBackText_mc.thickness = -50; //-200:200
			feedBackText_mc.wordWrap = true;
			feedBackText_mc.width = wb.width - 150;
			var format2:TextFormat = new TextFormat();
            format2.font = FontManager.segoe.fontName;
            format2.color = 0x000000;
            format2.size = 14;
            format2.underline = false;
            feedBackText_mc.defaultTextFormat = format2;
			//feedBackText_mc.setTextFormat(format2);
			feedBackText_mc.multiline = true;
			feedBackText_mc.htmlText = e.text;
			feedBackText_mc.x = wb.x + 100;
			feedBackText_mc.y = titleText_mc.y + titleText_mc.height;
			feedBackText_mc.alpha = 0;
			feedBackText_mc.name = "feedback";
			feedbackContainer.addChild(feedBackText_mc);
			
			wb.height = 15 + titleText_mc.height + 10 + feedBackText_mc.height + 60;
			
			tA.width = feedbackContainer.width - 20;
			tA.height = 240;
			tA.setStyle("textFormat", FontManager.choiceTextFormatBlack);
			//tA.setStyle("borderStyle", "none");
			//tA.setStyle("focusRectSkin",new Sprite());
			//tA.setStyle("upSkin", new Sprite ());
			//var tFF:TextFormat = tA.getStyle("textFormat") as TextFormat;
			//trace(tFF.font + " : is the font");
			
			tA.x = feedBackText_mc.x;
			tA.y = feedBackText_mc.y + feedBackText_mc.textHeight + 25;
			tA.alpha = 0;
			tA.name = "c1";
			tA.editable = true;
			
			feedbackContainer.addChild(tA);
			TweenMax.to(tA, .75, { delay:1.8, alpha:1 } );
			
			
			var feedBackText_mc2:TextField = new TextField();
			feedBackText_mc2.autoSize = TextFieldAutoSize.LEFT;
            feedBackText_mc2.background = false; //use true for doing generic labels
            feedBackText_mc2.border = false;      // ** same
			feedBackText_mc2.embedFonts = true;
			feedBackText_mc2.antiAliasType = "advanced";
			feedBackText_mc2.gridFitType = GridFitType.PIXEL;
			feedBackText_mc2.sharpness = -300; //-400:400
			feedBackText_mc2.thickness = -50; //-200:200
			feedBackText_mc2.wordWrap = true;
			feedBackText_mc2.width = wb.width - 150;
            feedBackText_mc2.defaultTextFormat = format2;
			//feedBackText_mc.setTextFormat(format2);
			feedBackText_mc2.multiline = true;
			feedBackText_mc2.htmlText = "Your note can be viewed at anytime in My Stuff.";
			feedBackText_mc2.x = wb.x + 100;
			feedBackText_mc2.y = tA.y + tA.height+ 10;
			feedBackText_mc2.alpha = 0;
			feedBackText_mc2.name = "feedback2";
			feedbackContainer.addChild(feedBackText_mc2);
			
			
			var lineDrawing:MovieClip = new MovieClip();
			feedbackContainer.addChild(lineDrawing);
			lineDrawing.graphics.lineStyle(1, 0, 1);
			lineDrawing.graphics.moveTo(titleText_mc.x-5,wb.y+10); ///This is where we start drawing
			lineDrawing.graphics.lineTo(titleText_mc.x-5, wb.y+wb.height - 10);
			lineDrawing.alpha = 0;
			
			var next:greenGlassButton = new greenGlassButton();
			var format4:TextFormat = new TextFormat();
			format4.font = FontManager.bgM.fontName;
            format4.color = 0xFFFFFF;
            format4.size = 22;
			next.label.embedFonts = true;
			next.label.defaultTextFormat = format4;
			next.label.mouseEnabled = false;
			next.mouseChildren = false;
			next.x = (wb.width - next.width)/2;
			next.y = wb.y + wb.height - (next.height + 10);
			next.alpha = 0;
			feedbackContainer.addChild(next);
			TweenMax.to(next, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );

			
			
			
		
				next.label.text = "save";
				next.addEventListener(MouseEvent.CLICK, doCloseFeedback);
				wb.width = 754;
				wb.height = 408;
				titleText_mc.y -= 10;
				
				feedBackText_mc.htmlText = tmp.text;
				
				//feedBackText_mc.styleSheet = style;
				//feedBackText_mc.x = 10;
				feedBackText_mc.width = 734;
				lineDrawing.graphics.clear();
				lineDrawing.graphics.lineStyle(1, 0, 1);
				lineDrawing.graphics.moveTo(0,titleText_mc.height+10); 
				lineDrawing.graphics.lineTo(wb.width, titleText_mc.height + 10);
				next.x = (wb.x + wb.width) - (next.width + 10);
				next.y = (wb.y + wb.height) - (next.height + 10);
				//trace(titleText_mc.textWidth);
				titleText_mc.x = (wb.x + wb.width - titleText_mc.textWidth)/2;
			
			next.buttonMode = true;
			next.useHandCursor = true;
			//TweenMax.to(next, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );

			/*var nColor:Number = parseInt("0000000", 16);
			boundingBox.x = wb.x - 4;
			boundingBox.y = wb.y -4;
			boundingBox.width = wb.width + 8;
			boundingBox.height = wb.height +8;
			TweenMax.to(boundingBox, 0, { tint:nColor } );	*/
			//TweenMax.to(boundingBox, .25 , { glowFilter: { color:nColor, alpha:1, blurX:20, blurY:15 , strength:2, quality:3 }} );
			for (var i:uint = 0; i < feedbackContainer.numChildren; i++) 
			{ 
				var mc:DisplayObject = DisplayObject(feedbackContainer.getChildAt(i)); 
				if (i < 1)
				{
					TweenMax.to(mc, .5, {alpha:1} );
				}
				else 
				{
					
					TweenMax.to(mc, .5, { delay: .6, alpha:1} );
				}
			}
			feedbackContainer.visible = true;
			TweenMax.to(feedbackContainer, .25, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			//feedbackContainer.x = (stage.stageWidth - feedbackContainer.width + (0 / 2)) / 2;
			feedbackContainer.x = (768 - wb.width) / 2;
			//feedbackContainer.y = 0 + (432 - feedbackContainer.height)/2;
			feedbackContainer.y = 0 + (432 - wb.height) / 2;
			
			
		}
		private function doCloseFeedback(e:MouseEvent):void
		{
			var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
			for (var i:int = feedback.numChildren-1; i>=0; i--)
			{
				var mc:DisplayObject = DisplayObject(feedback.getChildAt(i)); 
				if (i < 1)
				{
					TweenMax.to(mc, .5, { delay: .6, alpha:0, onComplete:feedBackRemoved, onCompleteParams:[feedback]} );
				}
				else 
				{
					
					TweenMax.to(mc, .5, { delay: .3, alpha:0} );
				}
			}
		}
		public function feedBackRemoved(feedback:MovieClip):void 
		{
			
			if (this.getChildByName("feedback"))
			{
				var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
				this.removeChild(feedback);
			}
			
		}
	}
	
}