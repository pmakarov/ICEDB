package com.Amtrak.ICE
{
    import flash.display.Sprite;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.events.Event;
 
	/**
	 * (c) 2010 Zach Foley
	 * This class will preload a video to be used as part of an interactive video.
	 */
    public class FLVPreloader extends Sprite {
        private var videoURL:String = "PATH TO YOUR VIDEO FILE HERE OR PASS IT INTO THE CONSTRUCTOR";
        private var connection:NetConnection;
		public var stream:NetStream;
		public static const READY:String = "FLVPreloader_flvisready";
		public static const LOADING:String = "FLVPreloader_flvisloading";
		private var _loadProgress:Number;
		public var video:Video;
		// The cleint object is a generic object that listens for events from the netstream it must have specific methods or errors will be thrown
		private var _client:Object;
        public function FLVPreloader(client:Object = null, url:String = null ) {
			if (url != null) {
				videoURL = url;
			}
			if (client == null) {
				client = this;
			} else {
				_client = client;
			}
            connection = new NetConnection();
            connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            connection.connect(null);
        }
        private function netStatusHandler(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Stream not found: " + videoURL);
                    break;
            }
        }
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
		/**
		 * This is the function that connects up the netstream
		 */
        private function connectStream():void {
            stream = new NetStream(connection);
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.client = _client;
			addEventListener(Event.ENTER_FRAME, checkNetsreamLoadStatus)
            video = new Video();
			video.width = 850;
			video.height = 456
			video.y = 45;
            video.attachNetStream(stream);
			// THE MAGIN SECRET TRICK IS HERE!
            stream.play(videoURL); //LOAD IT
			stream.pause(); // PAUSE IT!
			stream.seek(0);// TELL IT TO WAIT ON THE FIRST FRAME UNTIL YOU TELL IT TO PLAY LATER
			// VOILA!
            addChild(video);
        }
 
		private function checkNetsreamLoadStatus(e:Event):void
		{
			if (stream.bytesLoaded / stream.bytesTotal >= 1) {
				dispatchEvent(new Event(FLVPreloader.READY));
				removeEventListener(Event.ENTER_FRAME, checkNetsreamLoadStatus);
			} else {
				_loadProgress = stream.bytesLoaded / stream.bytesTotal
				dispatchEvent(new Event(FLVPreloader.LOADING));
			}
		}
		/**
		 * use this property to tell you preloader how the video load is going.
		 */
		public function get loadProgress():Number { return _loadProgress; }
 
		// DEFAULT CLIENT METHODS
		// IF YOU MAKE YOUR OWN CLIENT OR PASS ONE THROUGH THE CONSRUCTOR
		// BE SURE TO IMPLEMENT EACH OF THE METHODS BELOW
		public function onMetaData(info:Object):void {
			trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		}
		public function onCuePoint(info:Object):void {
			trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		public function onXMPData(infoObject:Object):void
		{
			trace("onXMPData Fired\n");
			var cuePoints:Array = new Array();
			var cuePoint:Object;
			var strFrameRate:String;
			var nTracksFrameRate:Number;
			var strTracks:String = "";
			var onXMPXML:XML = new XML(infoObject.data);
			// Set up namespaces to make referencing easier
			var xmpDM:Namespace = new Namespace("http://ns.adobe.com/xmp/1.0/DynamicMedia/");
			var rdf:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
			for each (var it:XML in onXMPXML..xmpDM::Tracks)
			{
				 var strTrackName:String = it.rdf::Bag.rdf::li.rdf::Description.@xmpDM::trackName;
				 var strFrameRateXML:String = it.rdf::Bag.rdf::li.rdf::Description.@xmpDM::frameRate;
				 strFrameRate = strFrameRateXML.substr(1,strFrameRateXML.length); 
 
				 nTracksFrameRate = Number(strFrameRate);  
 
				 strTracks += it;
			}
			var onXMPTracksXML:XML = new XML(strTracks);
			var strCuepoints:String = "";
			for each (var item:XML in onXMPTracksXML..xmpDM::markers)
			{
				strCuepoints += item;
			}
			trace(strCuepoints);
		} 
 
	}
}