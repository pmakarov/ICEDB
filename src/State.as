package
{
	import flash.net.NetStream;
	//State Machine Interface
	interface State
	{
		function startPlay(ns:NetStream, flv:String):void;
		function stopPlay(ns:NetStream):void;
		function doPause(ns:NetStream):void;
	}
}