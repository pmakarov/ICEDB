package
{
	import flash.net.NetStream;
	class PlayState implements State
	{
		var videoWorks:VideoWorks;
		public function PlayState(videoWorks:VideoWorks)
		{
			trace("-- play state --");
			this.videoWorks = videoWorks;
		}
		public function startPlay(ns:NetStream, flv:String):void
		{
			trace("no need.. already playing");
		}
		public function stopPlay(ns:NetStream):void
		{
			ns.close();
			trace("stop playing");
			videoWorks.setState(videoWorks.getStopState());
		}
		public function doPause(ns:NetStream):void
		{
			ns.pause();
			trace("Begin Pause");
			videoWorks.setState(videoWorks.getPauseState());
		}
	}
}