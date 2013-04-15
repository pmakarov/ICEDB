package com.Amtrak.ICE.components
{
	import com.greensock.text.FlexSplitTextField;
	import com.greensock.TweenMax;
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.Evaluation;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.IEvaluationDisplayable;
	import com.Amtrak.ICE.MediaLoader;
	import fl.controls.DataGrid;
	import fl.controls.ScrollPolicy;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import fl.controls.TextArea;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import mx.events.MoveEvent;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class Assessment extends Evaluation implements IEvaluationDisplayable
	{
		private var inputBoxes:Array = [];
		private var questions:Array = [];
		private var questionTextFormat:TextFormat;
		private var assessmentType:String;
		private var scale:Array = [];
		private var padding:uint = 10;
        private var currHeight:uint = 0;
        private var verticalSpacing:uint = 30;
        private var posX:uint;
		private var dynamicData:Array;

		public function Assessment(xml:XML = null)
		{	
			assessmentType = (xml["choice-collection"].@type == undefined) ? "custom": xml["choice-collection"].@type;
			for each ( var item:XML in xml..scaleItem )
			{
				scale.push( item.toString() );
			}
			super(xml);
			questionTextFormat = new TextFormat();
            questionTextFormat.font = FontManager.segoe.fontName;
            questionTextFormat.color = 0x000000;
            questionTextFormat.size = 14;
            questionTextFormat.underline = false;
		}
		override public function handleContentLoaded(e:Event):void
		{					
			/*this.addEventListener("DYNAMIC_DATA_LOADED", displayAfterDynamicContent);
			if (dataDependencyID != "")
			{
				var tmp:Object = new Object();
				tmp.componentID = dataDependencyID;
				dispatchEvent(new ComponentDataRequestEvent(tmp));
				
			}
			else
			{
				displayInterface();
			}*/
			

		}
		
		public function displayInterface():void
		{
			var background_mc:bg = new bg();
			background_mc.name = "bg";
			if (customBG != "")
			{
				var ml:MediaLoader = new MediaLoader();
				ml.loadMedia(customBG.toString());
				background_mc.addChild(ml);
			}
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
            format.size = 30;
            format.underline = false;
            titleText_mc.defaultTextFormat = format;
			titleText_mc.text = titleText;
			titleText_mc.x = (background_mc.width - titleText_mc.width)/2;
			titleText_mc.y = 9;
			background_mc.addChild(titleText_mc);
			
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
			background_mc.addChild(instructionText_mc);
		
			var thisWidth:Number = this.width;
			var thisHeight:Number = this.height;
			
			var submit:greenGlassButton = new greenGlassButton();
			var format4:TextFormat = new TextFormat();
			format4.font = FontManager.bgM.fontName;
            format4.color = 0xFFFFFF;
            format4.size = 22;
			submit.label.embedFonts = true;
			submit.label.defaultTextFormat = format4;
			submit.label.text = "Next";
			submit.label.mouseEnabled = false;
			//submit.alpha = 0;
			submit.name = "submit";
			submit.mouseChildren = false;
			submit.x = thisWidth - (submit.width + 10);
			submit.y = thisHeight - (submit.height + 10);
			background_mc.addChild(submit);
			TweenMax.to(submit, .15, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );
			
			
			var mc:MovieClip = new MovieClip();
			mc.name = "radioBoard";
			
			switch (assessmentType) 
			{
				case "yesNo":
				scale = new Array();
				scale[0] = "Yes";
				scale[1] = "No";
			    mc = buildQuestionnaire();
				background_mc.addChild(mc);
				break;
				
				case "amount":
				scale = new Array();
				scale[0] = "Yes";
				scale[1] = "No";
				mc = buildQuestionnaire();
				background_mc.addChild(mc);
				break;
				
				case "agree":
				scale = new Array();
				scale[0] = "Strongly Disagree";
				scale[1] = "Disagree";
				scale[2] = "Neither Agree nor Disagree";
				scale[3] = "Agree";
				scale[4] = "Strongly Agree";
				mc = buildQuestionnaire();
				background_mc.addChild(mc);
				break;
				
				case "quality":
				scale = new Array();
				scale[0] = "Bad";
				scale[1] = "Slightly Bad";
				scale[2] = "Neutral";
				scale[3] = "Slightly Good";
				scale[4] = "Good";
				mc = buildQuestionnaire();
				background_mc.addChild(mc);
				break;
				
				case "custom":
				mc = buildQuestionnaire();
				background_mc.addChild(mc);
				break;
				
				default:
				break;
			}
			
			
			mc.y = instructionText_mc.y + instructionText_mc.height + 20;
			
			
		}
		public function displayAfterDynamicContent(e:Event):void
		{
			dynamicData = dependentData;
			/*if (dependentData)
			{
				for (var i:uint = 0; i < dependentData.length; i++)
				{
					trace(dependentData[i].answerID + " : " + dependentData[i].answerData);
					var a:MovieClip = MovieClip(this.getChildByName("bg")).getChildByName("radioBoard") as MovieClip;
					var str:String = "c" + (i+1);
					trace(str);
					var group:RadioButtonGroup = a.RadioButtonGroup.getGroup(str);
					group.getRadioButtonAt(0).selected = true;
					//trace("The currently selected radio button is: " + group.selection.label);

				}
			}*/
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
			
			
			
			/**** LEAVE THIS FUNCTION HERE FOR NOW **********/
		}
		
		public function buildQuestionnaire():MovieClip
		{
			
			var mc:MovieClip = new MovieClip();
			
			var header:whiteTop = new whiteTop();
			mc.addChild(header);
			var prevX:Number = 0;
			var pad:Number = 12;
			var tH:Number = 0;
			
			var tc:MovieClip = new MovieClip();
			
			var format6:TextFormat = new TextFormat();
			format6.font = FontManager.segoe.fontName;
			format6.color = 0x000000;
			format6.size = 14;
			format6.underline = false;
			format6.align = TextFormatAlign.CENTER;
			var startX:Number = 0;
			for (var j:uint = 0; j < scale.length; j++)
			{
				var tf:TextField = new TextField();
				tf.embedFonts = true;
				tf.wordWrap = true;
				tf.antiAliasType = "advanced";
				tf.sharpness = -300;
				tf.thickness = - 50;
				tf.defaultTextFormat = format6;
				tf.width = 60;
				tf.htmlText = scale[j];
				
				if (tf.textHeight > tH)
				{
					tH = tf.textHeight;
				}
				tc.addChild(tf);
				tf.x = prevX;
				if (j < 1)
				{
					startX = tf.width/2 - pad;
				}
				tf.y = 5;
				prevX = tf.x + tf.width + pad;
				//trace(scale[j]);
			}
			mc.addChild(tc);
			header.width = prevX;
			header.height = tH + 4;
			header.y = 5;
			var nColor:uint = 0xDCE0AF;
			TweenMax.to(header, 0, { tint:nColor} );		
			
			var newColorTransform:ColorTransform = new ColorTransform();
			var prevHeight:Number = header.y + header.height;
			var w:Number = this.width;
			header.x = w - header.width;
			tc.x = header.x + (header.width - tc.width) / 2;
			for (var i:uint = 0; i < choiceList.length; i++)
			{
				newColorTransform.color  = (i % 2 != 0) ? 0xEFF1DA : 0xFFFFFF ;
				var tF:TextField = new TextField();
				tF.embedFonts = true;
				tF.wordWrap = true;
				tF.antiAliasType = "advanced";
				tF.sharpness = -300;
				tF.thickness = - 50;
				tF.width = w - tc.width - 20;
				tF.defaultTextFormat = questionTextFormat;
				tF.htmlText = choiceList[i].text;
				
				//trace(choiceList[i].text);
				var child:Shape = new Shape();
				child.graphics.beginFill(newColorTransform.color);
				child.graphics.lineStyle(1, 0x333333);
				child.graphics.drawRect(0, 0, w, tF.textHeight+8);
				child.graphics.endFill();
				child.name = "cell";
				child.y = prevHeight;
				mc.addChild(child);
				TweenMax.to(child, 0, { dropShadowFilter: { color:0x333333, alpha:59, blurX:4, blurY:4, distance:2, quality:3 }} );

				mc.addChild(tF);
				tF.x = 5;
				tF.y = prevHeight;
				prevHeight += child.height+6;
				//prevHeight += 50;
				//setupRadioButtons();
				mc.addChild(createRadioButtonGroup("c" + i, scale.length, tc.x + startX, tF.y+ tF.textHeight/2));
				if(dynamicData)
				{
					if (dynamicData.length>1)
					{
					var group:RadioButtonGroup = RadioButtonGroup.getGroup("c" +i);
					group.getRadioButtonAt(dynamicData[i].answerData.substr(1,dynamicData[i].answerData.length-1)).selected = true;
					}
				}
			}
			
			mc.addChild(drawVerticalLines(scale.length, header.x , prevHeight-6, 72));
			
			return mc;
		}
		public function drawVerticalLines(num:uint, xPos:Number, height:Number,pad:Number):MovieClip
		{
			var lines:MovieClip = new MovieClip();
			for (var i:uint = 0; i < num; i++)
			{
				var lineDrawing:MovieClip = new MovieClip();
				lines.addChild(lineDrawing);
				lineDrawing.graphics.lineStyle(1, 0, 1);
				lineDrawing.graphics.moveTo(xPos +i*pad, 5); ///This is where we start drawing
				lineDrawing.graphics.lineTo(xPos +i*pad, height);
				
			}
			TweenMax.to(lines, 0, { tint:0x666666 } );
			return lines;
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
			evalData = evalData as Array ;
			evalData = new Array();
			for (var j:uint; j < choiceList.length; j++)
			{
			//trace("Answer ID: " + choiceList[j].id +  "\nanswerText : " +choiceList[j].value);
			//trace(steps[stepNumber].component.evalData[i].Data);
			//trace(typeof(choiceList[j].id) + choiceList[j].id.toString());
				evalData.push({"answerID":choiceList[j].id.toString(), "answerData":choiceList[j].value.toString()});
			}
			//evalData = { "answerID":"c1","answerText":tA.text};
			dispatchEvent(new Event("ASSET_COMPLETE"));
			
		}
        private function createRadioButtonGroup(name:String, number:Number,xSpace:Number, ySpace:Number):MovieClip
		{
            var rbg:RadioButtonGroup = new RadioButtonGroup(name);
            rbg.addEventListener(Event.CHANGE, announceChange);
			var radioGroup:MovieClip = new MovieClip();
			for (var i:uint = 0; i < number; i++)
			{
				createRadioButton(radioGroup, "v" + i, rbg, xSpace + i * 72 , ySpace);
			}            
            
			return radioGroup;
        }
        private function createRadioButton(mc:MovieClip, rbLabel:String, rbg:RadioButtonGroup, posX:Number, posY:Number):void
		{
            var rb:RadioButton = new RadioButton();
            rb.group = rbg;
			//rb.label = rbLabel;
            rb.label = "";
			rb.name = rbLabel;
            rb.move(posX, posY - rb.height/4 - 1);
            mc.addChild(rb);
			posX += padding;
        }
		private function activateControls():void
		{
			var backg:MovieClip = this.getChildByName("bg") as MovieClip;
			var submit:MovieClip = backg.getChildByName("submit") as MovieClip;
			submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
			submit.buttonMode = true;
			submit.useHandCursor = true;
		}
        private function announceChange(e:Event):void 
		{
            var rbg:RadioButtonGroup = e.target as RadioButtonGroup;
            var rb:RadioButton = rbg.selection;
			var counter:uint = 0;
            //trace(rbg.name + " has selected " + rb.name);     
			for (var i:uint = 0; i < choiceList.length; i++)
			{
				
				if (e.target.name == "c" + i)
				{
					choiceList[i].selected = true;
					choiceList[i].value = rb.name;
					
				}
				if (choiceList[i].selected)
				{
					counter++;
				}
				if (counter == choiceList.length)
				{
					activateControls();
				}
			}
        }

	}
	
}