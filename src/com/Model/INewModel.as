package com.Model
{
	import flash.events.*;
	
	public interface INewModel extends IModel
	{
		function getMapTypeList():Array
		function getMapType():uint
		function setMapType(index:uint):void
	}
}