package com.Model
{
	import flash.events.*;
	
	public interface IModel extends IEventDispatcher
	{
		function getRegionList():Array
		function getRegion():uint
		function setRegion(index:uint):void
		function getMapURL():String
	}
}