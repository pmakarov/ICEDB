package com.Amtrak.ICE.utils {	
	
	import flash.events.*;
    import flash.net.URLRequest;
    import flash.net.URLLoader;

	/**
	 * ...
	 * @author Paul Makarov
	 */
	
    public class loadXml extends EventDispatcher {
        public var myXML:XML;
        private var myXLoader:URLLoader;
        private var myXMLURL:URLRequest;
        private var XML_URL:String;

        public function loadXml(url:String) {
            myXML = new XML();
            XML_URL = url;
            myXMLURL = new URLRequest(XML_URL);
            myXLoader = new URLLoader(myXMLURL);
            myXLoader.addEventListener(Event.COMPLETE, completeHandler);
            myXLoader.addEventListener(IOErrorEvent.IO_ERROR, handleError);
        }
        private function completeHandler(e:Event):void {
            myXML = XML(e.target.data);
            dispatchEvent(new Event("xmlParsed"));

        }
        private function handleError(event:IOErrorEvent):void {
            trace("Error loading XML");
        }
    }
}