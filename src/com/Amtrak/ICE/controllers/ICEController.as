package com.Amtrak.ICE.controllers 
{
	import com.Amtrak.ICE.scorm.SCORM;
	import com.Amtrak.ICE.utils.FlashVarUtil;
	import flash.display.LoaderInfo;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class ICEController extends EventDispatcher
	{
		public var scorm:SCORM;
		public var lmsConnected:Boolean;
		public var lessonStatus:String;
		public var success:Boolean;
		public var configData:String;
		public var _playerMode:String;
		public var hosted:Boolean;
		public var hostAPI:String;
		public var branding:String;
		public var username:String;
		public var password:String;
		//public var dataManager:Object;
		
		public function ICEController(paramObj:Object = null)
		{
			
			/* 
			 * _playerMode = [ "PRESENTATION", "SCENARIO", "INTERACTIVE_PRACTICE", "TUTORIAL"]
			 */
			
			if (paramObj)
			{
				configData = "data/" + FlashVarUtil.getValue("data");
				username = FlashVarUtil.getValue("username");
				password = FlashVarUtil.getValue("password");
				
			}
			else
			{
				configData = "data/myPRIME_taxonomy.xml" ;
				_playerMode = "PRESENTATION";
				hosted = false;
				username = "TK";
				password = "421";
				lmsConnected = false;
				lessonStatus = "";
				success = false;
			}
			
		}
		
	}

}