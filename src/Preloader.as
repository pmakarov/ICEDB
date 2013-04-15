package 
{
	import com.myPRIME.videoCoursePlayer.utils.ThePreloader;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	public class Preloader extends MovieClip 
	{
		private var bk:iceBar;
		
		//private var preloader:PreloaderBar;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO show loader
			bk = new iceBar();
			bk.width = stage.stageWidth;
			bk.height = stage.stageHeight;
			addChild(bk);
			
			//var lod:LoadingAnimation = new LoadingAnimation();
			//addChild(lod);
			//this.addChild(preloader);
			
			//preloader.addEventListener("loadComplete", loadAssets);
			//preloader.addEventListener("preloaderFinished", setUp);
			
			
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// TODO update loader
			updateLoader(e.bytesLoaded / e.bytesTotal);
		}
		
		private function checkFrame(e:Event):void 
		{
			
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		private function updateLoader(num:Number) : void
		{
			//num is a number between 0 and 1
			//trace(num);
			bk.mcPreloaderBar.width = num * 500;
		}
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			removeChild(bk);
			startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}