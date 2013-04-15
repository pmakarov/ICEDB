package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	//implement fms2 app
	
	public class TestVid extends Sprite
	{
		private var nc:NetConnection = new NetConnection();
		private var ns:NetStream;
		private var vid:Video = new Video(721, 405);
		private var vidTest:VideoWorks;
		private var playBtn:NetBtn;
		private var stopBtn:NetBtn;
		private var flv:String;
		private var flv_txt:TextField;
		private var dummy:Object;
		
		public function TestVid():void 
		{
			nc.connect(null);
			ns = new NetStream(nc);
			addChild(vid);
			
			vid.x = (stage.stageWidth / 2) - (vid.width / 2);
			vid.y = (stage.stageHeight / 2) - (vid.height / 2);
			
			//instantiate state machine
			vidTest = new VideoWorks();
			
			//play and stop buttons
			playBtn = new NetBtn("Play");
			addChild(playBtn);
			playBtn.x = (stage.stageWidth / 2) - 50;
			playBtn.y = 547;
			stopBtn = new NetBtn("Stop");
			addChild(stopBtn);
			stopBtn.x = (stage.stageWidth / 2) +50;
			stopBtn.y = 547;
			
			var pauseBtn:NetBtn = new NetBtn("Pause");
			addChild(pauseBtn);
			pauseBtn.x = (stage.stageWidth / 2 + 100) - pauseBtn.width;
			pauseBtn.y = 365;
			
			//add listeners
			playBtn.addEventListener(MouseEvent.CLICK, doPlay);
			stopBtn.addEventListener(MouseEvent.CLICK, doStop);
			pauseBtn.addEventListener(MouseEvent.CLICK, pauseNow);
			
			//add the text field
			flv_txt = new TextField();
			flv_txt.border = true;
			flv_txt.borderColor = 0x9e0039;
			flv_txt.background = true;
			flv_txt.backgroundColor = 0xfab383;
			flv_txt.type = TextFieldType.INPUT;
			flv_txt.x = (stage.stageWidth / 2) - 45;
			flv_txt.y = 10;
			flv_txt.width = 90;
			flv_txt.height = 16;
			addChild(flv_txt);
			
			//this prevents a MetaData error being thrown
			dummy = new Object();
			ns.client = dummy;
			dummy.onMetaData = getMeta;
			
			//NetStream
			ns.addEventListener(NetStatusEvent.NET_STATUS, flvCheck);
			
		}
		
		//MetaData
		private function  getMeta(mdata:Object):void 
		{
			trace("onMetaData:" + mdata.duration);
		}
		
		//Handle FLV
		private function flvCheck(event:NetStatusEvent):void 
		{
			 //trace(event.info.code);
			switch(event.info.code)
			{
				case "NetStream.Play.Stop":
					vidTest.stopPlay(ns);
					vid.clear();
					break;
					
				case "NetStream.Play.StreamNotFound":
					vidTest.stopPlay(ns);
					flv_txt.text =  "File not found";
					break;
					
				default:
					break;
			}
		}
		
		//Start play
		private function doPlay(e:MouseEvent):void
		{
			if (flv_txt.text != "" && flv_txt.text != "Provide file name")
			{
				flv_txt.textColor = 0x000000;
				flv = "assets/media/video/" + flv_txt.text + ".f4v";
				vidTest.startPlay(ns, flv);
				vid.attachNetStream(ns);
			}
			else
			{
				flv_txt.textColor = 0xCC0000;
				flv_txt.text = "Provide file name";
			}
		}
		
		//Stop play
		private function doStop(e:MouseEvent):void 
		{
			vidTest.stopPlay(ns);
			vid.clear();
		}
		
		private function pauseNow(e:MouseEvent):void 
		{
			
			vidTest.doPause(ns);
		}
	}
}