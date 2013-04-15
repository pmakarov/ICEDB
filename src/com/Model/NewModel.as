package com.Model
{
	import flash.events.*;
	
	public class NewModel extends Model implements INewModel
	{
		protected var aMapTypes:Array;
		protected var chosenMapType:uint;
		
		protected var aIRImageURLs:Array;
		
		public function NewModel()
		{
			this.aIRImageURLs = new Array(
			"http://www.goes.noaa.gov/GIFS/ECIR.JPG",
			"http://www.goes.noaa.gov/GIFS/WCIR.JPG",
			"http://www.goes.noaa.gov/GIFS/PRIR.JPG",
			"http://www.goes.noaa.gov/GIFS/ALIR.JPG",
			"http://www.goes.noaa.gov/GIFS/HAIR.JPG");	
			
			this.aMapTypes = new Array( "vissible", "Infrared");
			this.chosenMapType = 0;
		}
		
		public function getMapTypeList():Array
		{
			return aMapTypes;
		}
		
		public function getMapType():uint
		{
			return this.chosenMapType;
		}
		
		public function setMapType(index:uint):void
		{
			this.chosenMapType = index;
			this.update();
		}
		
		
		override public function getMapURL():String
		{
			switch(chosenMapType)
			{
				case 1: 
					return this.aIRImageURLs[chosenRegion];
					break;
					
				default:
					return this.aImageURLs[chosenRegion];
					break;
					
			}
			
			//return this.aImageURLs[chosenRegion];
		}
		
		
	}
}