package com.Amtrak.ICE.components
{
	import com.greensock.TweenMax;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.utils.VideoXMLLoader;
	import fl.video.FLVPlayback;
	import fl.video.MetadataEvent;
	import fl.video.VideoEvent;
	import fl.video.VideoPlayer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.LoaderInfo;
	import flash.ui.Mouse;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author pmakarov
	 */
	public class ICEMediaPlayer extends Sprite
	{
		private var videoPlayBack:FLVPlayback;
		private var videoPath:String = "";
		private var pbBG:videoProgressBarBG; 
		private var pb:videoProgressBar;
		private var videoContainer:Sprite;
		private var hArea:Sprite;
		private var playPause:videoPlayButton
		private var videoControlsContainer:MovieClip;
		private var videoXML:VideoXMLLoader;
		private var cuePoints:Array;
		private var savePoints:Array;
		private var spCounter:uint = 0;
		private var cueCount:uint = 0;
		public var complete:Boolean = false;
		private var time:String = "";
		private var bolProgressScrub:Boolean = false;
		private var bolVolumeScrub:Boolean = false;
		private var scrubber:ProgressScrubber;
		private var volumeScrubber:MovieClip;
		private var tmrDisplay:Timer;
		private var myTimer:Timer;
		private var previousVolumePosition:Number;
		private const DISPLAY_TIMER_UPDATE_DELAY:int = 10;
		
		
		[SWF(width="1024", height="768", frameRate="60", backgroundColor="#000000")]

		public function ICEMediaPlayer():void 
		{
			
			parseFlashVars();
			
			videoContainer = new Sprite();
		
			var vbg:MovieClip = new MovieClip();
			vbg.x = 0;
			vbg.y = 0;
			/*vbg.width = 1024;
			vbg.height = 768;*/
			//vbg.alpha = .7;*/
			
			videoContainer.addChild(vbg);
			
			videoPlayBack = new FLVPlayback();
			videoPlayBack.autoPlay = false;
			videoPlayBack.scaleMode = "exactFit";
			videoContainer.addChild(videoPlayBack);
			videoContainer.addEventListener(MouseEvent.ROLL_OVER, handleVideoRollOver);
			videoContainer.addEventListener(MouseEvent.ROLL_OUT, handleVideoRollOut);
			//videoPlayBack.visible = false;
			
			
			
			videoControlsContainer = new MovieClip();
			
			buildVideoControls();
			
			videoContainer.name = "container";
			addChild(videoContainer);
			
			videoPlayBack.source = videoPath;	
			videoPlayBack.addEventListener(MetadataEvent.METADATA_RECEIVED, metadataReceived);
			videoPlayBack.addEventListener(VideoEvent.STATE_CHANGE, videoStateHandler);
			videoPlayBack.addEventListener(VideoEvent.PLAYHEAD_UPDATE, progressHandler);
			videoPlayBack.addEventListener(VideoEvent.COMPLETE, handleVideoComplete); 
			
			
			tmrDisplay = new Timer(DISPLAY_TIMER_UPDATE_DELAY);
			tmrDisplay.addEventListener(TimerEvent.TIMER, updateDisplay);
			myTimer = new Timer(3000, 1);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
			
			setVolume(1);
			
			videoPlayBack.play();
		
			
		}	
		
		private function parseFlashVars():void
		{
			var format:TextFormat = new TextFormat();
			format.font = "Verdana";
			format.color = 0xFFFFFF;
            format.size = 14;
			format.bold = true;
			
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.border = true;
			tf.defaultTextFormat = format;
			addChild(tf);
			tf.appendText("params:" + "\n");
			tf.visible = false;
			
			var flashVars:Object = LoaderInfo(this.root.loaderInfo).parameters;
			var myFlashVar:String;
			// if the flashvar exists…
			if(root.loaderInfo.parameters["src"] != null)
			   // set our temp value equal to the flashvar embedded in the HTML
			   myFlashVar = root.loaderInfo.parameters["src"];
				trace("myFlashVar: " + myFlashVar);

			if (myFlashVar)
			{
				for (var keyStr:String in flashVars)
				{
					tf.appendText("\t" + keyStr + ":\t" + flashVars[keyStr] + "\n");
					switch(keyStr)
					{
						case "src":
							videoPath = flashVars[keyStr];
							tf.appendText("target source:" + flashVars[keyStr]);
			
							break;
							
						default:
							break;
					}
				}
				
			}
			else 
			{
				videoPath = "http://www.helpexamples.com/flash/video/caption_video.flv";
				//videoPath = "video/runSKELITOR_rgb_9_1.f4v";
			}
		}
		
		private function buildVideoControls():void
		{
			
			
			
			hArea = new Sprite();
			videoControlsContainer.addChild(hArea);
			hArea.graphics.beginFill(0x0000FF);
			hArea.alpha = 0;
			hArea.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			hArea.graphics.endFill();
			hArea.x = stage.stageWidth/2-hArea.width/2;
			hArea.y = stage.stageHeight/2-hArea.height/2;
			hArea.addEventListener(MouseEvent.CLICK, onClick);
			
			var mediaBG:mediaBarBG = new mediaBarBG();
			mediaBG.x = 1018 / 2 - mediaBG.width / 2;
			mediaBG.y = 768 - mediaBG.height * 2;
			videoControlsContainer.addChild(mediaBG);
			
			pbBG = new videoProgressBarBG();
			pbBG.height = 6;
			pbBG.width = 528;
			pbBG.x = mediaBG.x + 41;
			pbBG.y = mediaBG.y + (mediaBG.height - pbBG.height)/2;
			videoControlsContainer.addChild(pbBG);
			pbBG.addEventListener(MouseEvent.CLICK, progressClick);
			
			pb = new videoProgressBar();
			pb.mouseEnabled = false;
			pb.height = 4;
			pb.width = 0;
			pb.alpha = .5;
			pb.x = mediaBG.x + 41;
			pb.y = mediaBG.y + (mediaBG.height - pbBG.height) / 2 + 1;
			pb.name = "progressBar";
			videoControlsContainer.addChild(pb);
			
			scrubber = new ProgressScrubber();
			scrubber.x = pb.x + 5;
			scrubber.y = pb.y - 2;
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, progressScrubberClicked);
			videoControlsContainer.addChild(scrubber);
			
			playPause = new videoPlayButton();
			playPause.x = mediaBG.x + 6;
			playPause.y = mediaBG.y + (mediaBG.height - playPause.height)/2;
			playPause.addEventListener(MouseEvent.CLICK, togglePlayPauseButton);
			playPause.name = "playPause";
			playPause.buttonMode = true;
			
			videoPlayBack.playPauseButton = playPause;
			
			videoControlsContainer.addChild(playPause);
			
			var format:TextFormat = new TextFormat();
			format.font = "Verdana";
			format.color = 0xFFFFFF;
            format.size = 10;
			format.bold = true;
						
			var timeText_mc:TextField = new TextField();
			timeText_mc.autoSize = TextFieldAutoSize.LEFT;
            timeText_mc.background = false; //use true for doing generic labels
            timeText_mc.border = false;      // ** same
			//timeText_mc.embedFonts = true;
			timeText_mc.antiAliasType = "advanced";
			timeText_mc.gridFitType = GridFitType.NONE;
			timeText_mc.sharpness = -200;
			timeText_mc.wordWrap = false;
            timeText_mc.defaultTextFormat = format;			
			timeText_mc.x = pbBG.x + pbBG.width + 12;
			timeText_mc.y = pbBG.y - 5;
			timeText_mc.width = 200;
			timeText_mc.text = "00:00";
			timeText_mc.name = "time";
			videoControlsContainer.addChild(timeText_mc);
			TweenMax.to(timeText_mc, .6, {glowFilter:{ color:0xDDEEFF, alpha:1, blurX:10, blurY:10 , strength:1, quality:3 }} );
			
			
			var vol:volumeControl = new volumeControl();
			vol.x = mediaBG.x + mediaBG.width - (vol.width) + 2;
			vol.y = mediaBG.y + 6;
			vol.buttonMode = true;
			vol.addEventListener(MouseEvent.ROLL_OVER, handleVolumeControlRollOver);
			vol.addEventListener(MouseEvent.ROLL_OUT, handleVolumeControlRollOut);
			videoControlsContainer.addChild(vol);
			
			volumeScrubber = vol.control.scrub as MovieClip;
			volumeScrubber.addEventListener(MouseEvent.MOUSE_DOWN, volumeScrubberClicked);
			
			vol.muteButton.addEventListener(MouseEvent.CLICK, toggleMute);
			
			videoContainer.addChild(videoControlsContainer);
			videoControlsContainer.x = 0;
			videoControlsContainer.y = 0;
			videoControlsContainer.visible = false;
			videoControlsContainer.alpha = 0;
			
		}
		public function toggleMute(e:MouseEvent):void
		{
			var mute:MovieClip = e.target as MovieClip;
			if (mute.currentFrame == 1)
			{
				previousVolumePosition = volumeScrubber.y;
				setVolume(0);
				volumeScrubber.y = 98;
				mute.gotoAndStop(2);
			}
			else
			{
				volumeScrubber.y = previousVolumePosition;
				var vol:Number = (98 - previousVolumePosition)/84;
				setVolume(vol);
				mute.gotoAndStop(1);
			}
		}
		public function onClick(e:MouseEvent):void
		{
			videoPlayBack.playing ? videoPlayBack.pause() : videoPlayBack.play();
			
		}
		public function progressClick(e:MouseEvent):void
		{	
			
			videoPlayBack.pause();
			videoPlayBack.seek(Math.floor((pbBG.mouseX / 15.75) * videoPlayBack.totalTime));
			trace((pbBG.mouseX / 15.75) * videoPlayBack.totalTime);
			videoPlayBack.play();
		}
		
		public function handleVolumeControlRollOver(e:MouseEvent):void
		{
			var vol:volumeControl = e.target as volumeControl;
			TweenMax.to(vol.control, .75, { y: -110 } );
		}
		public function handleVolumeControlRollOut(e:MouseEvent):void
		{
			var vol:volumeControl = e.target as volumeControl;
			TweenMax.to(vol.control, .75, { y:0 } );
		}
		
		public function handleVideoRollOver(e:MouseEvent):void 
		{
			
			videoControlsContainer.visible = true;
			TweenMax.to(videoControlsContainer, .75, { alpha:1 } );
			stage.addEventListener(MouseEvent.MOUSE_MOVE, showPanel);
		}
		public function handleVideoRollOut(e:MouseEvent):void 
		{
			TweenMax.to(videoControlsContainer, 1.5, { alpha:0 } );
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, showPanel);

		}
		
		public function showPanel(e:Event):void {
			videoControlsContainer.visible = true;
			Mouse.show();
			TweenMax.to(videoControlsContainer, .75, { alpha:1 } );
			myTimer.reset();
			myTimer.start();
		}
		public function timerHandler(e:TimerEvent):void {
			TweenMax.to(videoControlsContainer, 1.5, { alpha:0 } );
			Mouse.hide();
		}

		
		public function handleStageMouseMove(e:MouseEvent):void
		{
			
		}
		public function unload():void
		{
			videoPlayBack.stop();
		}
		
		public function videoStateHandler(e:VideoEvent):void 
		{
				//trace(e.state);
			//if (cueCount < cuePoints.length)
			//{
				/*if (pb)
				{
					pb.width = (528) * (videoPlayBack.playheadPercentage / 100);
				}*/
				//trace("width: - - - - - - - -  - > " + pb.width);
				//pb.width = videoPlayBack.bytesLoaded * 1020 / videoPlayBack.bytesTotal;
				
			//}
				switch(e.state)
				{
					case "playing":
						dispatchEvent(new Event("ASSET_LOADED"));
						playPause.gotoAndStop(1);
						break;
						
					case "paused":
						playPause.gotoAndStop(2);
						break;
						
					default:
						break;
				}
			
		
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
			time = formatTime(videoPlayBack.playheadTime) + " / " + formatTime(videoPlayBack.totalTime);
			
			TextField(videoControlsContainer.getChildByName("time")).text = time;
			
			
			// checks, if user is scrubbing. if so, seek in the video
			// if not, just update the position of the scrubber according
			// to the current time
			if (bolProgressScrub)
			{
				videoPlayBack.pause();
				var seekNum:Number = (scrubber.x - pb.x) / 528 * videoPlayBack.totalTime;
				videoPlayBack.seek(Math.round(seekNum));
			}
			else
			{
				scrubber.x = pb.x + videoPlayBack.playheadTime * 528 / videoPlayBack.totalTime;
			}
			
			if (pb)
			{
				pb.width = (528) * (videoPlayBack.playheadPercentage / 100);
				
			}
			if (Math.floor(videoPlayBack.playheadPercentage) == 90)
			{
				//trace("look to buffer next movie");
				//trace(videoPlayBack.getVideoPlayer(0));
				//videoPlayBack.activeVideoPlayerIndex = 1;
				//videoPlayBack.load("assets/media/values/video/values_1_frosty.smil");				
			}
		}
		
		
		public function metadataReceived(evt:MetadataEvent):void 
		{
			tmrDisplay.start();
			/*trace("duration:", evt.info.duration); // 16.334
			trace("framerate:", evt.info.framerate); // 15
			trace("width:", evt.info.width); // 320
			trace("height:", evt.info.height); // 213*/
			
			videoPlayBack.width = 1024;
			//videoPlayBack.width = evt.info.width;
			videoPlayBack.height = 768;
			//videoPlayBack.height = evt.info.height;
			var videoplayer:VideoPlayer = videoPlayBack.getVideoPlayer(0);
			videoplayer.smoothing = true;
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
		
		public function progressScrubberClicked(e:MouseEvent):void 
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseReleased);

			// set progress scrub flag to true
			bolProgressScrub = true;
			
			// start drag
			scrubber.startDrag(false, new Rectangle(pb.x, pb.y-2, 528, 0));
		}

		public function volumeScrubberClicked(e:MouseEvent):void 
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseReleased);

			// set volume scrub flag to true
			bolVolumeScrub = true;
			
			// start drag
			volumeScrubber.startDrag(false, new Rectangle(18, 14, 0, 84));
		}

		
		public function mouseReleased(e:MouseEvent):void 
		{
			// set progress/volume scrub to false
			bolVolumeScrub		= false;
			if (bolProgressScrub)
			{
				bolProgressScrub = false;
				videoPlayBack.pause();
				var seekNum:Number = (scrubber.x - pb.x) / 528 * videoPlayBack.totalTime;
				videoPlayBack.seek(Math.round(seekNum));
			}
			
			// stop all dragging actions
			scrubber.stopDrag();
			volumeScrubber.stopDrag();
			
			videoPlayBack.play();
			
			// update progress/volume fill
			pb.width = (scrubber.x - pb.x)/528;
			
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseReleased);

		}
		public function setVolume(volume:Number = 0):void 
		{
			// create soundtransform object with the volume from
			// the parameter
			//var sndTransform:SoundTransform		= new SoundTransform(intVolume);
			// assign object to netstream sound transform object
			videoPlayBack.volume = volume;
			
			// hides/shows mute and unmute button according to the
			// volume
			/*if(intVolume > 0) {
				mcVideoControls.btnMute.visible		= true;
				mcVideoControls.btnUnmute.visible	= false;
			} else {
				mcVideoControls.btnMute.visible		= false;
				mcVideoControls.btnUnmute.visible	= true;
			}*/
		}
		public function formatTime(t:int):String 
		{
			// returns the minutes and seconds with leading zeros
			// for example: 70 returns 01:10
			var s:int = Math.round(t);
			var m:int = 0;
			if (s > 0) 
			{
				while (s > 59) 
				{
					m++;
					s -= 60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			} 
			else 
			{
				return "00:00";
			}
		}
		public function updateDisplay(e:TimerEvent):void 
		{
			// checks, if user is scrubbing. if so, seek in the video
			// if not, just update the position of the scrubber according
			// to the current time
			if (bolProgressScrub)
			{
				pb.width = (scrubber.x - pb.x);
			}
			
			// update volume when user is scrubbing
			if (bolVolumeScrub) 
			{
				var vol:Number = (98 - volumeScrubber.y)/84;
				setVolume(vol);
			}
		
		}
	}
	
}