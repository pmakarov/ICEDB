package com.Amtrak.ICE {
	

	public class Lesson	 
	{
		
		public var id:String = "";
		public var title:String = "";
		public var url:String = "";
		public var complete:Boolean = false;
		public var active:Boolean = false;
		public var unlocked:Boolean = false;

		public function Lesson( xml:XML ) : void
		{
			id = xml.@id;
			title = xml.title;
			url = xml.url;
		}
	}
}
