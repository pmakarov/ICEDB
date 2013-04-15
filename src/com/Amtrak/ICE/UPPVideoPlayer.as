package com.Amtrak.ICE
{
	import com.myPRIME.ICE.utils.VideoXMLLoader;
	import com.myPRIME.ICE.components.PopupWindow;
	import fl.video.FLVPlayback;
	import fl.video.MetadataEvent;
	import fl.video.VideoEvent;
	import fl.video.VideoPlayer;
	import fl.video.VideoProgressEvent;
	import flash.display.Sprite;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.net.*;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.display.Sprite;

	/**
	 * ...
	 * @author pmakarov
	 */
	public class UPPVideoPlayer extends Sprite
	{
		private var videoPlayBack:FLVPlayback;
		private var videoPath:String = "http://www.helpexamples.com/flash/video/caption_video.flv";
		private var blocker:interfaceBlocker = new interfaceBlocker();
		private var pb:videoProgressBar;
		private var videoContainer:Sprite;
		private var sceneXML:VideoXMLLoader;
		private var cuePoints:Array;
		private var savePoints:Array;
		private var spCounter:uint = 0;
		private var cueCount:uint = 0;
		public var complete:Boolean = false;
		
		public function UPPVideoPlayer(sceneXML:VideoXMLLoader = null):void 
		{
			videoContainer = new Sprite();
			
			
			var vbg:videoControlBG = new videoControlBG()
			vbg.x = 0;
			vbg.y = 0;
			vbg.width = 1020;
			vbg.height = 706;
			videoContainer.addChild(vbg);
			
			videoPlayBack = new FLVPlayback();
			videoPlayBack.playPauseButton = playPause;
			videoPlayBack.autoPlay = false;
			videoPlayBack.scaleMode = "exactFit";
			videoContainer.addChild(videoPlayBack);
			
			
			var pbBG:videoProgressBarBG = new videoProgressBarBG();
			pbBG.height = 6;
			pbBG.width = 1018;
			pbBG.x = 2;
			pbBG.y = 678;
			videoContainer.addChild(pbBG);
			
			
			pb = new videoProgressBar();
			pb.height = 4;
			pb.width = 0;
			pb.x = 2;
			pb.y = 679;
			videoContainer.addChild(pb);
			
			var playPause:videoPlayButton = new videoPlayButton();
			playPause.x = 0;
			playPause.y = 684;
			playPause.width = 25;
			playPause.height = 24;
			playPause.addEventListener(MouseEvent.CLICK, togglePlayPauseButton);
			playPause.name = "playPause";
			playPause.buttonMode = true;
			videoContainer.addChild(playPause);
			
			
			this.addEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
			this.addChild(videoContainer);
			videoContainer.x = 0;
			videoContainer.y = 0;
			videoContainer.width = 1020;
			videoContainer.height = 706;
			videoContainer.name = "container";
			
			//sceneXML = new SceneXMLLoader("data/steps/videoElement.xml");
			//sceneXML.addEventListener( Event.COMPLETE, onXmlLoad );		
			videoPlayBack.source = sceneXML.getURL();	
			this.addEventListener("CUE_COMPLETE", cueCompleteHandler);
			videoPlayBack.addEventListener(MetadataEvent.METADATA_RECEIVED, metadataReceived);
			videoPlayBack.addEventListener(VideoEvent.STATE_CHANGE, videoStateHandler);
			videoPlayBack.addEventListener( MetadataEvent.CUE_POINT, doCuePoint);	
			videoPlayBack.addEventListener(VideoEvent.PLAYHEAD_UPDATE, progressHandler);
			videoPlayBack.addEventListener(VideoEvent.COMPLETE, handleVideoComplete); 
			
			
			if (sceneXML.getCuePoints().length > 0)
			{
				addCuePoints(sceneXML);
			}
			else
			{
				videoPlayBack.play();
			}
			
		}	
		public function unload():void
		{
			videoPlayBack.stop();
		}
		public function cueCompleteHandler(e:Event):void
		{
			//trace("finished with cues");
			
			videoPlayBack.play();
		}
		public function addCuePoints(sceneXML:VideoXMLLoader):void
		{
			cuePoints = sceneXML.getCuePoints();
			savePoints = new Array();
			for (var i:uint = 0; i < cuePoints.length; i++)
			{
				for (var x:uint = 0; x < cuePoints[i].getActions().length; x++)
				{
					if (cuePoints[i].getActions()[x].type == "save")
					{
						var savePointButton:videoSavePoint = new videoSavePoint();
						savePointButton.name = "sp_" + i;
						savePointButton.id = i;
						//you will ask yourself how one day... and you will laugh
						savePointButton.x = (12 * i ) + 1020 - (12 * sceneXML.getTotalSavePoints());
						// 12pix + 8pix * count
						savePointButton.y = videoPlayBack.y + 634 - 20;
						savePointButton.width = 8;
						savePointButton.height = 15;
						savePointButton.active = false;
						savePointButton.time = cuePoints[savePointButton.id].time;
						//trace(savePointButton.x + " : " + savePointButton.y + " : " + savePointButton.width + " : " + savePointButton.height);
						savePoints.push(savePointButton);
						cuePoints[i].spRef = savePointButton;
						videoContainer.addChild(savePointButton);
						
					}
				}
				videoPlayBack.addASCuePoint(cuePoints[i].time, "cuePoint_" + i, cuePoints[i].getActions());									
			}
			
			dispatchEvent(new Event("CUE_COMPLETE"));
		}
		protected function onXmlLoad( e:Event ) : void
		{
			
			
			//var evalType:String = evaluation.@evalType.toString();
			
			videoPlayBack.source = sceneXML.getURL();
			
			cuePoints = sceneXML.getCuePoints();
			savePoints = new Array();
			for (var i:uint = 0; i < cuePoints.length; i++)
			{
				for (var x:uint = 0; x < cuePoints[i].getActions().length; x++)
				{
					if (cuePoints[i].getActions()[x].type == "save")
					{
						var savePointButton:videoSavePoint = new videoSavePoint();
						savePointButton.name = "sp_" + i;
						savePointButton.id = i;
						//you will ask yourself how one day... and you will laugh
						savePointButton.x = (12 * i ) + videoPlayBack.width - (12 * sceneXML.getTotalSavePoints());
						// 12pix + 8pix * count
						savePointButton.y = videoPlayBack.y + videoPlayBack.height - 20;
						savePointButton.width = 8;
						savePointButton.height = 15;
						savePointButton.active = false;
						savePointButton.time = cuePoints[savePointButton.id].time;
						//trace(savePointButton.x + " : " + savePointButton.y + " : " + savePointButton.width + " : " + savePointButton.height);
						savePoints.push(savePointButton);
						cuePoints[i].spRef = savePointButton;
						videoContainer.addChild(savePointButton);
						
					}
				}
				videoPlayBack.addASCuePoint(cuePoints[i].time, "cuePoint_" + i, cuePoints[i].getActions());									
			}
			/*if (sceneXML.getTotalSavePoints() > 0)
			{
				
				var count:uint = sceneXML.getTotalSavePoints();
				for (var j:uint = 0; j < count; j++)
				{
					var savePointButton:videoSavePoint = new videoSavePoint();
						savePointButton.name = "sp_" + j;
						savePointButton.id = j;
						//you will ask yourself how one day... and you will laugh
						savePointButton.x = (12 * j ) + videoPlayBack.width - (12 * count);
						// 12pix + 8pix * count
						savePointButton.y = videoPlayBack.y + videoPlayBack.height - 20;
						savePointButton.width = 8;
						savePointButton.height = 15;
						savePointButton.active = false;
						savePointButton.time = cuePoints[savePointButton.id].time;
						//trace(savePointButton.x + " : " + savePointButton.y + " : " + savePointButton.width + " : " + savePointButton.height);
						savePoints.push(savePointButton);
						videoContainer.addChild(savePointButton);
				}
			}*/
			videoPlayBack.addEventListener(VideoEvent.STATE_CHANGE, videoStateHandler);
			videoPlayBack.addEventListener( MetadataEvent.CUE_POINT, doCuePoint);	
			videoPlayBack.addEventListener(VideoEvent.PLAYHEAD_UPDATE, progressHandler);
			videoPlayBack.addEventListener(VideoEvent.COMPLETE, handleVideoComplete); 
			videoPlayBack.play();
		}
		
		public function videoStateHandler(e:VideoEvent):void 
		{
			//if (cueCount < cuePoints.length)
			//{
				pb.width = (1020) * (videoPlayBack.playheadPercentage / 100);
				//trace("width: - - - - - - - -  - > " + pb.width);
				//pb.width = videoPlayBack.bytesLoaded * 1020 / videoPlayBack.bytesTotal;
				
			//}
			/*if (videoPlayBack.buffering)
				{
					//trace("buffering..");
				}
				if (e.state != "playing")
				{
					//pb.visible = false;
				}
				else {
					trace(e.state);
					//pb.visible = true;
				}*/
			
		
		}
		
		public function togglePlayPauseButton(e:MouseEvent):void 
		{
			if (e.target.currentFrame == 1)
			{
				e.target.gotoAndStop(2)
				videoPlayBack.pause();
			}
			else
			{
				e.target.gotoAndStop(1);
				videoPlayBack.play();
			}
		}
		public function progressHandler(e:VideoEvent):void 
		{
			//pb.width = (videoPlayBack.width - 25) * (videoPlayBack.playheadPercentage / 100);
			pb.width = (1020) * (videoPlayBack.playheadPercentage / 100);
			if (Math.floor(videoPlayBack.playheadPercentage) == 90)
			{
				//trace("look to buffer next movie");
				//trace(videoPlayBack.getVideoPlayer(0));
				//videoPlayBack.activeVideoPlayerIndex = 1;
				//videoPlayBack.load("assets/media/values/video/values_1_frosty.smil");				
			}
		}
		public function doCuePoint(evt:MetadataEvent):void 
		{
			//trace(evt.info.name + " : " + evt.info.time + " : " + evt.info.parameters);
			for (var i:* in evt.info.parameters)
			{
				//trace(i);
				//trace(evt.info.parameters[i].type + " : " +  evt.info.parameters[i].data);
				handleSceneActions(evt.info.parameters[i]);
			}
			if (cueCount < savePoints.length-1)
			{
				cueCount++;
			}
		}
		
		public function metadataReceived(evt:MetadataEvent):void 
		{
			/*trace("duration:", evt.info.duration); // 16.334
			trace("framerate:", evt.info.framerate); // 15
			trace("width:", evt.info.width); // 320
			trace("height:", evt.info.height); // 213*/
			
			videoPlayBack.width = 1020;
			videoPlayBack.height = 706;
			var videoplayer:VideoPlayer = videoPlayBack.getVideoPlayer(0);
			videoplayer.smoothing = true;
		}
		private function handleSceneActions(command:Object):void 
		{
			//trace("TYPE: " + command.type);
			
			
			switch(command.type)
			{
				case "caption":
				//trace("DO CAPTION \n" + command.data);
				break;
				
				case "display":
				//trace("DO DISPLAY ACTION \n" + command.data);
				break;
				
				case "save":
				//trace("save point time: " + videoPlayBack.playheadTime + " listed in cue point " + cuePoints[cueCount].id);
				activateSavePoint();
				break;
				
				case "system":
				//trace("DO SYSTEM CALL \n" + command.data);
				trace(command.data);
				videoPlayBack.pause();
				var tmp:Object = new Object();
				tmp.title = "NO INFORMATION SUPPLIED!";
				tmp.text = "You did not make a selection. DO IT NOW!!!";
				tmp.value = false;
				tmp.windowType = "CAUTION";
				dispatchEvent(new FeedbackEvent(tmp));
				break;
				
				default:
				break;
			}
		}
		private function activateSavePoint():void 
		{
			if (cuePoints[cueCount].spRef && cuePoints[cueCount].spRef.active == false)
			{
				cuePoints[cueCount].spRef.gotoAndStop(2);
				cuePoints[cueCount].spRef.buttonMode = true;
				cuePoints[cueCount].spRef.addEventListener(MouseEvent.CLICK, handleSeekSavePoint);
			}
		}
		private function handleSeekSavePoint(e:MouseEvent):void
		{
			videoPlayBack.pause();
			//trace(savePoints.length + " is teh length yo; but cue count is: " + cueCount + " and check it, the e.id is: " + uint(e.target.id + 1));
			if (uint(e.target.id + 1) < savePoints.length)
			{
				cueCount = uint(e.target.id + 1);
			}
			else
			{
				cueCount = savePoints.length - 1;
			}
			var time:Number = Number(e.target.time);
			
			if (cueCount == 1)
			{
				videoPlayBack.seek(0.00);
			}
			else
			{
				videoPlayBack.seek(time);
			}
			pb.width = (videoPlayBack.width - 25) * (time/videoPlayBack.totalTime);
			videoPlayBack.play();
		}
		private function blockInterface():void
		{
			blocker.width = stage.stageWidth;
			blocker.height = stage.stageHeight;
			blocker.x = 0;
			blocker.y = 0;
			blocker.alpha = 0;
			blocker.name = "blocker";
			TweenMax.to(videoPlayBack, .5, { blurFilter: { color:0x9BA8DB, alpha:1 , blurX:5, blurY:5 }});
			this.addChild(blocker);
		}
		private function unblockInterface():void 
		{
			blocker.filters = null;
			this.removeChild(this.getChildByName("blocker"));
		}
		private function displayFeedback(e:FeedbackEvent):void 
		{
			//trace(e.value + "\n" + e.text);
			blockInterface();
			//Build Feedback 
			videoContainer.mouseChildren = false;
			if (e.windowType == "POPUP")
			{
				var params:Object = new Object();
				params.x = 139;
				params.y = 40;
				params.width = 400;
				params.height = 300;
				var popup:PopupWindow = new PopupWindow("Popup Window", "assets/media/default.swf", params);
				popup.name = "popup";
				addChild(popup);
			}
			else
			{
			var feedbackContainer:MovieClip = new MovieClip();
			feedbackContainer.name = "feedback";
			addChild(feedbackContainer);
			
			var wb:whiteBox = new whiteBox();
			wb.width = 520;
			wb.height = 210;
			wb.x = (stage.stageWidth - wb.width)/2
			wb.y = ((456+20) - wb.height)/2;
			
			feedbackContainer.addChild(wb);
			TweenMax.to(wb, .25, { dropShadowFilter: { color:0x333333, alpha:59, blurX:11, blurY:11, distance:6, quality:3 }} );
			trace(e.title);
			var titleText_mc:TextField = new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
            titleText_mc.background = false; //use true for doing generic labels
            titleText_mc.border = false;      // ** same
			titleText_mc.wordWrap = true;
			var format:TextFormat = new TextFormat();
            format.font = "Segoe UI";
            format.color = 0x000000;
            format.size = 16;
			format.bold = true;
            titleText_mc.defaultTextFormat = format;
			titleText_mc.text = e.title;
			titleText_mc.x = wb.x + 100;
			titleText_mc.y = wb.y + 15;
			titleText_mc.width = wb.width - 100;
			feedbackContainer.addChild(titleText_mc);
			
			var feedBackText_mc:TextField = new TextField();
			feedBackText_mc.autoSize = TextFieldAutoSize.LEFT;
            feedBackText_mc.background = false; //use true for doing generic labels
            feedBackText_mc.border = false;      // ** same
			feedBackText_mc.wordWrap = true;
			feedBackText_mc.width = wb.width - 150;
			var format2:TextFormat = new TextFormat();
            format2.font = "Segoe UI";
            format2.color = 0x000000;
            format2.size = 14;
            format2.underline = false;
            feedBackText_mc.defaultTextFormat = format2;
			feedBackText_mc.text = e.text;
			feedBackText_mc.x = wb.x + 100;
			feedBackText_mc.y = titleText_mc.y + titleText_mc.height + 10;
			
			feedbackContainer.addChild(feedBackText_mc);
			
			var next:greenGlassButton = new greenGlassButton();
			
			next.label.mouseEnabled = false;
			next.mouseChildren = false;
			//next.addEventListener(MouseEvent.ROLL_OVER, buttonOver);
			//next.addEventListener(MouseEvent.ROLL_OUT, buttonOut);
			if (e.windowType != "CAUTION")
			{
				next.label.text = "NEXT";
				next.addEventListener(MouseEvent.CLICK, doFeedbackNext);
			}
			else
			{
				next.label.text = "OK"
				next.addEventListener(MouseEvent.CLICK, doCloseFeedback);
			}
			
			next.buttonMode = true;
			next.useHandCursor = true;
			next.x = (stage.stageWidth - next.width)/2;
			next.y = wb.y + wb.height - (next.height + 10);
			
			feedbackContainer.addChild(next);
			
			
			var icon:feedBackIcon = new feedBackIcon();
			icon.x = wb.x + 20;
			icon.y = wb.y + 20;
			feedbackContainer.addChild(icon);
			
			var sColor:String = "6699cc";
			if (e.value == "v1" || e.value== "true")
			{
				icon.gotoAndStop("CORRECT");
				sColor = "7DAB63";
			}
			else if(e.value == "v2" || e.value == "false")
			{
				if (e.windowType == "CAUTION")
				{
					icon.gotoAndStop("CAUTION");
					sColor = "FFCC00";
				}
				else
				{
					icon.gotoAndStop("INCORRECT");
					sColor = "C86162";
				}
			}
			var nColor:Number = parseInt(sColor, 16);
			TweenMax.to(wb, .25 ,{glowFilter:{color:nColor, alpha:1, blurX:20, blurY:15 , strength:2, quality:3}});
			}
			
		}
		public function doFeedbackNext(e:MouseEvent):void
		{
			//clearDisplayList();
			//playNextScene(e);
		}
		public function doCloseFeedback(e:MouseEvent):void 
		{
			videoContainer.mouseChildren = true;
			var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
			this.removeChild(feedback);
			unblockInterface();
			if (videoPlayBack.source != "" && !videoPlayBack.playing)
			{
				videoPlayBack.play();
			}
			this.videoPlayBack.filters = null;
		}

		private function handleVideoComplete(e:VideoEvent):void
		{
			//trace("secondsPassed: " + videoPlayBack.playheadPercentage);
			//videoPlayBack.visibleVideoPlayerIndex = 1;
			//videoPlayBack.play();
			this.complete = true;
			dispatchEvent(new Event("ASSET_COMPLETE"));
		}
		public function init():void
		{
			videoPlayBack.pause();
			videoPlayBack.seek(0.00);
			pb.width = 0;
			videoPlayBack.play();
		}

	}
	
}