package com.Amtrak.ICE.utils
{
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.*;
 
	public class ThePreloader extends MovieClip
	{
 
		private var fullWidth:Number; //the width of our mcPreloaderBar at 100%
		public var ldrInfo:LoaderInfo;
		private var mcPreloaderBar:PreloaderBar;
 
		public function ThePreloader(fullWidth:Number = 0, ldrInfo:LoaderInfo = null)
		{
			this.fullWidth = fullWidth;
			this.ldrInfo = ldrInfo;
			mcPreloaderBar = new PreloaderBar();
			this.addChild(mcPreloaderBar);
			mcPreloaderBar.x = -250;
			mcPreloaderBar.y = -10.85;
			addEventListener(Event.ENTER_FRAME, checkLoad);
		}
 
		private function checkLoad (e:Event) : void
		{
			if (ldrInfo.bytesLoaded == ldrInfo.bytesTotal && ldrInfo.bytesTotal != 0)
			{
				//loading complete
				dispatchEvent(new Event("loadComplete"));
				phaseOut();
			}
 
			updateLoader(ldrInfo.bytesLoaded / ldrInfo.bytesTotal);
		}
 
		private function updateLoader(num:Number) : void
		{
			//num is a number between 0 and 1
			trace(num);
			mcPreloaderBar.width = num * fullWidth;
		}
 
		private function phaseOut() : void
		{
			removeEventListener(Event.ENTER_FRAME, checkLoad);
			phaseComplete();
		}
 
		private function phaseComplete() : void
		{
			dispatchEvent(new Event("preloaderFinished"));
		}
 
	}
 
}