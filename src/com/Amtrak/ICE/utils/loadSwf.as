package com.Amtrak.ICE.utils {	
	
	import flash.events.*;
    import flash.net.URLRequest;
    //import flash.net.URLLoader;
	import flash.display.Loader;

	/**
	 * ...
	 * @author Paul Makarov
	 */
	
	
    public class loadSwf extends EventDispatcher 
	{
       
        public var myLoader:Loader;
        private var mySWFURL:URLRequest;
        private var SWF_URL:String;

        public function loadSwf(url:String) 
		{
            SWF_URL = url;
            mySWFURL = new URLRequest(SWF_URL);
            myLoader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			//myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			myLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleError);
			myLoader.load(mySWFURL);
            
        }
        private function completeHandler(e:Event):void 
		{
            dispatchEvent(new Event(Event.COMPLETE) );

        }
        private function handleError(event:IOErrorEvent):void 
		{
            trace("Error loading SWF");
        }
		
		public function getSwf() : Loader { return myLoader; }
    }
}