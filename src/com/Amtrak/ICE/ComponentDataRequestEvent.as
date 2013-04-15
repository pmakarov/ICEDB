package com.Amtrak.ICE
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class ComponentDataRequestEvent extends Event
	{
		// Rather than use a string for adding event listeners, we use
		// a constant so we avoid typos
		public static const REQUEST_TYPE:String = "data";
		public static const RESPONSE_TYPE:String = "data";
		public var componentID:String;
		
		public function ComponentDataRequestEvent( cdr:Object ) 
		{
			super( REQUEST_TYPE );
			componentID = cdr.componentID;
		}

	}
	
}