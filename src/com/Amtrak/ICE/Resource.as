package com.Amtrak.ICE {
	

	public class Resource 
	{
		public var href:String = "";
		public var title:String = "";

		public function Resource( xml:XML ) : void
		{
			
			title = xml.toString();
			href = xml.@href.toString();	
		}
	}
}
