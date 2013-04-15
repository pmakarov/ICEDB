package com.Amtrak.ICE
{
	import flash.events.Event;
	public class ICETimedTextEvent extends Event
	{

		public static const CAPTION_UPDATED: String = "captionUpdated";
		public var data:Object;

		public function ICETimedTextEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new ICETimedTextEvent (type, data, bubbles, cancelable);
		}
	}
}

