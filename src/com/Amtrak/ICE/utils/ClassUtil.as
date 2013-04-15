package com.Amtrak.ICE.utils {	
	
	import flash.events.*;
   	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */

    public class ClassUtil extends EventDispatcher 
	{
		
		public function getClassName(o:Object):String
		{
			var fullClassName:String = getQualifiedClassName(o);
			//use this line to remove standard MC info
			//return fullClassName.slice(fullClassName.lastIndexOf("::") + 2);
			return fullClassName;
		}
		public function sampleFunction():void
        {
            trace(" from sampleFunction()");
        }

    }
}