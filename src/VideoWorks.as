package
{
	import flash.net.NetStream;
	//Context Class
	class VideoWorks
	{
		var playState:State;
		var stopState:State;
		var pauseState:State;
		var state:State;
		
		public function VideoWorks()
		{
			trace('Video Player is on');
			playState = new PlayState(this);
			stopState = new StopState(this);
			pauseState = new PauseState(this);
			state = stopState;
		}
		public function startPlay(ns:NetStream, flv:String):void 
		{
			state.startPlay(ns, flv);
		}
		public function stopPlay(ns:NetStream):void
		{
			state.stopPlay(ns);
		}
		public function doPause(ns:NetStream):void 
		{
			state.doPause(ns);
		}
		public function setState(state:State):void
		{
			trace("a new state is set");
			this.state =  state;
		}
		public function getState():State 
		{
			return state;
		}
		public function getPlayState():State
		{
			return this.playState;
		}
		public function getStopState():State
		{
			return this.stopState;
		}
		public function getPauseState():State 
		{
			return this.pauseState;
		}
	}
}