package
{
	
	import com.Amtrak.ICE.ComponentDataRequestEvent;
	import com.Amtrak.ICE.components.ICEVideoPlayer;
	import com.Amtrak.ICE.components.multipleChoiceSingleSelect;
	import com.Amtrak.ICE.controllers.ICEController;
	import com.Amtrak.ICE.Evaluation;
	import com.Amtrak.ICE.EvaluationGenerator;
	import com.Amtrak.ICE.FeedbackEvent;
	import com.Amtrak.ICE.FontManager;
	import com.Amtrak.ICE.ICETimedTextEvent;
	import com.Amtrak.ICE.Lesson;
	import com.Amtrak.ICE.Link;
	import com.Amtrak.ICE.LocalDataManager;
	import com.Amtrak.ICE.MediaLoader;
	import com.Amtrak.ICE.Step;
	import com.Amtrak.ICE.utils.CourseXMLLoader;
	import com.Amtrak.ICE.utils.FlashVarUtil;
	import com.Amtrak.ICE.utils.LessonXMLLoader;
	import com.Amtrak.ICE.utils.ThePreloader;
	import com.Amtrak.ICE.utils.VideoXMLLoader;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.greensock.TweenMax;
	import fl.controls.TextArea;
	import fl.video.FLVPlayback;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.media.SoundMixer;
	import flash.net.*;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	[Frame(factoryClass="Preloader")]
	
	public class Main extends Sprite
	{
		
		protected var stepList:MovieClip;
		protected var lessonXml:LessonXMLLoader;
		protected var courseXml:CourseXMLLoader;
		protected var titleText_mc:TextField;
		private var stepNumber:int = 0;
		private var audioStep:int = 0;
		private var steps:Array;
		private var lessons:Array;
		private var audioSteps:Array;
		private var ml:MediaLoader;
		private var xmlLoader:URLLoader;
		private var sceneXML:VideoXMLLoader;
		private const LEFT:int = 0;
		private const TOP:int = 0;
		
		private var dataPath:String;
		
		private var _playerMode:String;
		private var currentLesson:Lesson;
		
		/* INTEFACE STUFF */
		
		private var ep:explorerTab;
		private var _fullScreen:Boolean;
		private var sB:glassBar;
		private var tB:glassBar;
		private var backdrop:flash.display.MovieClip;
		private var blocker:interfaceBlocker = new interfaceBlocker();
		protected var prevButton:IbaBackArrow;
		protected var nextButton:IbaForwardArrow;
		protected var progressBar:IbaProgressBar;
		protected var fs:fullScreenButton;
		
		protected var cb:closeButton;
		protected var hb:helpButton;
		//protected var tr:treeButton;
		protected var tr:amtrakInfoButton;
		protected var contBox:contenbox;
		protected var capBox:captionBox;
		protected var capText:TextField;
		protected var capTextBox:TextArea;
		protected var ice:ICEController;
		protected var caption:globalCaption;
		protected var dataManager:Object;
		protected var userDataArray:Array;
		protected var resources:Array;
		protected var helpDoc:Array;
		protected var systemMute:Boolean;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			steps = new Array();		
			lessons = new Array();
			var hasFlashVars:Boolean = FlashVarUtil.setFlashVar(LoaderInfo(this.root.loaderInfo).parameters);
			if (ice == null)
			{
				ice = new ICEController(hasFlashVars);
			}
			courseXml = new CourseXMLLoader(ice.configData);
			courseXml.addEventListener(Event.COMPLETE, onCourseXmlLoad);
			
			ExternalInterface.addCallback("setComponentDataById", setComponentDataById);
			ExternalInterface.addCallback("getComponentDataById", getComponentDataById);
			
		}	
		public function onCourseXmlLoad(e:Event):void 
		{
			dataPath = "data/xml/";
			// data model stubs for additional dashboard data
			helpDoc = courseXml.getHelp();
			resources = courseXml.getResources();
			
			lessons = courseXml.getNodes();
			
			dataManager = LocalDataManager.getInstance();
			if (dataManager.handleUserLogin(ice.username + ice.password))
			{
				var user:Object = dataManager.getUser();						
			}
			else
			{
				var userObject:Object = new Object();
				userObject.uid = "1";
				userObject.name = ice.username;
				userObject.pass = ice.password;
				userObject.location = 0;
				userObject.currentLocation = "";
				userObject.totalProgress = 0;
				dataManager.call("LOCAL.setContentObjectModel", lessons);
				dataManager.handleNewUser(userObject);
			}
			
			
			userDataArray = dataManager.call("LOCAL.getProgress", []);
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("onDataManagerLoaded", "DATA_MANAGER_LOADED");
			}
			
		}	

		public function getProgress():void {
			
			userDataArray = dataManager.call("LOCAL.getProgress", []);
			ExternalInterface.call("onUserProgress", userDataArray);
		}
	
		
		public function setComponentDataById(params:Array):void 
		{
			dataManager.call("EvalObject.submitData", params);
		}
		
		public function getComponentDataById(id:String):void
		{
			var arr:Array = new Array();
			arr.push("bleh") // don't feel like restructuring LDM right now..
			arr.push(id); // ensuring id is in array position [1];
			var tmp:Array = new Array();
			tmp = dataManager.call("EvalObject.getData", arr);
			ExternalInterface.call("onGetComponentDataById", tmp);
		}
		
		public function globalRecordLessonComplete():void
		{
			//push the data to the data manager; call local service
			//var index:uint = getCurrentLesson();
			//trace(currentLesson.title +  " : currentLesson.id=" + currentLesson.id);
			var index:uint = parseInt(currentLesson.id);
			
			
			currentLesson.active = false;
			currentLesson.complete = true;
			
			userDataArray[index-1] = 1;
			//trace("user data: " + userDataArray);
		
				var tmp:Array = new Array();
				tmp.push(index);
				dataManager.call("LOCAL.recordLessonComplete", tmp);
			
			var finalLesson:Boolean = (index == lessons.length  || allComplete()) ? true : false;
			
			if (finalLesson == true)
			{
				globalRecordEndOfSCO();
				
			}
			
			
		}
		public function globalRecordEndOfSCO():void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("finishedCourse", "ohYeahWeDone");
			}
		}
		private function getCurrentLesson():uint
		{
			//TODO: Make this work- it don't
			
			for (var i:int = 0; i < userDataArray.length; i++)
			{
				if (userDataArray[i] != "1" )
				{
					//trace(links[i].title + " is the current Lesson id=" + links[i].id);
					return i;
				}
			}
			
			return 0;
		}
		private function allComplete():Boolean
		{
			for (var i:int = 0; i < userDataArray.length; i ++)
			{
				if (userDataArray[i] == "0")
				return false;
			}
			return true;
		}
		private function receivedFromJavaScript(value:String):void
		{
			trace(("JavaScript says: " + value + "\n"));
		}
		
		private function checkJavaScriptReady():Boolean
		{
			var isReady:Boolean = ExternalInterface.call("isReady");
			return isReady;
		}
		
	}
}
