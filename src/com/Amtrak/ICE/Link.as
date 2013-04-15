package com.Amtrak.ICE {
	

	public class Link 
	{
		public var type:String = "";
		public var id:String = "";
		public var title:String = "";
		public var src:String = "";
		public var desc:String = "";
		public var complete:Boolean = false;
		public var active:Boolean = false;
		public var unlocked:Boolean = false;

		public function Link( xml:XML ) : void
		{
			id = xml.@id;
			type = xml.@type;
			title = xml.title;
			src = xml.file.@src;	
			desc = xml.desc;
		}
	}
}
