package com.Amtrak.ICE.utils 
{
	import com.ads.Node;
	import com.Amtrak.ICE.Step;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class LessonXMLLoader extends EventDispatcher
	{
		protected var xml:XML;
		protected var lessonID:String;
		protected var lessonTitle:String;
		protected var steps:Array = [];
		protected var edges:Array = [];
		
		public function LessonXMLLoader(url:String) 
		{
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
			lessonID = xml.module.@id.toString();
			lessonTitle = xml.module.title.toString();
			for each (var step:XML in xml..node)
			{
				if (step.hasOwnProperty("file"))
				{
					steps.push( new Step(step) );
					//trace(step);	
				}
			}
		/*	if (xml.edges)
			{
				for each (var edge:XML in xml.edges.edge)
				{
					//trace(edge.@to.toString() + " -> " + edge.@from.toString());
					var tmp:Object = new Object();
					tmp.to = edge.@to.toString();
					tmp.from = edge.@from.toString();
					tmp.weight = edge.@weight.toString();
					edges.push(tmp);
				}
			}*/
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		public function getNodes() : Array { return steps; }
		public function getLessonID():String { return lessonID; }
		public function getLessonTitle():String { return lessonTitle; }
		public function getXML():XML { return xml;} 
		public function getEdges():Array { return edges; }
		public function getNodeByID(name:String):Node
		{
			for (var i:uint = 0; i < steps.length; i++)
			{
				if (name == steps[i].id)
				{
					return new Node(steps[i].title);
				}
			}
			return null;
		}
	}
	
}
