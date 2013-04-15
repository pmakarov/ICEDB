package com.Amtrak.ICE.components
{
	import com.greensock.TweenMax;
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.Evaluation;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import com.Amtrak.ICE.MediaLoader;
	import com.Amtrak.ICE.components.RadioChoice
	import fl.containers.UILoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.GridFitType;
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
	public class multipleChoiceSingleSelect extends Evaluation implements IEvaluationDisplayable
	{
		private var radioButtons:Array;
		private var userSelection:MovieClip;
		private var multimediaSource:String;
		private var loaded:Boolean = false;
		private var elemSpacer:Object = new Object();
		
		public function multipleChoiceSingleSelect(xml:XML = null):void
		{
			radioButtons = new Array();
			multimediaSource = xml.multimedia.@src;
			//!! DO STUFF BEFORE THE SUPER CALL
			super(xml);	
		}
		
		public function doSomething(e:Event):void 
		{
			
			e.target.content.addEventListener("ASSET_READY", updateExternalContent);
			e.target.content.init();
			e.target.content.addEventListener("EVALUATE_ASSET", synchExternalAssetForEvaluation);
			dispatchEvent(new Event("ASSET_LOADED"));
		}
		public function handleCustomFeedbackState():void
		{
			if (design == true)
			{
				var db:MovieClip = this.getChildByName("designBox") as MovieClip;
				var l:MediaLoader = db.getChildByName("loader") as MediaLoader;
				var mc:MovieClip = l.loader.content as MovieClip;
				var fO:Object = new Object();
				fO.id = userSelection.id;
				var bool:Boolean = (userSelection.valueId == "v1") ? true : false;
				fO.correct = bool;
				var num:int;
				for (var i:int = 0; i < choiceList.length; i++)
				{
					//trace("Gotta like it: " + choiceList[i].value  + " : " + feedbackList[num].value);
					if (choiceList[i].value == userSelection.valueId)
					{
						num = i;
						//trace("do shit to: " + mc.choiceArray[num].name + " : " + mc.choiceArray[num].id);
						break;
					}
				}
				//trace(feedbackList[num].value);
				mc.processCustomFeedback(num);
			}
			else
			{
				//trace("handling custom amtrak feedback for evalObject");
				unlockControls();
				
				userSelection.alpha = .5;
				userSelection.buttonMode = false;
				userSelection.mouseChildren = false;
				userSelection.mouseEnabled = false;
			}


		}
		public function handleCustomHighlightState(value:String):void
		{
			var num:int = 0;
			if (design == true)
			{
				var db:MovieClip = this.getChildByName("designBox") as MovieClip;
				var l:MediaLoader = db.getChildByName("loader") as MediaLoader;
				var mc:MovieClip = l.loader.content as MovieClip;
				var tmp:Array = mc.choiceArray;
				//trace("do shit to: " + mc.choiceArray[num].name + " : " + mc.choiceArray[num].id);
				for (var a:int = 0; a < tmp.length; a++)
				{
					tmp[a].gotoAndStop(1);
					TweenMax.to(tmp[a], 0, { glowFilter: { remove:true }} );
					//tmp[a].alpha = .33;
					tmp[a].buttonMode = false;
					tmp[a].mouseChildren = false;
					tmp[a].mouseEnabled = false;
				}
				for (var i:int = 0; i < choiceList.length; i++)
				{
					//TweenMax.to(mc.choiceArray[i], 0, {glowFilter:{remove:true}});
					if (choiceList[i].value == value)
					{
						num = i;
						//trace("do shit to: " + mc.choiceArray[num].name + " : " + mc.choiceArray[num].id);
						break;
					}
				}
					//trace(feedbackList[num].value);
					mc.processCustomFeedback(num);
					mc.choiceArray[num].gotoAndStop("_disabled");
					//TweenMax.to(mc.choiceArray[num], .6, {glowFilter: {color: 0xFF0000, alpha: 1, blurX: 10, blurY: 210, strength: 3, quality: 3}});
			}
			else
			{
				for (var j:int = 0; j < choiceList.length; j++)
				{
					//trace("Gotta like it: " + choiceList[i].value  + " : " + feedbackList[num].value);
					TweenMax.to(radioButtons[j], 0, {glowFilter:{remove:true}});
					if (choiceList[j].value == value)
					{
						//trace("do shit to: " + mc.choiceArray[num].name + " : " + mc.choiceArray[num].id);
						num = j;

					}
				}

				TweenMax.to(radioButtons[num], .6, {glowFilter: {color: 0xFF7D7D, alpha: 1, blurX: 25, blurY: 25, strength: 2.45, quality: 1}});

			}
		}
		public function synchExternalAssetForEvaluation(e:Event):void
		{
			var tmp:Array = new Array();
			tmp = e.target.choiceArray;
			for (var i:Number = 0; i < tmp.length; i++)
			{
				if (tmp[i].selected == true)
				{
					//trace(tmp[i].name);
					var selection:Object = new Object();
					selection = tmp[i];
					selection.valueId = choiceList[i].value;
					choiceList[i].text = selection.text.text; 
					selection.Data = choiceList[i].text;
					userSelection = tmp[i];
					userSelection.valueId = selection.valueId;
					userSelection.Data = choiceList[i].text;
					tmp[i].selected = false;
				}
			}
			
			evaluate();
		}
		public function updateExternalContent(e:Event):void
		{
			var tmp:Array = new Array();
			tmp = e.target.choiceArray;
			
			/*var tf:TextFormat = new TextFormat();
			tf.font = FontManager.segoeBold.fontName;
            tf.size = 14;*/
			for (var i:Number = 0; i < tmp.length; i++)
			{
				if (dependentData.length > 0 && dependentData[0]!=null)
				{
					if (dependentData[i])
					{
						tmp[i].text.text = dependentData[i].answerData;
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
			//e.target.instructionText_mc.defaultTextFormat = FontManager.instructionTextFormat;
			e.target.instructionText_mc.text = instructionText;
			e.target.questionText_mc.text = questionText;
		}
		private function displayDesign():void 
		{
			var bgClip:MovieClip = new MovieClip();
			addChild(bgClip);
			var ml2:MediaLoader = new MediaLoader();
			ml2.loadMedia(multimediaSource);
			/* TODO: Create DECORATOR */
			//ml2.Width = 1020;
			ml2.Width = 721;
			//ml2.Height = 706;
			ml2.Height = 405;
			//ml2.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, doSomething);
			ml2.name = "loader";
			ml2.loader.addEventListener(Event.COMPLETE, doSomething);
			bgClip.name = "designBox";
			bgClip.addChild(ml2);
		}
		private function buildTitle(bgClip:MovieClip):void
		{
			//Title Text:
			titleText_mc = new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			//titleText_mc.embedFonts = true;
            //titleText_mc.defaultTextFormat = FontManager.titleTextFormatWhite;
			titleText_mc.text = titleText;
			
			bgClip.addChild(titleText_mc);
			titleText_mc.x = (this.width - titleText_mc.width) / 2;
			titleText_mc.y = 9;
			//HACK for AMTRAK 5/22/2012
			titleText_mc.visible = false;
			transitionManager.push(titleText_mc);
		}
		private function buildInstruction(bgClip:MovieClip):void 
		{
			//Instruction Text:			
			instructionText_mc = new TextField();
			instructionText_mc.autoSize = TextFieldAutoSize.LEFT;
            instructionText_mc.background = false; //use true for doing generic labels
            instructionText_mc.border = false;      // ** same
			//instructionText_mc.embedFonts = true;
			instructionText_mc.antiAliasType = "advanced";
			instructionText_mc.sharpness = -300;
			instructionText_mc.thickness = -50;
            //instructionText_mc.defaultTextFormat = FontManager.instructionTextFormatWhite;
			instructionText_mc.htmlText = instructionText;
			bgClip.addChild(instructionText_mc);
			instructionText_mc.x = (this.width - instructionText_mc.width) / 2;
			instructionText_mc.y = 44;
			//HACK for Amtrak 5/22/2012
			instructionText_mc.visible = false;
			transitionManager.push(instructionText_mc);
		}
		private function buildQuestion(bgClip:MovieClip):void 
		{
			//QuestionBox:
			var questionWhiteBox:whiteBox = new whiteBox();
			questionWhiteBox.width = 500;
			questionWhiteBox.x = 0;
			questionWhiteBox.y = 0;
			bgClip.addChild(questionWhiteBox);
			transitionManager.push(questionWhiteBox);
			
			//Question Text:
			questionText_mc = new TextField();
			questionText_mc.autoSize = TextFieldAutoSize.LEFT;
            questionText_mc.background = false; //use true for doing generic labels
            questionText_mc.border = false;      // ** same
			questionText_mc.embedFonts = true;
			questionText_mc.antiAliasType = "advanced";
			questionText_mc.gridFitType = GridFitType.PIXEL;
			//questionText_mc.sharpness = -300;
			//questionText_mc.thickness = -50;
			questionText_mc.wordWrap = true;
			questionText_mc.width = questionWhiteBox.width - 8;
            questionText_mc.defaultTextFormat = FontManager.QuestionTextFormatWhite;
			questionText_mc.htmlText = questionText;
			questionText_mc.x = questionWhiteBox.x + 8;
			questionText_mc.y = questionWhiteBox.y + 5;
			questionWhiteBox.height = questionText_mc.height + 16;
			questionWhiteBox.width = questionText_mc.textWidth + 26;
			TweenMax.to(questionWhiteBox, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			elemSpacer.y = questionWhiteBox.y + questionWhiteBox.height;
			elemSpacer.x = questionWhiteBox.x;
			bgClip.addChild(questionText_mc);
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
				bgClip.addChild(ml);
				elemSpacer.ml = ml;
				elemSpacer.choicesBox = choicesBox;
				elemSpacer.bgClip = bgClip;
				transitionManager.push(ml);
		}
		private function buildChoices(bgClip:MovieClip):void 
		{
			elemSpacer.bgClip = bgClip;
			
			addEventListener("multimediaPositioned", positionChoices);
			
			dispatchEvent(new Event("multimediaPositioned"));
		
			
		}
		
		public function multimediaLoaded(e:Event):void
		{
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
			
			
			var prevHeight:Number = questionText_mc.y + 90;
			var totalHeight:Number = 0;
			
			for (var i:Number = 0; i < choiceList.length; i++)
			{
				var tmp:RadioChoice = new RadioChoice(choiceList[i].text);
				tmp.addEventListener(MouseEvent.CLICK, handleRadioSelectionClick);
				tmp.buttonMode = true;
				tmp.mouseChildren = true;
				//tmp.x = choicesBox.x + 6;
				tmp.y = prevHeight + 20;
				prevHeight = tmp.y + tmp.height;
				totalHeight += tmp.height + 10;
				tmp.name = "radio_" + i;
				tmp.id = choiceList[i].id;
				tmp.valueId = choiceList[i].value;
				bgClip.addChild(tmp);
				//tmp.alpha = 0;
				radioButtons.push(tmp);
				TweenMax.to(tmp, .15, { dropShadowFilter: { color:0x222222, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );

					
			}
		
			

			
			
		}
		private function buildSubmit(bgClip:MovieClip):void 
		{
			var submit:greenGlassButton = new greenGlassButton();
			var format4:TextFormat = new TextFormat();
			//format4.font = FontManager.bgM.fontName;
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
		public function displayInterface():void 
		{
			if (!handleDefaults())
			{
				return;
			}
			
			//Add BG 
			var background_mc:bg = new bg();
			if (customBG != "")
			{
				var l:UILoader = new UILoader();
				try
				{
					l.load(new URLRequest(customBG));
					l.width = 721;
					l.height = 405;
					background_mc.addChild(l);
				}
				catch (error:SecurityError)
				{
					trace("A SecurityError has occurred.");
				}

				
				
			}
			
			//background_mc.alpha = 0;
			addChild(background_mc);
			transitionManager.push(background_mc);
			
			buildTitle(background_mc);
			buildInstruction(background_mc);
			buildQuestion(background_mc);
			buildChoices(background_mc);
			//buildSubmit(background_mc);		
			
			dispatchEvent(new Event("ASSET_LOADED"));
			
			for (var i:uint = 0; i < transitionManager.length; i++)
			{
				
				if (transitionManager[i].name == "choiceBox")
				{
					TweenMax.to(transitionManager[i], .75, { delay: i * .01, alpha:1, onComplete:fadeInChoices, onCompleteParams:[5]} );
				}
				else
				{
					if (i != transitionManager.length - 1)
					{
						TweenMax.to(transitionManager[i], .75, { delay: i * .6, alpha:1 } );
					}
					
				}
				
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
		override public function stop():void
		{
			if (this.getChildByName("audio"))
			{
				MediaLoader(this.getChildByName("audio")).stopSound();
				this.removeChild(this.getChildByName("audio"));
				
			}
			
			if (this.getChildByName("loader"))
			{
				MediaLoader(this.getChildByName("loader")).clearMedia();
			}
		}
		
		public function fadeInChoices(param1:Number):void
		{
			for (var i:uint = 0; i < radioButtons.length; i++)
			{
				if (i < radioButtons.length - 1)
				{
					TweenMax.to(radioButtons[i], .75, { alpha:1 } );
				}
				else
				{
					TweenMax.to(radioButtons[i], .75, { alpha:1, onComplete:fadeInButton, onCompleteParams:[5] } );
				}
			}
		}
		public function fadeInButton(param1:Number):void
		{
			
			//TweenMax.to(transitionManager[transitionManager.length-1], .75, { delay:.6,alpha:1, onComplete:activateInterface, onCompleteParams:[5]} );
			TweenMax.to(transitionManager[transitionManager.length-1], .75, { delay:.6,alpha:1} );
			
		}
		public function activateInterface(param1:Number):void 
		{
			transitionManager[transitionManager.length - 1].buttonMode = true;
			transitionManager[transitionManager.length-1].addEventListener(MouseEvent.CLICK, handleEvaluation);
		}
		override public function evaluate():void
		{
			var tmp:Object = new Object();
			tmp.title = titleText;
			if (userSelection == null)
			{
				tmp.title = "Not Enough Information Supplied!";
				tmp.text = "You have not fulfilled the requirements for completing this interaction. Please check the screen instructions for more information. Click OK to continue."; 
				tmp.value = false;
				tmp.windowType = "CAUTION";
				dispatchEvent(new FeedbackEvent(tmp));
				return;
			}
			var isCorrect:Boolean = false;
			var correctCount:Number = 1;
			var selectionCount:Number = 0;
			for (var i:int = 0; i < choiceList.length; i++)
			{
				for (var j:int = 0; j < valueList.length; j++)
				{
					if (choiceList[i].value == valueList[j].id && valueList[j].text == "true")
					{//Found w/e was listed as TRUE in the Choice List
						//trace(choiceList[i].value + " : " + radioButtons[i].id);
						correctCount++;
						if (userSelection.id == choiceList[i].id)
						{
							isCorrect = true;
							break;
						}
						 
					}
				}
			}
			evalData = evalData as Array ;
			evalData = new Array();
			evalData.push({ "answerID":userSelection.id,"answerData":userSelection.Data});
			
			//added for Amtrak:
			lockControls();
			
			if (feedbackList.length > 0)
			{
				for (var x:int = 0; x < feedbackList.length; x++)
				{
					if (feedbackList[x].value == userSelection.valueId)
					{
						tmp.text = this.feedbackList[x].text;
						tmp.value = this.feedbackList[x].value;
						tmp.audio = this.feedbackList[x].audio;
						tmp.video = this.feedbackList[x].video;
						
						switch(scoreType)
						{
							case "default":
							tmp.windowType = "EVALUATION";
							break;
							
							case "noScore":
							trace("**************************** " + scoreType + " BYYYYAAAAAAAAAAAAAAAAAAAAAAAH");
							tmp.windowType = "NO_SCORE";
							tmp.value = false;
							break;
							
							case "summative":
							tmp.windowType = "SUM";
							break;
							
						default:
							//tmp.windowType = "EVALUATION";
							break;
						}
						dispatchEvent(new FeedbackEvent(tmp));
					}
				}
				
			}
			else
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
			}
			
			
			remainingAttempts--;
		}
		
		public function handleRadioSelectionClick(e:MouseEvent):void
		{
			var mc:MovieClip = e.target.parent.parent as MovieClip;
			for (var i:int = 0; i < radioButtons.length; i++)
			{
				radioButtons[i].State = "_up";
				radioButtons[i].Selected = false;
				TweenMax.to(radioButtons[i], 0, {glowFilter:{remove:true}});
				if (radioButtons[i].name ==mc.name)
				{
					radioButtons[i].State = "_down";
					radioButtons[i].Selected = true;
					userSelection = radioButtons[i];
					//TweenMax.to(mc, .6, {glowFilter: {color: 0xFF0000, alpha: 1, blurX: 2, blurY: 2, strength: 3, quality: 3}});
					//TweenMax.to(mc, .15, { dropShadowFilter: { color:0xFFFFFFF, alpha:99, blurX:11, blurY:11, distance:6, quality:3 }} );
					//TweenMax.to(e.target, .6, { alpha:0 } );
				}
			}	
			// locks submit control when submit is present
			//activateInterface(1);
			evaluate();
		}
		public function handleRadioImageClick(e:MouseEvent):void
		{
			for (var i:int = 0; i < radioButtons.length; i++)
			{
				radioButtons[i].State = "_up";
				radioButtons[i].Selected = false;
				if (radioButtons[i].RadioButtonInstance.name == e.target.name)
				{
					radioButtons[i].State = "_down";
					radioButtons[i].Selected = true;
					userSelection = radioButtons[i];
					
				}
			}		
			activateInterface(1);
		}
		public function unlockControls():void
		{
			//trace("unlocking controls");
			for (var i:int = 0; i < radioButtons.length; i++)
			{
				radioButtons[i].buttonMode = true;
				radioButtons[i].mouseChildren = true;
				radioButtons[i].mouseEnabled = true;
			}
		}
		
		public function lockControls():void
		{
			//trace("locking controls");
			for (var i:int = 0; i < radioButtons.length; i++)
			{
				radioButtons[i].buttonMode = false;
				radioButtons[i].mouseChildren = false;
				radioButtons[i].mouseEnabled = false;
			}
		}
		
	}
	
}