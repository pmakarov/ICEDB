package
{
	import flash.net.NetStream;
	class StopState implements State
	{
		var videoWorks:VideoWorks;
		public function StopState(videoWorks:VideoWorks)
		{
			trace("-- stop state --");
			this.videoWorks = videoWorks;
		}
		public function startPlay(ns:NetStream, flv:String):void 
		{
			ns.play(flv);
			trace("begin playing");
			videoWorks.setState(videoWorks.getPlayState());
		}
		public function stopPlay(ns:NetStream):void 
		{
			trace("no need... you are already stopped");
		}
		public function doPause(ns:NetStream):void
		{
			trace("cannot go from Stop to Pause");
		}
	}
}