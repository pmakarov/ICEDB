package com.Amtrak.ICE {
	

	public class Step 
	{
		public var type:String = "";
		public var id:String = "";
		public var title:String = "";
		public var src:String = "";
		public var condition:String = "";
		public var component:Object;
		public var priority:int;
        public var position:int;
		public var complete:Boolean;
		public var count:uint;
		public var savePoint:String;

		public function Step( xml:XML ) : void
		{
			id = xml.@id;
			type = xml.@type;
			title = xml.title;
			src = xml.file.@src;	
			condition = xml.@condition;
			component = new Object();
			complete = false;
		}
	}
}
