package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.Evaluation
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import fl.controls.ComboBox;
	import fl.controls.TextArea;
	import fl.controls.ScrollPolicy;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class Matching extends Evaluation implements IEvaluationDisplayable
	{
		private var comboBoxes:Array = [];
		private var selectionCount:uint = 0;
		private var background_mc:bg;
		public function Matching(xml:XML = null)
		{	
			super(xml);
		}
		
		
		override public function handleContentLoaded(e:Event):void
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
		public function displayAfterDynamicContent(e:Event):void
		{
			if (dependentData)
			{
				for (var i:uint = 0; i < dependentData.length; i++)
				{
					trace(dependentData[i].answerID + " : " + dependentData[i].answerData);
				}
			}
			displayInterface();
		
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
			background_mc= new bg();
			background_mc.alpha = 0;
			addChild(background_mc);
			TweenMax.to(background_mc, .75, { alpha:1});
			
			if (randomize)
			{
				choiceList = randomizeArray(choiceList);
			}
			
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
			instructionText_mc.antiAliasType = "advanced";
			instructionText_mc.embedFonts = true;
			var format2:TextFormat = new TextFormat();
            format2.font = FontManager.segoeItalic.fontName;
            format2.color = 0xFFFFFF;
            format2.size = 14;
			format2.italic = true;
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
			questionText_mc.antiAliasType = "advanced";
			questionText_mc.sharpness = -300;
			questionText_mc.thickness = - 50;
			questionText_mc.embedFonts = true;
			questionText_mc.wordWrap = true;
			questionText_mc.width = wb.width - 8;
			var format3:TextFormat = new TextFormat();
            format3.font = FontManager.segoe.fontName;
            format3.color = 0x000000;
            format3.size = 14;
            format3.underline = false;
            questionText_mc.defaultTextFormat = format3;
			questionText_mc.text = questionText;
			questionText_mc.x = wb.x + 4;
			questionText_mc.y = wb.y + 2;
			wb.height = questionText_mc.height + 4;
			questionText_mc.alpha = 0;
			wb.height = questionText_mc.height + 4;
			TweenMax.to(wb, .75, { delay:2.0, alpha:1 } );
			TweenMax.to(wb, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			TweenMax.to(questionText_mc, .75, { delay:2.0, alpha:1 } );
			background_mc.addChild(questionText_mc);
			
			var matchingChoices:Array = new Array();
			
			var spacer:Number = wb.y + wb.height + 15;
			for (var i:uint = 0; i < choiceList.length; i++)
			{
				var blah:MovieClip  = new MovieClip();
				
				//var cb:ComboBox = new ComboBox();
				var cb:myPrimeComboBox = new myPrimeComboBox();
				//cb.prompt = "...";
				for (var j:uint = 0; j < valueList.length; j++)
				{
					cb.addItem( { label:String.fromCharCode(j + 65), data:valueList[j].text } );
					if (choiceList[i].value == valueList[j].id)
					{
						choiceList[i].answer = String.fromCharCode(j + 65);
					}
				}
				//cb.x = wb.x + 10;
				//cb.width = 40;
				//cb.y = spacer;
				cb.y = 2;
				cb.name = choiceList[i].id;
				spacer += cb.height + 10;
				//cb.alpha = 0;
				
				
				//background_mc.addChild(cb);
				
				var tf:TextField = new TextField();
					tf.autoSize = TextFieldAutoSize.LEFT;
					tf.background = false; //use true for doing generic labels
					tf.border = false;      // ** same
					tf.embedFonts = true;
					tf.antiAliasType = "advanced";
					tf.wordWrap = true;
					tf.width = 400;
					tf.sharpness = -300;
					tf.thickness = -50;
					tf.defaultTextFormat = format3;
					//tf.y = cb.y;
					//tf.x = cb.x + cb.width + 5;
					tf.text = choiceList[i].text;
					tf.alpha = 0;
					TweenMax.to(cb, .75, { delay: 2.8, alpha:1 } );
					TweenMax.to(tf, .75, { delay: 2.8, alpha:1 } );
				//background_mc.addChild(tf);
				cb.x = 0;
				cb.addEventListener("SELECTION_COMPLETE", incrementSelectionCount);

				tf.x = cb.x + cb.width + 4;
				comboBoxes.push(cb);
				blah.addChild(cb);
				var blahbg:MovieClip = new MovieClip();
				blahbg.graphics.drawRect(0,0,tf.textWidth,tf.textHeight);
				//blahbg.height = tf.textHeight;
				blah.addChild(blahbg);
				blah.addChild(tf);
				//cb.y = ((tf.y + tf.textHeight) / 2 -  (cb.y + cb.height) / 2);
				//trace("line height: " + tf.textHeight);
				if (tf.textHeight > 19)
				{
					cb.y += 6;
				}
				
				
				blah.id = choiceList[i].id;
				//blah.height = tf.height;
				/*trace("cb height: " + cb.height);
				trace("tf height: " + tf.height);
				trace("blah height: " + blah.height);*/
				matchingChoices.push(blah);
				
			}
			
			var pT:primeTable = new primeTable(matchingChoices);
			background_mc.addChild(pT);
			pT.x = questionText_mc.x
			pT.y = questionText_mc.y + questionText_mc.height + 10;
			pT.setWidth(500);
			TweenMax.to(pT, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );

			var prevHeight:Number = 12;
			var valBG:whiteBox = new whiteBox();
			background_mc.addChild(valBG);
			valBG.x = pT.x + pT.width + 10;
			valBG.y = pT.y;
			for (var x:uint = 0; x < valueList.length; x++)
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
					tF.width = 200;
					tF.defaultTextFormat = format3;
					//tF.text = String.fromCharCode(x + 65) + ". " + valueList[x].text;
					tF.text = String.fromCharCode(x + 65)+". ";
					background_mc.addChild(tF);
					tF.y = wb.y + wb.height + (prevHeight );
					tF.x = valBG.x + 10;
					tF.alpha = 0;
					
					var tF2:TextField = new TextField();
					tF2.autoSize = TextFieldAutoSize.LEFT;
					tF2.background = false; //use true for doing generic labels
					tF2.border = false;      // ** same
					tF2.embedFonts = true;
					tF2.antiAliasType = "advanced";
					tF2.sharpness = -300;
					tF2.thickness = -50;
					tF2.wordWrap = true;
					tF2.width = 200;
					tF2.defaultTextFormat = format3;
					//tF.text = String.fromCharCode(x + 65) + ". " + valueList[x].text;
					tF2.text = valueList[x].text;
					background_mc.addChild(tF2);
					tF2.y = wb.y + wb.height + (prevHeight );
					tF2.x = tF.x + tF.textWidth+5;
					tF2.alpha = 0;
					
					
					
					
					TweenMax.to(tF, .75, { delay: 3.2, alpha:1 } );
					TweenMax.to(tF2, .75, { delay: 3.2, alpha:1 } );
					prevHeight += tF2.height + 8.1;
			}
			
			
			valBG.height = prevHeight;
			valBG.width = wb.width - pT.width - 15;
			TweenMax.to(valBG, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );

			
			var submit:greenGlassButton = new greenGlassButton();
			var format4:TextFormat = new TextFormat();
			format4.font = FontManager.bgM.fontName;
            format4.color = 0xFFFFFF;
            format4.size = 22;
			submit.label.embedFonts = true;
			submit.label.defaultTextFormat = format4;
			//submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
			//submit.buttonMode = false;
			submit.mouseChildren = false;
			submit.useHandCursor = true;
			submit.x = this.width - (submit.width + 10);
			submit.y = background_mc.height - (submit.height + 10);
			submit.alpha = 0;
			TweenMax.to(submit, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			TweenMax.to(submit, .75, { delay: 4.0, alpha:1 } );
			background_mc.addChild(submit);
		}
		override public function evaluate():void
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			
			var isCorrect:Boolean = false;
			var correctCount:uint = 0;
			evalData = evalData as Array ;
			evalData = new Array();
			for (var i:uint = 0; i < comboBoxes.length; i++)
			{
				
				if (!comboBoxes[i].selectedItem)
				{
					tmp.title = "Insufficient Information Supplied!";
					tmp.text = "One or more selection boxes remain unanswered";
					tmp.value = false;
					tmp.windowType = "CAUTION";
					dispatchEvent(new FeedbackEvent(tmp));
					return;
				}
				evalData.push( { "answerID":comboBoxes[i].name, "answerData":comboBoxes[i].selectedItem.data } );
				if (comboBoxes[i].selectedItem.label == choiceList[i].answer) 
				{
					correctCount++;
				}
				if (correctCount == choiceList.length)
				{
					isCorrect = true;
				}
			}
			
			
			//Currently only correct and incorrect feedback supported for Matching
			if (feedbackList.length > 0)
			{
				if (isCorrect)
				{
					tmp.text = feedbackList[0].text;
					tmp.value = "v1";
				}
				else
				{
					tmp.text = feedbackList[1].text;
					tmp.value = "v2";
				}
				tmp.windowType = "EVALUATION";
				dispatchEvent(new FeedbackEvent(tmp));						
			}
			else
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
			}
		}
		public function incrementSelectionCount(e:Event):void
		{
			//trace("incrementing");
			selectionCount++;
			if (selectionCount == comboBoxes.length)
			{
				activateInterface();
			}
		}
		public function activateInterface():void
		{
			//trace("activating");
			var tmp:MovieClip = background_mc.getChildAt(background_mc.numChildren - 1) as MovieClip;
			tmp.buttonMode = true;
			tmp.addEventListener(MouseEvent.CLICK, handleEvaluation);
		}
	}
	
}