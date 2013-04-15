package com.Amtrak.ICE.components
{
	import com.greensock.TweenMax;
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.components.CheckBoxChoice;
	import com.Amtrak.ICE.components.RadioChoice;
	import com.Amtrak.ICE.components.RadioImage;
	import com.Amtrak.ICE.Evaluation;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import com.Amtrak.ICE.MediaLoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class multipleChoiceMultipleSelect extends Evaluation implements IEvaluationDisplayable
	{
		private var checkboxButtons:Array;
		private var checkbox:myPrimeCheckBox;
		private var userSelection:Array;
		private var multimediaSource:String;
		private var loaded:Boolean = false;
		private var elemSpacer:Object = new Object();
		
		public function multipleChoiceMultipleSelect(xml:XML = null):void
		{
			checkboxButtons = new Array();
			multimediaSource = xml.multimedia.@src;
			userSelection = new Array();
			//!! DO STUFF BEFORE THE SUPER CALL
			super(xml);	
			
		}
		public function doSomething(e:Event):void 
		{
			e.target.content.addEventListener("ASSET_READY", updateExternalContent);
			e.target.content.init();
			e.target.content.addEventListener("EVALUATE_ASSET", synchExternalAssetForEvaluation);
		}
		public function synchExternalAssetForEvaluation(e:Event):void
		{
			var tmp:Array = new Array();
			tmp = e.target.choiceArray;
			for (var i:Number = 0; i < tmp.length; i++)
			{
				if (tmp[i].selected == true)
				{
					var selection:Object = new Object();
					selection = tmp[i];
					selection.valueId = choiceList[i].value;
					choiceList[i].text = selection.text.text; 
					selection.Data = choiceList[i].text;
					userSelection.push(selection);
				}
			}
			
			evaluate();
		}
		public function updateExternalContent(e:Event):void
		{
			var tmp:Array = new Array();
			tmp = e.target.choiceArray;
			
		/*	var tf:TextFormat = new TextFormat();
			tf.font = FontManager.segoeBold.fontName;
            tf.size = 14;*/
			for (var i:Number = 0; i < tmp.length; i++)
			{
				if (dependentData.length > 0 && dependentData[0]!=null)
				{
					if (dependentData[i].answerData)
					{
						tmp[i].text.text = dependentData[i].answerData;
					}
					else
					{
						tmp[i].text.text = "no data ";
					}
				}
				else
				{
					tmp[i].text.text = choiceList[i].text;
				}
				/*tmp[i].text.embedFonts = true;
				tmp[i].text.antiAliasType = "advanced";
				tmp[i].text.sharpness = -300;
				tmp[i].text.thickness = -50;
				tmp[i].text.setTextFormat(tf);*/
			}
			e.target.titleText_mc.text = titleText;
			e.target.instructionText_mc.defaultTextFormat = FontManager.instructionTextFormat;
			e.target.instructionText_mc.text = instructionText;
			e.target.questionText_mc.text = questionText;
		}
		private function displayDesign():void 
		{
			var bgClip:MovieClip = new MovieClip();
			addChild(bgClip);
			var ml2:MediaLoader = new MediaLoader();
			ml2.loadMedia(multimediaSource);
			//ml2.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, doSomething);
			ml2.loader.addEventListener(Event.COMPLETE, doSomething);
			bgClip.addChild(ml2);
		}
		private function buildTitle(bgClip:MovieClip):void
		{
			//Title Text:
			titleText_mc = new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			titleText_mc.embedFonts = true;
            titleText_mc.defaultTextFormat = FontManager.titleTextFormatWhite;
			titleText_mc.text = titleText;
			bgClip.addChild(titleText_mc);
			titleText_mc.x = (this.width - titleText_mc.width) / 2;
			titleText_mc.y = 9;
			titleText_mc.alpha = 0;
			transitionManager.push(titleText_mc);
			
		}
		private function buildInstruction(bgClip:MovieClip):void 
		{
			//Instruction Text:			
			instructionText_mc = new TextField();
			instructionText_mc.autoSize = TextFieldAutoSize.LEFT;
            instructionText_mc.background = false; //use true for doing generic labels
            instructionText_mc.border = false;      // ** same
			instructionText_mc.embedFonts = true;
			instructionText_mc.antiAliasType = "advanced";
			instructionText_mc.sharpness = -300;
			instructionText_mc.thickness = -50;
            instructionText_mc.defaultTextFormat = FontManager.instructionTextFormatWhite;
			instructionText_mc.htmlText = instructionText;
			bgClip.addChild(instructionText_mc);
			instructionText_mc.x = (this.width - instructionText_mc.width) / 2;
			instructionText_mc.y = 44;
			transitionManager.push(instructionText_mc);
		}
		private function buildQuestion(bgClip:MovieClip):void 
		{
			//QuestionBox:
			var questionWhiteBox:whiteBox = new whiteBox();
			questionWhiteBox.width = 747;
			questionWhiteBox.x = (this.width - questionWhiteBox.width) / 2;
			if (instructionText_mc.text != "" )
			{
				questionWhiteBox.y = instructionText_mc.y + 30;
			}
			else 
			{
				questionWhiteBox.y = 44;
			}
			bgClip.addChild(questionWhiteBox);
			questionWhiteBox.alpha = 0;
			transitionManager.push(questionWhiteBox);
			//Question Text:
			questionText_mc = new TextField();
			questionText_mc.autoSize = TextFieldAutoSize.LEFT;
            questionText_mc.background = false; //use true for doing generic labels
            questionText_mc.border = false;      // ** same
			questionText_mc.embedFonts = true;
			questionText_mc.antiAliasType = "advanced";
			questionText_mc.sharpness = -300;
			questionText_mc.thickness = -50;
			questionText_mc.wordWrap = true;
			questionText_mc.width = questionWhiteBox.width - 8;
			var format3:TextFormat = new TextFormat();
            format3.font = FontManager.segoe.fontName;
            format3.color = 0x000000;
            format3.size = 14;
            format3.underline = false;
            questionText_mc.defaultTextFormat = format3;
			questionText_mc.htmlText = questionText;
			questionText_mc.x = questionWhiteBox.x + 4;
			questionText_mc.y = questionWhiteBox.y + 2;
			questionWhiteBox.height = questionText_mc.height + 4;
			elemSpacer.y = questionWhiteBox.y + questionWhiteBox.height;
			elemSpacer.x = questionWhiteBox.x;
			bgClip.addChild(questionText_mc);
			TweenMax.to(questionWhiteBox, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			questionText_mc.alpha = 0;
			transitionManager.push(questionText_mc);
		}
		private function handleDefaults():Boolean
		{
			if (hotspot)
			{
				multiMedia = false;
				layout = "horizontal";
			}
			
			if (design)
			{
				multiMedia = false;
				layout = "vertical";
				randomize = false;
				displayDesign();
				return false;
			}
			
			else return true;
		}
		private function addMultimedia(bgClip:MovieClip, choicesBox:MovieClip):void
		{
			var ml:MediaLoader = new MediaLoader();
				ml.loadMedia(multimediaSource);
				//ml.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, multimediaLoaded);
				ml.loader.addEventListener(Event.COMPLETE, multimediaLoaded);
				//ml.height = 260;
				//ml.width = 230;
				//bgClip.addChild(ml);
				elemSpacer.ml = ml;
				//elemSpacer.choicesBox = choicesBox;
				elemSpacer.bgClip = bgClip;
				//transitionManager.push(ml);
		}
		private function buildChoices(bgClip:MovieClip):void 
		{
			//ChoicesBox:
			/*var choicesBox:whiteBox = new whiteBox();
			choicesBox.name = "choiceBox";
			choicesBox.width = 747;
			choicesBox.x = elemSpacer.x;
			choicesBox.y = elemSpacer.y + 30;
			bgClip.addChild(choicesBox);
			elemSpacer.bgClip = bgClip;
			elemSpacer.choicesBox = choicesBox;
			addEventListener("choicesPositioned", positionChoices);
			//Handle graphical display
			if (multiMedia)
			{
				
				addMultimedia(bgClip, choicesBox);
			}
			else
			{
				choicesBox.y = elemSpacer.y + 30;
				dispatchEvent(new Event("choicesPositioned"));
			}*/
			
		//bgClip.addChild(choicesBox);
			elemSpacer.bgClip = bgClip;
			//elemSpacer.choicesBox = choicesBox;
			
			addEventListener("multimediaPositioned", positionChoices);
			
			if (multiMedia)
			{
				
				addMultimedia(bgClip, bgClip);
			}
			else
			{
				//choicesBox.y = elemSpacer.y + 30;
				dispatchEvent(new Event("multimediaPositioned"));
			}
			
			
			//transitionManager.push(choicesBox);
		}
		
		public function multimediaLoaded(e:Event):void
		{
			//VICIOUS HACK!
			/*var width:Number = e.target.content.width;
			var height:Number = e.target.content.height;
			
			var ml:MediaLoader = elemSpacer.ml;
			var choicesBox:MovieClip = elemSpacer.choicesBox;
			var bgClip:MovieClip = elemSpacer.bgClip;
				if (layout == "vertical" || layout == "horizontal")
				{
					ml.x = choicesBox.x + (bgClip.width - width) / 2;
					ml.y = questionText_mc.y + questionText_mc.height + 10;
					choicesBox.y = ml.y + height + 5;
				}
				else 
				{*/
				/*	var part:Number = choicesBox.width / 2;
					var eW:Number = width;
					var eX:Number = (part + eW) / 2 - eW;
					choicesBox.y = elemSpacer.y + 10;
					choicesBox.width /= 2;
					if (layout == "splitScreenRight")
					{
						ml.x = eX + part;
						ml.y = choicesBox.y;
					}
					else if (layout == "splitScreenLeft")
					{
						ml.x = questionText_mc.x;
						ml.y = elemSpacer.y + 10;
						//choicesBox.x = eX + part - 30;
					}*/
					
					
				//}
				dispatchEvent(new Event("multimediaPositioned"));
		}
		public function positionChoices(e:Event):void 
		{
			var bgClip:MovieClip = elemSpacer.bgClip;
			//var choicesBox:MovieClip = elemSpacer.choicesBox;
			
			if (randomize)
			{
				choiceList = randomizeArray(choiceList);
			}
			//Choice Text:
			if (layout == "vertical" || layout == "splitScreenLeft" || layout == "splitScreenRight")
			{
			var prevHeight:Number = 0;
			var totalHeight:Number = 0;
			for (var i:Number = 0; i < choiceList.length; i++)
			{
				var tmp:MovieClip = new MovieClip();
					tmp = new CheckBoxChoice(choiceList[i].text);
					tmp.RadioButtonInstance.addEventListener(MouseEvent.CLICK, handleCheckboxSelectionClick);
					tmp.buttonMode = true;
					//tmp.x = choicesBox.x + 6;
					tmp.y = prevHeight + 10;
					prevHeight = tmp.y + tmp.height;
					totalHeight += tmp.height + 10;
					tmp.name = "radio_" + i;
					tmp.id = choiceList[i].id;
					tmp.valueId = choiceList[i].value;
					bgClip.addChild(tmp);
					//tmp.alpha = 0;
					checkboxButtons.push(tmp);
					if (multiMedia)
					{
						tmp.ChoiceTextLength = 432;
						//tmp.x = tmp.x + 240;
					}
			}
			var pT:primeTable = new primeTable(checkboxButtons);
			if (multiMedia)
			{
				pT.addMediaLeft(elemSpacer.ml);
			}
			bgClip.addChild(pT);
			pT.x = elemSpacer.x;
			pT.y = elemSpacer.y + 10;
			TweenMax.to(pT, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );

			
				
			}
			else //must be horizontal layout... right?
			{
				var newColorTransform:ColorTransform = new ColorTransform();
				var partition:Number = questionText_mc.width / choiceList.length;
				//elemWidth is hardcoded here to be capped at 134 with text + button
				var elemWidth:Number = 170;
				var elemX:Number = (partition + elemWidth)/2 - elemWidth;
				for (var j:Number = 0; j < choiceList.length; j++)
				{
					var tmp2:MovieClip = new MovieClip;
					newColorTransform.color  = (j % 2 != 0) ? 0xDFE2E7 : 0xB9C6D5;
						if (!hotspot)
						{
							tmp2 = new CheckBoxChoice(choiceList[j].text);
							tmp2.ChoiceTextLength = 100;
							tmp2.RadioButtonInstance.addEventListener(MouseEvent.CLICK, handleCheckboxSelectionClick);
						}
						else
						{
							//choicesBox.visible = false;
							tmp2 = new CheckBoxImage(choiceList[j].text);
							tmp2.ml.loadMedia(choiceList[j].text);
							tmp2.RadioButtonInstance.addEventListener(MouseEvent.CLICK, handleCheckboxImageClick);
							tmp2.RadioButtonInstance.useHandCursor = true;
							tmp2.setColor(newColorTransform);
							TweenMax.to(tmp2, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
							elemX += 5;
						}
					
					
					tmp2.x = elemX;
					tmp2.y = questionText_mc.y + questionText_mc.height + 16;
					tmp2.name = "radio_" + j;
					tmp2.id = choiceList[j].id;
					tmp2.valueId = choiceList[j].value;
					elemX = partition + elemX;
					bgClip.addChild(tmp2);
					checkboxButtons.push(tmp2);
				}
			}
			
			
			
		}
		private function buildSubmit(bgClip:MovieClip):void 
		{
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
			submit.mouseChildren = false;
			//submit.buttonMode = true;
			submit.useHandCursor = true;
			submit.x = this.width - (submit.width + 10);
			submit.y = this.height - (submit.height + 10);
			bgClip.addChild(submit);
			TweenMax.to(submit, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );
			transitionManager.push(submit);
		}
		public function displayAfterDynamicContent(e:Event):void
		{
			if (dependentData)
			{
				for (var i:uint = 0; i < dependentData.length; i++)
				{
					//trace(dependentData[i].answerID + " : " + dependentData[i].answerData);
					var choiceObject:Object = new Object();
					choiceObject.id = "c" + (i+1).toString();
					choiceObject.value = "v1";
					choiceObject.text = dependentData.answerData;
					choiceList.push(choiceObject);
				}
			}
			displayInterface();
		
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
			if (!handleDefaults())
			{
				return;
			}
			
			//Add BG 
			var background_mc:bg = new bg();
			background_mc.alpha = 0;
			addChild(background_mc);
			transitionManager.push(background_mc);
			
			buildTitle(background_mc);
			buildInstruction(background_mc);
			buildQuestion(background_mc);
			buildChoices(background_mc);
			buildSubmit(background_mc);		
			
			doTransitionIn();
			
			
			
				
		}
		public function doTransitionIn():void
		{
			for (var i:uint = 0; i < transitionManager.length; i++)
			{
				if (transitionManager[i].name == "choiceBox")
				{
					TweenMax.to(transitionManager[i], .75, { delay: i * .0, alpha:1, onComplete:fadeInChoices, onCompleteParams:[5]} );
				}
				else
				{
					if (i != transitionManager.length - 1)
					{
						TweenMax.to(transitionManager[i], .75, { delay: i * .0, alpha:1 } );
					}
					initialized = true;
				}
				
			}
		}
		public function fadeInChoices(param1:Number):void
		{
			for (var i:uint = 0; i < checkboxButtons.length; i++)
			{
				if (i < checkboxButtons.length - 1)
				{
					TweenMax.to(checkboxButtons[i], .75, { alpha:1 } );
				}
				else
				{
					TweenMax.to(checkboxButtons[i], .75, { alpha:1, onComplete:fadeInButton, onCompleteParams:[5] } );
				}
			}
		}
		public function fadeInButton(param1:Number):void
		{
			
			TweenMax.to(transitionManager[transitionManager.length-1], .75, { delay:.6,alpha:1} );
			initialized = true;
		}
		public function activateInterface(param1:Number):void 
		{
			transitionManager[transitionManager.length - 1].buttonMode = true;
			transitionManager[transitionManager.length-1].addEventListener(MouseEvent.CLICK, handleEvaluation);
		}
		public function deactivateInterface(param1:Number):void 
		{
			transitionManager[transitionManager.length - 1].buttonMode = false;
			transitionManager[transitionManager.length-1].removeEventListener(MouseEvent.CLICK, handleEvaluation);
		}
		override public function evaluate():void
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			if (userSelection.length == 0)
			{
				tmp.title = "Not Enough Information Supplied!";
				tmp.text = "You have not fulfilled the requirements for completing this interaction. Please check the screen instructions for more information. Click OK to continue."; 
				tmp.value = false;
				tmp.windowType = "CAUTION";
				dispatchEvent(new FeedbackEvent(tmp));
				return;
			}
			var isCorrect:Boolean = false;
			var correctCount:Number = 0;
			var correctAnswerList:Array = new Array();
			var selectionCount:Number = userSelection.length;
			for (var i:Number = 0; i < choiceList.length; i++)
			{
				for (var j:Number = 0; j < valueList.length; j++)
				{
					if (choiceList[i].value == valueList[j].id && valueList[j].text == "true")
					{//Found w/e was listed as TRUE in the Choice List
						//trace("Choice Value = " + choiceList[i].value);
						correctCount++;
						correctAnswerList.push(choiceList[i]);
					}
				}
				
			}
		    
			if(correctAnswerList.length == userSelection.length)
			{
				isCorrect = compareValues(correctAnswerList, userSelection);
			}
				
			evalData = evalData as Array;
			evalData = new Array();
			/************* FIX FOR BACKEND 1/6/11 **************************/
		    var temp2:Object = new Object();
			var temp:Array = new Array();
			for (var a:* in userSelection)
			{
				//trace("Answer ID: " + userSelection[a].id +  "\nanswerText : " +userSelection[a].Data);
				//trace(steps[stepNumber].component.evalData[i].Data);
				evalData.push( { "answerID":userSelection[a].id, "answerData":userSelection[a].Data } );
				/*var answer:String = userSelection[a].id;
				answer = answer.slice(1,answer.length);
				var num:uint = parseInt(answer);
				answer = String.fromCharCode(num + 64);
				temp.push(answer);*/
			}
			/*temp2.answerID = "c1";
			temp2.answerData = temp;
			evalData.push(temp2);*/
			
			//evalData = userSelection;

			//Currently only correct and incorrect feedback supported for multiple choice w/ checkbox
			if (feedbackList.length > 0)
			{
				for (var x:Number = 0; x < feedbackList.length; x++)
				{
					
						//trace(feedbackList[x].value + "\n" + feedbackList[x].text);
						
						if (isCorrect && feedbackList[x].value == correctAnswerList[0].value)
						{
							tmp.text = this.feedbackList[x].text;
							tmp.value = this.feedbackList[x].value;
							break;
						}
						else if(!isCorrect && feedbackList[x].value != correctAnswerList[0].value)
						{
							tmp.text = this.feedbackList[x].text;
							tmp.value = this.feedbackList[x].value;
							break;
						}
				}
				tmp.windowType = "EVALUATION";
				dispatchEvent(new FeedbackEvent(tmp));						
			}
			else
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
			}
			
		}
		
		public function handleCheckboxImageClick(e:MouseEvent):void
		{
			
			for (var i:Number = 0; i < checkboxButtons.length; i++)
			{
				
				if (checkboxButtons[i].RadioButtonInstance.name == e.target.name)
				{
					if (checkboxButtons[i].Selected == false)
					{
						checkboxButtons[i].State = "_on";
						checkboxButtons[i].Selected = true;
						userSelection.addItem(checkboxButtons[i]);
						enabled = true;
					}
					else
					{
						checkboxButtons[i].State = "_up";
						checkboxButtons[i].Selected = false;
						userSelection.removeItemAt(userSelection.getItemIndex(checkboxButtons[i]));
					}
				}
			}		
			if (userSelection.length > 0)
			{
				activateInterface(1);
			}
			else
			{
				deactivateInterface(1);
			}
		}
		public function handleCheckboxSelectionClick(e:MouseEvent):void 
		{
			for (var i:Number = 0; i < checkboxButtons.length; i++)
			{
				
				if (checkboxButtons[i].RadioButtonInstance.name == e.target.name)
				{
					if (checkboxButtons[i].Selected == false)
					{
						checkboxButtons[i].State = "_on";
						checkboxButtons[i].Selected = true;
						userSelection.addItem(checkboxButtons[i]);
					}
					else
					{
						checkboxButtons[i].State = "_up";
						checkboxButtons[i].Selected = false;
						userSelection.removeItemAt(userSelection.getItemIndex(checkboxButtons[i]));
					}
				}
			}	
			if (userSelection.length > 0)
			{
				activateInterface(1);
			}
			else
			{
				deactivateInterface(1);
			}
			
		}
		public function compareValues(cA:Array, uA:Array):Boolean
		{
			for (var i:uint = 0; i < uA.length; i++)
			{
				if ( uA[i].valueId !=  cA[i].value)
				{
					return false;
				}
			}
			return true;
		}
	}
	
}