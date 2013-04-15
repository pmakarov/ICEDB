package
{
	import flash.net.NetStream;
	//Pause State
	class PauseState implements State
	{
		var videoWorks:VideoWorks;
		public function PauseState(videoWorks:VideoWorks):void 
		{
			trace("- - Pause State - -");
			this.videoWorks = videoWorks;
		}
		public function startPlay(ns:NetStream, flv:String):void 
		{
			trace("you have to go to unpause");
		}
		public function stopPlay(ns:NetStream):void 
		{
			trace("Don't go to Stop from Pause");
		}
		public function doPause(ns:NetStream):void
		{
			ns.togglePause();
			trace("Quit pausing.");
			videoWorks.setState(videoWorks.getPauseState());
		}
	}
}