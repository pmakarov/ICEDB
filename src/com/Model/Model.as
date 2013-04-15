package com.Model
{
	import flash.events.*;
	
	public class Model extends EventDispatcher implements IModel
	{
		protected var aRegions:Array;
		protected var chosenRegion:uint;
		
		protected var aImageURLs:Array;
		
		public function Model()
		{
			this.aRegions = new Array("East Coast", "West Coast", "Puerto Rico", "Alaska", "Hawaii");
			this.aImageURLs = new Array(
			"http://www.goes.noaa.gov/GIFS/ECVS.JPG",
			"http://www.goes.noaa.gov/GIFS/WCVS.JPG",
			"http://www.goes.noaa.gov/GIFS/PRVS.JPG",
			"http://www.goes.noaa.gov/GIFS/ALVS.JPG",
			"http://www.goes.noaa.gov/GIFS/HAVS.JPG");			
		}
		
		public function getRegionList():Array
		{
			return aRegions;
		}
		
		public function getRegion():uint
		{
			return this.chosenRegion;
		}
		
		public function setRegion(index:uint):void
		{
			this.chosenRegion = index;
			this.update();
		}
		
		public function getMapURL():String
		{
			return this.aImageURLs[chosenRegion];
		}
		
		protected function update():void
		{
			dispatchEvent(new Event(Event.CHANGE)); //dispatch event
		}
	}
}