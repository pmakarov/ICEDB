package com.Amtrak.ICE
{
	public class amtrakUser
	{
		public var uid:String;
		public var name:String;
		public var pass:String;
		public var mail:String;
		public var location:Object
		public var currentLocation:String;
		public var totalProgress:uint;
		public var lesson:uint;
		
		
		public function amtrakUser():void
		{
			uid = "";
			name = "";
			pass = "";
			mail = "";
			location = new Object();
			currentLocation = "";
			totalProgress = 0;
			lesson = 0;
		}		
	}
}