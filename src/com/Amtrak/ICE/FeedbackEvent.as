package com.Amtrak.ICE
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class  FeedbackEvent extends Event
	{
		// Rather than use a string for adding event listeners, we use
		// a constant so we avoid typos
		public static const EVALUATION_TYPE:String = "feedback";
		
		// The amount we need to incrememnt by
		public var title:String;
		public var text:String;
		public var value:String;
		public var audio:String;
		public var video:String;
		public var windowType:String;
		
		
		public function FeedbackEvent( fb:Object ) 
		{
			super( EVALUATION_TYPE );
			title = fb.title;
			value = fb.value;
			text = fb.text;
			audio = fb.audio;
			video = fb.video;
			windowType = fb.windowType;
		}
		
		override public function clone () : Event {
			return new FeedbackEvent ( { title: title, value: value, text: text, windowType: windowType, audio: audio, video: video } );
		}

	}
	
}