package com.Amtrak.ICE.utils 
{
	import com.Amtrak.ICE.Lesson;
	import com.Amtrak.ICE.Resource;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class CourseXMLLoader extends EventDispatcher
	{
		protected var xml:XML;
		protected var courseID:String;
		protected var courseTitle:String;
		protected var steps:Array = [];
		protected var help:Array = [];
		protected var resources:Array = [];
		
		public function CourseXMLLoader(url:String) 
		{
			trace(url);
			super(this);
			var loader:URLLoader = new URLLoader();			
			loader.addEventListener( Event.COMPLETE, onLoadXML );
			loader.dataFormat = "e4x";
			loader.load( new URLRequest(url) );
		}
		
		protected function onLoadXML( e:Event ) : void
		{
			var loader:URLLoader = e.target as URLLoader;
			xml = new XML(loader.data);		
			
			courseID = xml.module.@id.toString();
			courseTitle = xml.module.title.toString();
			for each (var helps:XML in xml..doc)
			{
				var o:Object = new Object();
				o.title = helps.toString();
				o.href = helps.@href.toString();
				help.push(o);
				//trace(resource);
			}
			
			for each (var step:XML in xml..node.url)
			{
				//trace(step);	
				steps.push( new Lesson(step) );
			}
			
			for each (var resource:XML in xml..resource)
			{
				//trace(resource);
				resources.push( new Resource(resource));
				
			}
		
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		public function getNodes() : Array { return steps; }
		public function getResources() : Array { return resources;}
		public function getCourseID():String { return courseID; }
		public function getCourseTitle():String { return courseTitle; }
		public function getXML():XML { return xml; } 
		public function getHelp():Array {return help; } 
		
	}
	
}
