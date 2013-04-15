
package com.Amtrak.ICE {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import com.greensock.TweenMax;
	import com.greensock.easing. *;
	import com.greensock.plugins.*;
	import com.Amtrak.ICE.ComponentDataRequestEvent;


	public class Evaluation extends MovieClip implements IEvaluationDisplayable
	{
		public var evalType:String = "";
		public var randomize:Boolean = false;
		public var design:Boolean = false;
		public var multiMedia:Boolean = false;
		public var layout:String = "vertical";
		public var hotspot:Boolean = false;
		public var totalAttempts:Number;
		public var remainingAttempts:uint;
		public var src:String = "";
		public var titleText:String = "";
		public var instructionText:String = "";
		public var questionText:String = "";
		public var remediation:Object = new Object();
		public var remediationList:Array = new Array();
		public var feedbackList:Array = new Array();
		public var choiceList:Array = new Array();
		public var valueList:Array = new Array();
		public var isAnswered:Boolean = false;
		public var dependentData:Array = new Array();
		public var evalData:Object;
		public var customBG:String = "";
		public var audioSource:String = "";
		public var dataDependencyID:String =  "";
		public var audioAssetReady:Boolean = false;
		//display fields
		public var titleText_mc:TextField;
		public var instructionText_mc:TextField;
		public var questionText_mc:TextField;
		public var transitionManager:Array;
		public var repostData:Array;
		public var scoreType:String = "";
		public var initialized:Boolean;
		
		public function Evaluation( xml:XML = null) : void
		{
			
			evalType = xml.@evalType;
			titleText = xml.titleText.toString();
			instructionText = xml.instructionText.toString();
			questionText = xml.questionText.toString();
			remediation.file = xml.remediation.file.@href;
			remediation.windowOptions = xml.remediation.file.@windowOptions.toString();
			remediation.linkText = xml.remediation.linkText.toString();
			randomize = (xml.@randomize == true) ? true : false;
			design = (xml.@design == undefined || xml.@design == false) ? false :true;
			multiMedia = (xml.@multimedia == undefined || xml.@multimedia == false) ? false :true;
			hotspot = (xml.@hotspot == undefined || xml.@hotspot == false) ? false :true;
			layout = (xml.@layout == undefined) ? "vertical" : xml.@layout;
			scoreType = (xml.@scoreType == undefined) ? "default": xml.@scoreType;
			customBG = (xml.@customBG == undefined) ? "" : xml.@customBG;
			audioSource = xml.audio.@src;
			//dataDependencyID = xml['data-dependency'].@id.toString();
			//var tmpList:XMLList = xml['data-depenency'].@id;
			
			for each (var dd:XML in xml['data-dependency'])
			{
				dataDependencyID += dd.@id.toString() + ";";
				
			}
			//trace(dataDependencyID);
			totalAttempts = (xml.@maxAttempts == undefined) ? 1 :xml.@maxAttempts;
			remainingAttempts = totalAttempts;
			
			transitionManager = new Array();
			//this.addEventListener(Event.COMPLETE, handleContentLoaded);
			
			for each ( var feedback:XML in xml..feedbackObject )
			{
				var feedbackObject:Object = new Object();
				feedbackObject.value = feedback.@valueID;
				feedbackObject.text = (feedback.text == undefined) ? "" : feedback.text.toString();
				feedbackObject.audio = (feedback.audio == undefined) ? "" : feedback.audio.@src.toString();
				feedbackObject.video = (feedback.video == undefined) ? "" : feedback.video.@src.toString();
				feedbackObject.selected = false;
				feedbackList.push( feedbackObject );
			}
			
			
			for each (var choices:XML in xml..choice)
			{
				var choiceObject:Object = new Object();
				choiceObject.id = choices.@id;
				choiceObject.value = choices.@valueID;
				choiceObject.text = choices.text.toString();
				choiceList.push(choiceObject);
			}
						
			for each (var values:XML in xml..value)
			{
				var valueObject:Object = new Object();
				valueObject.id = values.@id;
				valueObject.text = values.toString();
				valueList.push(valueObject);
			}
			initialized = false;
			initializeDynamicContent();
		}
		override public function play():void 
		{
			if (this.getChildByName("audio"))
			{
				//MediaLoader(this.getChildByName("audio"));
				MediaLoader(this.getChildByName("audio")).playSound();
			}
			//this.display();
			this.alpha = 0;
			TweenMax.to(this, 1, { alpha:1 } );
		}
		
		override public function stop():void 
		{
			if (this.getChildByName("audio"))
			{
				MediaLoader(this.getChildByName("audio")).stopSound();
				this.removeChild(this.getChildByName("audio"));
				
			}
		}
		public function initContent():void 
		{
			this.display();
		}
		public function initializeDynamicContent():void
		{
			if (audioSource != "")
			{
				var s:MediaLoader = new MediaLoader();
				s.name = "audio";
				s.loadMedia(audioSource);
				s.stopSound();
				s.addEventListener("ASSET_LOADED", audioLoaded);
				this.addChild(s);
			}		
			else 
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function audioLoaded(e:Event):void
		{
			audioAssetReady = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function handleContentLoaded(e:Event):void
		{
			/*if (this.getChildByName("audio"))
			{
				MediaLoader(this.getChildByName("audio")).playSound();
			}
			this.display();*/
		}
		public function get Data():Object 
		{
			return evalData;
		}
		public function display():void
		{			
			var background_mc:bg = new bg();
			addChild(background_mc);
			
			titleText_mc= new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			var format:TextFormat = new TextFormat();
            format.font = "(BankGothicBT-Medium) System Default Font";
            format.color = 0xFFFFFF;
            format.size = 30;
            format.underline = false;
            titleText_mc.defaultTextFormat = format;
			titleText_mc.text = titleText;
			titleText_mc.x = 0;
			titleText_mc.y = 9;
			background_mc.addChild(titleText_mc);
			
			instructionText_mc = new TextField();
			instructionText_mc.autoSize = TextFieldAutoSize.LEFT;
            instructionText_mc.background = false; //use true for doing generic labels
            instructionText_mc.border = false;      // ** same
			var format2:TextFormat = new TextFormat();
            format2.font = "Segoe UI";
            format2.color = 0xFFFFFF;
            format2.size = 14;
			format2.italic = true;
            format2.underline = false;
            instructionText_mc.defaultTextFormat = format2;
			instructionText_mc.text = instructionText;
			instructionText_mc.x = 0;
			instructionText_mc.y = 44;
			background_mc.addChild(instructionText_mc);
			
			
			var wb:whiteBox = new whiteBox();
			wb.width = 747;
			wb.x = (this.width - wb.width) / 2;
			wb.y = instructionText_mc.y + 30;
			background_mc.addChild(wb);
			
			
			questionText_mc = new TextField();
			questionText_mc.autoSize = TextFieldAutoSize.LEFT;
            questionText_mc.background = false; //use true for doing generic labels
            questionText_mc.border = false;      // ** same
			questionText_mc.wordWrap = true;
			questionText_mc.width = wb.width - 8;
			var format3:TextFormat = new TextFormat();
            format3.font = "Segoe UI";
            format3.color = 0x000000;
            format3.size = 14;
            format3.underline = false;
            questionText_mc.defaultTextFormat = format3;
			questionText_mc.text = questionText;
			questionText_mc.x = wb.x + 4;
			questionText_mc.y = wb.y + 2;
			wb.height = questionText_mc.height + 4;
			
			background_mc.addChild(questionText_mc);
			
			var submit:greenGlassButton = new greenGlassButton();
			submit.label.text = "Submit";
			submit.label.mouseEnabled = false;
			submit.addEventListener(MouseEvent.ROLL_OVER, doButtonOver);
			submit.addEventListener(MouseEvent.ROLL_OUT, doButtonOut);
			submit.addEventListener(MouseEvent.CLICK, handleEvaluation);
			
			submit.buttonMode = true;
			submit.useHandCursor = true;
			submit.x = this.width - (submit.width + 10);
			submit.y = this.height - (submit.height + 10);
			background_mc.addChild(submit);
		}
		public function handleEvaluation(e:MouseEvent):void 
		{
			evaluate();
		}
		public function evaluate():void 
		{
			if (feedbackList.length > 0)
			{
				var tmp:Object = new Object();
				tmp.title = titleText;
				tmp.text = this.feedbackList[0].text;
				tmp.value = this.feedbackList[0].value;
				tmp.audio = this.feedbackList[0].audio;
				tmp.video = this.feedbackList[0].video;
				dispatchEvent(new FeedbackEvent(tmp));
			}
			else
			{
				dispatchEvent(new Event("ASSET_COMPLETE"));
			}
		}
		public function doButtonOver(e:MouseEvent):void
		{
			e.target.gotoAndStop("OVER");
		}
		public function doButtonOut(e:MouseEvent):void
		{
			e.target.gotoAndStop("OUT");
		}
		
		public function randomizeArray(array:Array):Array
		{
			var newArray:Array = new Array();
			while(array.length > 0){
				var obj:Array = array.splice(Math.floor(Math.random()*array.length), 1);
				newArray.push(obj[0]);
			}
			return newArray;
		}
		
		public function assignDataDependencyValues(val:Array):void
		{
			dependentData = val;
			dispatchEvent(new Event("DYNAMIC_DATA_LOADED"));
		}
		
		public function repost(eD:Array):void
		{
			dependentData = eD;
			dispatchEvent(new Event("REPOST"));
		}
	}
}
