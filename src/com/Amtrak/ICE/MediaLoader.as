package com.Amtrak.ICE
{
	import com.Amtrak.ICE.components.ICEVideoPlayer;
	import fl.containers.UILoader;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.*;
	import flash.events.*;
	import flash.media.Video;
	import fl.video.*;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	
	public class MediaLoader extends Sprite
	{
		private var url:String;
		private var mediaPath:String;
		private var dataPath:String;
		public var loader:UILoader;
		private var ns:NetStream;
		private var s:Sound;
		private var channel:SoundChannel;
		private var screenWidth:Number = 440;
		private var screenHeight:Number = 330;
		private var mediaType:String = "";
		private var vid:Video;
		
		private var hasSound:Boolean = false;
		
		public function MediaLoader(url:String="")
		{
			this.url = url;
			//this.mediaPath = "assets/media/";
			//this.dataPath = "data/sample_data/";
		}
		public function get Height():Number
		{
			return this.screenHeight;
		}
		public function get Width():Number
		{
			return this.screenWidth;
		}
		public function set Width(num:Number):void
		{
			this.screenWidth = num;
		}
		public function set Height(num:Number):void
		{
			this.screenHeight = num;
		}
		public function loadMedia(url:String):void
		{
			
			//trace(url);
			//clearMedia();
			mediaType = extractFileType(url);
			switch(mediaType)
			{
				
				case "flv":
				case "f4v":
				case "mov":
				//url = mediaPath+"/video/" + url;
				handleFLV(url);
				break;
				
				case "jpg":
				case "swf":
				//url = mediaPath + url;
				handleSWF(url);
				break;
				
				case "mp3":
				case "wav":
				//url = mediaPath + url;
				handleAudio(url);
				break;
				
			default:
				trace("unrecognized file type");
				break;
			}
			url = "";
		}
		public function clearMedia():void
		{		
			switch(mediaType)
			{
				
				case "jpg":
				case "swf":
					//this.loader.unloadAndStop();
					this.loader.unload();
					break;
					
				case "flv":
				case "f4v":	
				case "mov":
					ns.close();
					this.removeChild(this.getChildByName("video"));
					break;
					
				case "mp3":
				case "wav":
					SoundMixer.stopAll();
					break;
					
				default:
					break;
			}
			
			if (this.loader)
			{
				trace("clearing content from a loader");
				Loader(this.loader).unloadAndStop();
			}
			if (this.getChildByName("video"))
			{
				if (ns)
				{
					ns.close();
				}
				ICEVideoPlayer(this.getChildByName("video")).unload();
				this.removeChild(this.getChildByName("video"));
			}
			if (this.s)
			{
				SoundMixer.stopAll();
			}
		}
		private function handleAudio(url:String):void
		{
			s = new Sound(new URLRequest(url));
			s.addEventListener(Event.COMPLETE, doSoundLoadComplete);
			channel = new SoundChannel();
			
			
		}
		public function doSoundComplete(evt:Event):void
		{
			//trace("Sound Complete");
			dispatchEvent(new Event("SOUND_COMPLETE"));
		}
		public function playSound():void
		{
			if (this.s)
			{
				channel = s.play();
			}
		}
		public function stopSound():void
		{
			if (this.s)
			{
				if (this.channel)
				{
					this.channel.stop();
					this.channel = null;
				}
			}
		}
		public function doSoundLoadComplete(e:Event):void
		{
			channel = s.play();
			channel.addEventListener(Event.SOUND_COMPLETE, doSoundComplete);
			dispatchEvent(new Event("ASSET_LOADED"));	
		}
		private function handleSWF(url:String):void
		{
			//singleton it
			if (!this.getChildByName("loader"))
			{
				loader = new UILoader();
				loader.name = "loader";
				this.addChild(loader);
			}
			
			loader.load(new URLRequest(url));
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);

		}
		
		private function loaderCompleteHandler(e:Event):void 
		{
			this.loader.content.addEventListener("ASSET_COMPLETE", handleComplete);
			//trace(loader.content.width + " : " + loader.content.height + " : " + this.Width + " : " + this.Height );
			//loader.content.width = this.Width;
			//loader.content.height = this.Height;
			//loader.content.scaleY = (this.Height/loader.content.height);
			//trace(loader.content.scaleY + " : " + loader.content.height);
			//trace(loader.content.scaleX + " : " + loader.content.scaleY);
			//this.loader.content.addEventListener("EVALUATE_ASSET", handleEvaluate);
			this.loader.maintainAspectRatio = false;
			this.loader.scaleContent = true;
			loader.width = this.Width;
			loader.height = this.Height;
			dispatchEvent(new Event("ASSET_LOADED"));
			
		}
		private function handleComplete(e:Event):void
		{
			dispatchEvent(new Event("ASSET_COMPLETE"));
		}
		private function handleEvaluate(e:Event):void
		{
			//dispatchEvent(new Event("EVALUATE_ASSET", true, true));
		}
		private function handleFLV(url:String):void
		{		
			vid = new Video();
			vid.name = "video";
			vid.height = this.screenHeight;
			vid.width = this.screenWidth;
			//vid.addEventListener(VideoEvent.COMPLETE, vidComplete);
			vid.smoothing = true;
			this.addChild(vid);
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);

			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, doNetStatus);
			vid.attachNetStream(ns);
			
			var listener:Object = new Object();
			listener.onMetaData = function(evt:Object):void 
			{
				//trace("metadata: duration=" + evt.duration + " width=" + evt.width + " height=" + evt.height + " framerate=" + evt.framerate);
			};
			ns.client = listener;		
			ns.play(url);
			

		}
		private function doNetStatus(e:NetStatusEvent):void
		{
				if (e.info.code == "NetStream.Play.Start")
				{
					trace("here");
					//dispatchEvent(new Event("ASSET_LOADED"));
				}
				else if (e.info.code == "NetStream.Buffer.Full")
				{
					dispatchEvent(new Event("ASSET_LOADED"));
				}
				
				else if (e.info.code == "NetStream.Play.Stop")
				{ 
					trace("secondsPassed: " + ns.time);
					//dispatchEvent(new Event("ASSET_COMPLETE", true, true));
					dispatchEvent(new Event("EVALUATE_ASSET", true, true));
					
				}
		}
		
		/*private function vidComplete(e:VideoEvent):void
		{
			trace("yo yo it's done son!");
		}*/
		
		public function extractFileType(file:String):String 
		{
			var extensionIndex:Number = file.lastIndexOf(".");
			if (extensionIndex == -1) 
			{
				//No extension
				return "";
			} 
			else 
			{
				return file.substr(extensionIndex + 1,file.length);
			}
		}
		
	}
	
}