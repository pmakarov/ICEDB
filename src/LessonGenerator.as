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
	import com.Amtrak.ICE.Link;
	import com.Amtrak.ICE.LocalDataManager;
	import com.Amtrak.ICE.MediaLoader;
	import com.Amtrak.ICE.Step;
	import com.Amtrak.ICE.utils.CourseXMLLoader;
	import com.Amtrak.ICE.utils.FlashVarUtil;
	import com.Amtrak.ICE.utils.LessonXMLLoader;
	import com.Amtrak.ICE.utils.VideoXMLLoader;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.greensock.TweenMax;
	import fl.controls.TextArea;
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
	
	
	public class LessonGenerator extends Sprite
	{
		
		protected var stepList:MovieClip;
		protected var lessonXml:LessonXMLLoader;
		protected var courseXml:CourseXMLLoader;
		protected var titleText_mc:TextField;
		
		private var stepNumber:int = 0;
		private var audioStep:int = 0;
		private var steps:Array;
		private var links:Array;
		private var audioSteps:Array;
		private var ml:MediaLoader;
		private var xmlLoader:URLLoader;
		private var sceneXML:VideoXMLLoader;
		private const LEFT:int = 0;
		private const TOP:int = 0;
		
		private var dataPath:String;
		
		private var _playerMode:String;
		private var currentLesson:Link;
		
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
		protected var systemMute:Boolean;
		
		public function LessonGenerator():void
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
			var hasFlashVars:Boolean = FlashVarUtil.setFlashVar(LoaderInfo(this.root.loaderInfo).parameters);
			var obj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			ice = new ICEController(hasFlashVars);
			var e:Event = new Event("we");
			loadModule(e);
			
		}	
		public function onCourseXmlLoad(e:Event):void 
		{
			dataPath = "data/xml/";
			links = courseXml.getNodes();
			ice._playerMode = courseXml.getPlayerMode();
			ice.hosted = courseXml.getHosted();
			ice.branding = "assets/media/" + courseXml.getBranding();
			ice.hostAPI = courseXml.getHostAPI();
			resources = courseXml.getResources();
			
			//If  this commits data either locally or online hosted = true
			if (ice.hostAPI != null && !ice.lmsConnected)
			{
				if (ice.scorm != null)
				{
					
					initializeSCORMTracking();
				}
					
				
				else
				{
					dataManager = LocalDataManager.getInstance();
					if (dataManager.handleUserLogin("amtrakinstructor"))
					{
						var user:Object = dataManager.getUser();						
					}
					else
					{
						var userObject:Object = new Object();
						userObject.uid = "1";
						userObject.name = "amtrak";
						userObject.pass = "instructor";
						userObject.location = 0;
						userObject.currentLocation = "";
						userObject.totalProgress = 0;
						dataManager.call("LOCAL.setContentObjectModel", links);
						dataManager.handleNewUser(userObject);
					}
					
					
					userDataArray = dataManager.call("LOCAL.getProgress", []);
					
				}
			}
			else //Just handle the course/module w/out State preservation
			{
				//TODO create stateless module marshal.
				userDataArray = ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", ];
			}
			
			//initialize main menu
			if (userDataArray == null)
			{
				trace("Terminating Program!");
				return;
			}
			initMainMenu(userDataArray);
			
			
		}	
		
		public function initMainMenu(menu:Array):void 
		{
			steps = new Array();		
			lessonXml = null;
			courseXml= null;
			stepNumber = 0;
			audioStep = 0;
			audioSteps = []
			ml = null;
			xmlLoader = null;
			sceneXML = null;
			//links = new Array();
			
			
			for (var i:int = 0; i < links.length; i++)
			{
				//if user has completed a lesson or if the item is the chronologically first item unlock it
				if (menu[i] == "1" || i == 0)
				{
					links[i].unlocked = true;
					if (i < links.length - 1 && menu[i] == "1")
					{
						links[i + 1].unlocked = true;
					}
				}
			}
			ml = new MediaLoader();
			ml.loadMedia(ice.branding);
			ml.Width = 800;
			ml.Height = 600;
			this.addChild(ml);
			ml.addEventListener("ASSET_LOADED", handleMenuLoaded);
			ml.addEventListener("ASSET_READY", handleMenuReady);
			ml.addEventListener("EVALUATE_ASSET", loadModule);
		}
		public function handleMenuLoaded(e:Event):void
		{
			ml.removeEventListener("ASSET_LOADED", handleMenuLoaded);
			MovieClip(ml.loader.content).init();
		}
		public function handleMenuReady(e:Event):void
		{
			ml.removeEventListener("ASSET_READY", handleMenuReady);
			var arr:Array = MovieClip(ml.loader.content).choiceArray;
			for (var i:int = 0; i < arr.length; i++)
			{
				arr[i].text.text = links[i].title;
				arr[i].setDesc(links[i].desc); 
				if (!links[i].unlocked)
				{
					arr[i].buttonMode = false;
					arr[i].gotoAndStop("_disabled");
					arr[i].mouseEnabled = false;
				}
				arr[i].value = i;
			}
		}
		public function loadModule(e:Event):void
		{			
			if (ice.configData == "data/taxonomy.xml")
			{
				ice.configData = "data/default.xml";
			}
			
			
			/*if (ExternalInterface.available)
			{
				ExternalInterface.call("sendToJavaScript", ice.configData);
			}*/
			lessonXml = new com.Amtrak.ICE.utils.LessonXMLLoader(ice.configData);
			lessonXml.addEventListener(Event.COMPLETE, onXmlLoad);
			
		}
		
		protected function onXmlLoad(e:Event):void
		{
			dataPath = "data/xml/";
			steps = lessonXml.getNodes();
			
			//populate data containers
			buildInterface();
			handleCourse(steps[0]);
		}
		private function buildInterface():void
		{
			switch (ice._playerMode) 
			{
					
				case "PRESENTATION":
					handlePresentationInterface();
					break;
			
				default:
					break;
			}
			
		}
		
		
		private function handlePresentationInterface():void 
		{
			//var vbg:videoControlBG = new videoControlBG();
			
		
			//Use this add a tileable BG
			var vbg:Sprite = new Sprite();
			vbg.graphics.beginBitmapFill(new bobTile(0, 0));
			//vbg.graphics.beginBitmapFill(new tile(0, 0));
			vbg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			vbg.graphics.endFill();
			
			/*	var vbg:AmtrakBG = new AmtrakBG();
			vbg.x = 0;
			vbg.y = 0;
			//var newColorTransform:ColorTransform = new ColorTransform;
			//newColorTransform.color = 0xB9C6D5;
			//newColorTransform.color = 0x222222;
			//vbg.transform.colorTransform = newColorTransform;
			//vbg.setColor(newColorTransform);
			vbg.width = stage.stageWidth;
			vbg.height = stage.stageHeight;*/
			addChild(vbg);
			
			
			
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(800, 800, (Math.PI/180)*90, 0, 0);
			colors=[0x333333,0xCCCCCC];
			alphas=[.7,.7];
			ratios=[0,255];
			var grad:Sprite = new Sprite();
			grad.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			grad.graphics.drawRect(0,0,800,600);
			grad.graphics.endFill();
			addChild(grad);
			
			contBox = new contenbox();
			contBox.x = 35;
			//contBox.x = 0;
			//contBox.y = 17;
			contBox.y = 37;
			contBox.name = "contentBox";
			//contBox.width = stage.stageWidth
			//contBox.height = stage.stageHeight;
			this.addChild(contBox);
			contBox.visible = false;
			//TweenMax.to(contBox, .15, { dropShadowFilter: { color:0x222222, alpha:99, blurX:20, blurY:20, distance:10, quality:3 }} );

			backdrop = new videoControlBG();
			backdrop.x = 40;
			backdrop.y = 92;
			backdrop.name = "backdrop";
			backdrop.width = 721;
			backdrop.height = 405;
			this.addChild(backdrop);

			
			var fl:frontLine = new frontLine();
			fl.x = contBox.x + 5;
			fl.y = contBox.y + 5;
			//addChild(fl);
			
			var op:officePersonnel = new officePersonnel();
			op.x = 35 + contBox.x + contBox.width - (op.width + 8);
			op.y = backdrop.y - (op.height - 3);
			//addChild(op);
			
			xmlLoader = new URLLoader();
			xmlLoader.dataFormat = "e4x";
			xmlLoader.addEventListener(Event.COMPLETE, handleEvalGeneration);
			
			/*var maskCover:Sprite = new Sprite();
			maskCover.graphics.beginFill(0xFFCC00);
			maskCover.graphics.drawRect(ml.x, ml.y, ml.width, ml.height );
			maskCover.graphics.endFill();
			maskCover.x = 40;
			maskCover.y = 92;
			maskCover.width = 721;
			maskCover.height = 405;
			addChild(maskCover);*/
			ml = null;
			ml = new MediaLoader();
			ml.name = "ml";
			ml.x = 40;
			ml.y = 92;
			ml.addEventListener("ASSET_COMPLETE", playNextScene);
			ml.addEventListener("ASSET_LOADED", removeLoadingAnimation);
			ml.Width = 721;
			ml.Height = 405;
			addChild(ml);
			
			
			//ml.mask = maskCover;
			
			TweenMax.to(ml, .15, { dropShadowFilter: { color:0x000000, alpha:99, blurX:30, blurY:30, distance:1, strength:1, quality:3 }} );

			
			//build system Bar
			sB = new glassBar();
			sB.height = 30;
			sB.width = 1024;
			sB.addEventListener(MouseEvent.ROLL_OUT, handleToolBarRollOut);
			sB.addEventListener(MouseEvent.ROLL_OVER, handleToolBarRollOver);
			addChild(sB);
			TweenMax.to(sB, .15, { dropShadowFilter: { color:0x222222, alpha:99, blurX:20, blurY:20, distance:10, quality:3 }} );

			
			var logo:amtrakLogo = new amtrakLogo();
			logo.x = sB.x + 4;
			logo.y = (sB.height - logo.height) / 2;
			//logo.alpha = .5;
			sB.addChild(logo);
			
			var format:TextFormat = new TextFormat();
			format.font = FontManager.ButtonTextFormatWhite.font;
			format.color = 0xFFFFFF;
			format.size = 16;
			format.bold = true;
			
			//showEmbeddedFonts();
			
			titleText_mc = new TextField();
			titleText_mc.autoSize = TextFieldAutoSize.LEFT;
			titleText_mc.background = false; //use true for doing generic labels
			titleText_mc.border = false; // ** same
			titleText_mc.embedFonts = true;
			titleText_mc.antiAliasType = "advanced";
			titleText_mc.gridFitType = GridFitType.PIXEL;
			titleText_mc.sharpness = -200;
			titleText_mc.wordWrap = false;
			titleText_mc.defaultTextFormat = format;
			titleText_mc.x = logo.x + logo.width + 8;
			//titleText_mc.y = 4;
			titleText_mc.y = 10;
			titleText_mc.width = 600;
			titleText_mc.text = lessonXml.getLessonTitle();
			sB.addChild(titleText_mc);
			TweenMax.to(titleText_mc, .2, {glowFilter: {color: 0xDDEEFF, alpha: 1, blurX: 10, blurY: 10, strength: 1, quality: 3}});
			
			cb = new closeButton();
			cb.x = stage.stageWidth - cb.width;
			cb.y = (sB.x + sB.height) / 2 - cb.height / 2 + 3;
			cb.buttonMode = true;
			cb.mouseChildren = false;
			cb.addEventListener(MouseEvent.CLICK, handleClosePlayer);
			sB.addChild(cb);
			
			hb = new helpButton();
			hb.x = cb.x - hb.width;
			hb.y = (sB.x + sB.height) / 2 - hb.height / 2 + 3;
			hb.buttonMode = true;
			hb.mouseChildren = false;
			hb.addEventListener(MouseEvent.CLICK, handleHelpClick);
			sB.addChild(hb);
			
			//build tool Bar
			//var tB:glassBarReg = new glassBarReg();
			tB = new glassBar();
			tB.height = 30;
			tB.width = 1024;
			tB.y = stage.stageHeight - tB.height;
			tB.addEventListener(MouseEvent.ROLL_OUT, handleToolBarRollOut);
			tB.addEventListener(MouseEvent.ROLL_OVER, handleToolBarRollOver);
			addChild(tB);
			
			//tr = new treeButton();
			tr = new amtrakInfoButton();
			tr.x = 0;
			//tr.y = stage.stageHeight - tr.height;
			tr.y = tB.height / 2 - tr.height / 2 + 3;
			tr.buttonMode = true;
			tr.mouseChildren = false;
			tr.addEventListener(MouseEvent.CLICK, toggleMenuTree);
			tB.addChild(tr);
			
			progressBar = new IbaProgressBar();
			progressBar.name = "progressBar";
			progressBar.x = (stage.stageWidth - progressBar.width) / 2;
			progressBar.y = tB.height / 2 - progressBar.height / 2 + 1;
			//progressBar.fuelGauge.progressFill.width = 0;
			progressBar.fuelGauge.visible = false;
			
			
			
			var format2:TextFormat = new TextFormat();
			format2.font = FontManager.ButtonTextFormatWhite.font;
			format2.color = 0xC0C0C0;
			format2.size = 12;
			format2.bold = true;
			
			progressBar.screenCount.defaultTextFormat = format2;
			tB.addChild(progressBar);
			
			//Hmmm.
			progressBar.screenCount.y += 5;
			
			//nextButton = new forwardButton();
			nextButton = new IbaForwardArrow();
			nextButton.name = "nextButton";
			nextButton.x = progressBar.x + progressBar.width + 3;
			//nextButton.y = stage.stageHeight - nextButton.height - (tB.height-nextButton.height)/2;
			nextButton.y = tB.height / 2 - nextButton.height / 2 + 1;
			nextButton.buttonMode = true;
			nextButton.mouseChildren = false;
			nextButton.addEventListener(MouseEvent.CLICK, playNextScene);
			tB.addChild(nextButton);
			
			prevButton = new IbaBackArrow();
			prevButton.name = "previousButton";
			prevButton.x = progressBar.x - prevButton.width - 3;
			//prevButton.y = stage.stageHeight - prevButton.height - (tB.height-prevButton.height)/2;
			prevButton.y = tB.height / 2 - prevButton.height / 2 + 1;
			prevButton.buttonMode = true;
			prevButton.mouseChildren = false;
			prevButton.addEventListener(MouseEvent.CLICK, playPrevScene);
			tB.addChild(prevButton);
			
			
			caption = new globalCaption();
			caption.name = "captionButton";
			caption.x = stage.stageWidth -  caption.width;
			caption.y = tB.height / 2 - caption.height / 2 + 1;
			caption.buttonMode = true;
			caption.mouseChildren = false;
			caption.addEventListener(MouseEvent.CLICK, handleCaptionClick);
			tB.addChild(caption);
			
			
			capBox = new captionBox();
			capBox.x = 35;
			capBox.y = tB.y - 65;
			capBox.width = 731;
			capBox.height = 60;
			capBox.visible = true;
			capBox.tabChildren = true;
			addChild(capBox);
			
			
			/*capText = new TextField();
			capText.autoSize = TextFieldAutoSize.LEFT;
			capText.background = false; //use true for doing generic labels
			capText.border = false; // ** same
			capText.embedFonts = true;
			capText.antiAliasType = "advanced";
			capText.gridFitType = GridFitType.PIXEL;
			capText.sharpness = -200;
			capText.wordWrap = true;
			capText.multiline = true;
			capText.defaultTextFormat = format;
			capText.x = capBox.x
			capText.y = capBox.y;
			capText.width = 600;
			addChild(capText);
			capText.visible = false;*/
			
			//capText.text = "This report serves as the Master Technical Guide for the MYPRIME™ product, the virtual version of ACSAP’s ADAPT curriculum. MYPRIME™ is an interactive, video-based course that promotes changes in attitudes, beliefs, and choices, and provides Soldiers with the ability to";
			
			var myTextFormat:TextFormat = new TextFormat();
			myTextFormat.font = "Arial";
			myTextFormat.color = 0xFFFFFF;
			myTextFormat.size = 18;
			
			capTextBox = new TextArea();
			capTextBox.x = capBox.x;
			capTextBox.y = capBox.y;
			capTextBox.width = 731;
			capTextBox.height = 60;
			capTextBox.setStyle("textFormat", myTextFormat);
			//capTextBox.setStyle("textFormat", FontManager.QuestionTextFormatWhite);
			capTextBox.setStyle("borderStyle", "none");
			//tA.setStyle("focusRectSkin",new Sprite());
			capTextBox.setStyle("upSkin", new Sprite ());
			//var tFF:TextFormat = tA.getStyle("textFormat") as TextFormat;
			//trace(tFF.font + " : is the font");
			capTextBox.text = "Loading captions...";
			capTextBox.visible = true;
			capTextBox.editable = false;
			capTextBox.tabEnabled = true;
			capTextBox.tabIndex = 2;
			addChild(capTextBox);
			
			
			ep = new explorerTab();
			ep.x = 1;
			ep.y = 30;
			ep.visible = false;
			addChild(ep);
			buildExplorerPanel();
			
			
			/*
			 * DEMO HACK 5/8/2012
			 * Turned visibility of next/back buttons to "off"
			 */
			nextButton.visible = false;
			prevButton.visible = false;
			
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandlerfunction);
			
		}
		
		private function buildExplorerPanel():void
		{
			/*var myTree:Tree = new Tree();
			myTree.dataSource = lessonXml.getXML();
			myTree.addEventListener(Event.CHANGE, treeChangeHandler);
			myTree.x = 10;
			//myTree.x = 12;
			myTree.y = 34;
			//myTree.y = 66;
			myTree.name = "tree";
			//addChild(myTree);
			this.ep.addChild(myTree);*/
			buildCourseMap();
			buildResources();
			
		}
		private function buildCourseMap():void 
		{
			var list:TextField = new TextField();
			list.x = 20;
			list.y = 60;
			list.defaultTextFormat = FontManager.choiceTextFormatWhite;
            list.autoSize = TextFieldAutoSize.LEFT;
            list.multiline = true;
			list.name = "courseMap";
			list.htmlText += "<p>"
			for (var i:int = 0; i < 10; i++)
			{
				list.htmlText += "<a href=\"event: \"> Chapter " + (i) +  "</a><br>";
			}
			list.htmlText += "</p>";
			
			 ep.addChild(list);
		}
		private function buildResources():void 
		{
			var list:TextField = new TextField();
			list.x = 20;
			list.y = 310;
			list.defaultTextFormat = FontManager.choiceTextFormatWhite;
            list.autoSize = TextFieldAutoSize.LEFT;
            list.multiline = true;
            list.name = "resourceList";
			for (var i:int = 0; i < 3; i++)
			{
				list.htmlText += "<p><a href=\"event:\">recource " + (i+1) +" </a><br></p>";
			}
			
			 ep.addChild(list);
		}
		  private function opemResource(file:String):void 
		  {
			  
			try 
			{    
               navigateToURL(new URLRequest(file), "_blank");
            }
            catch (err:Error)
			{
                trace(err.message);
            }
            //myMP3.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
        }
        
        private function linkHandler(linkEvent:TextEvent):void 
		{
            opemResource(linkEvent.text);
        }
		private function treeChangeHandler(e:Event):void
		{
			var num:int = e.currentTarget.selectedIndex;
			goToSlide(num);
		
		}
		
		private function handleCourse(s:Step):void
		{
			updateInterface(s);			
			
			switch (s.type)
			{
				case "video": 
					sceneXML = new VideoXMLLoader(dataPath + s.src);
					sceneXML.addEventListener(Event.COMPLETE, handleVideoGeneration);
					break;
				
				case "evaluation": 
					xmlLoader.load(new URLRequest(dataPath + s.src));
					break;
				
				
				
				default:
					ml.loadMedia(s.src);
					break;
			
			}
			
			doLoadAnimation();
		}
		
		
		public function getSelectionIndexByID(num:int):int
		{
			for (var i:int = 0; i < steps.length; i++)
			{
				//trace(steps[i].id)
				if (Number(steps[i].id) == num)
				{
					return i;
				}
			}
			
			return 0;
		}
		/*public function handlePS(e:Event):void 
		{
			trace(e.target.value);
		}*/
		public function doLoadAnimation():void
		{
			
			//TweenMax.to(steps[stepNumber].component, 3, { alpha:1 } );
			clearDisplayList2();
			
			/*if (!this.getChildByName("loadingAnimation"))
			{
				var lod:loadingBlue = new loadingBlue();
				lod.name = "loadingAnimation";
				lod.x = stage.stageWidth / 2;
				lod.y = stage.stageHeight / 2;
				lod.scaleX = lod.scaleY = 5;
				addChild(lod);
			}
			else
			{
				this.getChildByName("loadingAnimation").visible = true;
			}*/
		}
		
		
		
		public function clearDisplayList2():void
		{
			if (stepNumber > 0 && steps[stepNumber].type == "evaluation")
			{
				switch (steps[stepNumber-1].type)
				{
					case "evaluation": 
						return;
						break;
					
					case "video": 
						return;
						break;
					
					default: 
						break;
				}
			
			}
			else
			{
				clearDisplayList();
			}
			
			
			
		}
		
		public function removeVideo():void
		{
			if (stepNumber == 0)
			{
				return;
			}
			if (steps[stepNumber - 1].type == "video")
			{
				ICEVideoPlayer(ml.getChildByName("video")).unload();
				//ml.getChildByName("video").visible = false;
				//ml.removeChild(ml.getChildByName("video"));
				
			}
		}
		
		public function clearDisplayList():void
		{
			trace("Clear node of type: " + steps[stepNumber].type + " before moving on!");
			if (stepNumber > 0)
			{
			switch (steps[stepNumber].type)
			{
				case "evaluation": 
					var eval:MovieClip = ml.getChildByName("evaluation") as MovieClip;
					if (eval && eval.getChildByName("audio"))
					{
						SoundMixer.stopAll();
							//MediaLoader(eval.getChildByName("audio")).channel.stop();
					}
					//ml.removeChild(this.getChildByName("evaluation"));
					if (ml.getChildByName("evaluation"))
					{
						ml.removeChild(ml.getChildByName("evaluation"));
						ml.clearMedia();
					}
					if (stepNumber>0 && steps[stepNumber - 1].type == "video")
					{
						ml.getChildByName("video");
						trace("on an eval but previous was video");
					}
					break;
				
				case "video": 
					if (ml.getChildByName("evaluation"))
					{
						var evalObject:multipleChoiceSingleSelect = ml.getChildByName("evaluation") as multipleChoiceSingleSelect;
						evalObject.stop();
						evalObject.removeEventListener(ComponentDataRequestEvent.REQUEST_TYPE, handleGetComponentDataById);
						evalObject.removeEventListener("ASSET_LOADED", handleAssetLoaded);
						evalObject.removeEventListener("ASSET_COMPLETE", doAssetComplete);
						evalObject.removeEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
						//ml.removeChild(evalObject);
					}
					
					
					if (ICEVideoPlayer(ml.getChildByName("video"))!=null)
					{
						ICEVideoPlayer(ml.getChildByName("video")).unload();
						ml.removeChild(ml.getChildByName("video"));
					}
					
					
					if (stepNumber>0 && steps[stepNumber - 1].type == "evaluation")
					{
						
						var evalz:MovieClip = ml.getChildByName("evaluation") as MovieClip
						TweenMax.to(evalz, 2, { alpha:0, onComplete: removeEvalByFade } );				
					}
					if (stepNumber>0 && steps[stepNumber - 1].type == "video")
					{
						ml.getChildByName("video");
						
					}
					ml.clearMedia();
					
					break;
				
				default: 
					var tmp:MediaLoader = this.getChildByName("ml") as MediaLoader;
					tmp.clearMedia();
					break;
			}
			}
			
			if (this.getChildByName("blocker"))
			{
				unblockInterface();
			}
			
			if (this.getChildByName("feedback"))
			{
				this.removeChild(this.getChildByName("feedback"));
			}
			
			//steps[stepNumber].component = null;
		}
		
		private function removeEvalByFade():void
		{
			var evalObject:multipleChoiceSingleSelect = ml.getChildByName("evaluation") as multipleChoiceSingleSelect;
			evalObject.stop();
			evalObject.removeEventListener(ComponentDataRequestEvent.REQUEST_TYPE, handleGetComponentDataById);
			evalObject.removeEventListener("ASSET_LOADED", handleAssetLoaded);
			evalObject.removeEventListener("ASSET_COMPLETE", doAssetComplete);
			evalObject.removeEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
			ml.removeChild(evalObject);
		}
		
		private function updateInterface(s:Step):void
		{
			
				
					if (stepNumber < 1)
					{
						prevButton.enabled = false;
						prevButton.gotoAndStop(1);
						prevButton.alpha = .3;
					}
					else if (stepNumber == steps.length - 1)
					{
						nextButton.enabled = false;
						nextButton.gotoAndStop(1);
						nextButton.alpha = .3;
					}
					else if (stepNumber > 0 && stepNumber < steps.length - 1)
					{
						prevButton.enabled = nextButton.enabled = true;
						prevButton.alpha = nextButton.alpha = 1;
					}
					stage.focus = stage;
					//trace(stage.focus);
					/*if (ep!=null && ep.getChildByName("tree"))
					{
						Tree(ep.getChildByName("tree")).selectNodeByIndex(stepNumber);
					}
					*/
					
					
					
					progressBar.screenCount.text = "Screen : " + String(stepNumber + 1) + " / " + String(steps.length);
					progressBar.fuelGauge.progressFill.width = progressBar.fuelGauge.width * ((stepNumber + 1) / steps.length);
					
			
		}
		
		private function handleGetComponentDataById(e:ComponentDataRequestEvent):void
		{
			var tmp:Array = new Array();
			tmp = e.componentID.split(";");
			trace(tmp);
			
			var requestedComponentData:Array = new Array();
			
			for (var j:uint = 0; j < tmp.length; j++)
			{
				requestedComponentData = requestedComponentData.concat(getComponentDataById(tmp[j]));
			}
			steps[stepNumber].component.assignDataDependencyValues(requestedComponentData);
		
		}
		
		private function getComponentDataById(compID:String):Array
		{
			var requestedComponentData:Array = new Array();
			for (var i:uint = 0; i < steps.length; i++)
			{
				if (compID == steps[i].id)
				{
					requestedComponentData = steps[i].component.evalData;
					return requestedComponentData;
				}
			}
			return null;
		}
		
		private function updateEvalData(e:Event):void
		{
			//trace(typeof(steps[stepNumber].component.evalData));
			//trace(steps[stepNumber].component.evalData.answerID + " : " + steps[stepNumber].component.evalData.answerData);
			if (steps[stepNumber].component.evalData)
			{
				
				for (var i:*in steps[stepNumber].component.evalData)
				{
					//trace("User: pmakarov\nQuestion ID: " + steps[stepNumber].id + "\nAnswer ID: " + steps[stepNumber].component.evalData[i].id + "\nanswerText : " + steps[stepNumber].component.evalData[i].Data+"\nTime: " +  TimeStamp.NewTimeStamp.toLocaleString()  );
					//trace(steps[stepNumber].component.evalData[i].Data);
					trace(steps[stepNumber].component.evalData[i].answerID + " : " + steps[stepNumber].component.evalData[i].answerData);
				}
			}
		}
		
		/*private function handleBranch(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var element:XML = new XML(loader.data);
			var elementType:String = element.@type.toString();
			//var ml:MediaLoader = new MediaLoader();
			ml.loadMedia(element..file.@src.toString());
			//ml.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, multimediaLoaded);
			ml.addEventListener("ASSET_COMPLETE", doAssetComplete);
			ml.addEventListener("Blah", tryThis);
			ml.name = "evaluation";
			addChild(ml);
			ml.x = LEFT;
			ml.y = TOP;
			steps[stepNumber].component = ml;
		
		}*/
		
		/*private function tryThis(e:Event):void
		{
			trace("try it");
		}*/
		
		/*private function handleScreen(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var evaluation:XML = new XML(loader.data);
			var elementType:String = evaluation.@type.toString();
			ml.loadMedia(evaluation..multimedia.@src.toString());
			steps[stepNumber].component = ml;
		
		}*/
		
		private function handleEvalGeneration(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var evaluation:XML = new XML(loader.data);
			var evalType:String = evaluation.@evalType.toString();
			
			var evalGenerator:EvaluationGenerator = EvaluationGenerator.getInstance();
			
			var evalObject:Evaluation;
			evalObject = evalGenerator.makeEvalFromXML(evaluation);
			
			
			evalObject.addEventListener(ComponentDataRequestEvent.REQUEST_TYPE, handleGetComponentDataById);
			evalObject.addEventListener("ASSET_LOADED", handleAssetLoaded);
			evalObject.addEventListener("ASSET_COMPLETE", doAssetComplete);
			evalObject.addEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
			evalObject.name = "evaluation";
			ml.addChild(evalObject);
			steps[stepNumber].component = evalObject;
			evalObject.initContent();
			evalObject.alpha = 0;
			
			
			//TweenMax.to(evalObject, 3, { alpha:.5, onComplete: doLoadAnimation } );
			
			if (evalObject.instructionText != "")
			{
				capTextBox.text = evalObject.instructionText;
				capTextBox.verticalScrollPosition = 0;
			}
		
		}
		
		private function handleVideoGeneration(e:Event):void
		{
				var videoPlayBack:ICEVideoPlayer;
			
			videoPlayBack = new ICEVideoPlayer(sceneXML);
			videoPlayBack.addEventListener("ASSET_LOADED", removeLoadingAnimation)
			videoPlayBack.addEventListener("ASSET_COMPLETE", doAssetComplete);
			videoPlayBack.addEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
			videoPlayBack.addEventListener(ICETimedTextEvent.CAPTION_UPDATED, updateCaptionDisplay2);
			videoPlayBack.addEventListener("MUTE", setSystemMute);
			videoPlayBack.addEventListener("UNMUTE", setSystemUnMute);

			videoPlayBack.name = "video"; 
			videoPlayBack.addEventListener(Event.REMOVED_FROM_STAGE, deactivate); 
			
			ml.addChild(videoPlayBack);
			
			
			steps[stepNumber].component = videoPlayBack;
			if (videoPlayBack.caption != "")
			{
				capTextBox.text = videoPlayBack.caption;
				capTextBox.verticalScrollPosition = 0;
				
			}
			else if (videoPlayBack.captionURL != "")
			{
				doLoadCaption(videoPlayBack.captionURL);
			}
			
			if (systemMute)
			{
				//videoPlayBack.setMute(true);
			}
		}
		
		public function setSystemMute(e:Event):void
		{
			systemMute = true;
			
		}
		public function setSystemUnMute(e:Event):void
		{
			systemMute = false;
		}
		
		public function deactivate(e:Event):void
		{
			trace("deactivating a video");
				e.currentTarget.removeEventListener("ASSET_LOADED", removeLoadingAnimation)
				e.currentTarget.removeEventListener("ASSET_COMPLETE", doAssetComplete);
				e.currentTarget.removeEventListener(FeedbackEvent.EVALUATION_TYPE, displayFeedback);
				e.currentTarget.deactivate(e);
		}
			public function doLoadCaption(src:String):void
		{
			ICEVideoPlayer(ml.getChildByName("video")).loadCaption(src);
			/*var txtLoad:URLLoader = new URLLoader(new URLRequest(src));
			txtLoad.addEventListener(Event.COMPLETE, updateCaptionDisplay);*/
		}
		public function doLoadCaption2(src:String):void
		{
			ICEVideoPlayer(ml.getChildByName("feedbackVideo")).loadCaption(src);
			/*var txtLoad:URLLoader = new URLLoader(new URLRequest(src));
			txtLoad.addEventListener(Event.COMPLETE, updateCaptionDisplay);*/
		}
		public function updateCaptionDisplay2(e:Event):void 
		{
			capTextBox.text = e.target.tf.text;
			
		}
		public function updateCaptionDisplay(e:Event):void 
		{
			/*capTextBox.text = e.target.data;
			capTextBox.verticalScrollPosition = 0;*/
		}
		public function removeLoadingAnimation(e:Event):void
		{
			//this.getChildByName("loadingAnimation").visible = false;
		}
		public function handleAssetLoaded(e:Event):void
		{
			//var obj:Object = new Object();
			//obj.transitionItem = e.target as MovieClip;
			//obj.transition = removeVideo;
			//TransitionManager.transitionIn(obj);
			TweenMax.to(steps[stepNumber].component, 1, { alpha:1, onComplete: removeVideo } );
		}
		
		private function playNextScene(e:Event):void
		{
			if (stepNumber < steps.length - 1)
			{
				//clearDisplayList();
				stepNumber++;
				handleCourse(steps[stepNumber]);
			}
			else
			{
				dispatchEvent(new Event("END_OF_MODULE"));
				/*stepNumber = steps.length - 1;
					//trace("End of Lesson");
				blockInterface();
				var sM:systemMessage = new systemMessage();
				sM.x = stage.stageWidth / 2 - sM.width / 2;
				sM.y = stage.stageHeight / 2 - sM.height / 2;
				addChild(sM);
				
				sM.cont.buttonMode = true;
				sM.cont.mouseChildren = false;
				sM.cont.addEventListener(MouseEvent.CLICK, handleContinueClick);
				
				sM.ex.buttonMode = true;
				sM.ex.mouseChildren = false;
				sM.ex.addEventListener(MouseEvent.CLICK, handleExitClick);*/
				
					//nextButton.enabled = false;
			}
		}
		
		protected function playPrevScene(e:Event):void
		{
			
			if (stepNumber > 0)
			{
				clearDisplayList();
				stepNumber--;
				handleCourse(steps[stepNumber]);
			}
			else
			{
				stepNumber = 0;
					//trace("Beginning of Lesson");
					//prevButton.enabled = false;
			}
		}
		
		public function goToSlide(num:int):void
		{
			if (num == stepNumber)
				return;
			
			if (num < steps.length)
			{
				clearDisplayList();
				stepNumber = num;
				handleCourse(steps[stepNumber]);
			}
		}
		
		private function blockInterface():void
		{
			//blocker.width = 768;
			blocker.width = stage.stageWidth;
			//blocker.height = 432;
			blocker.height = stage.stageHeight;
			blocker.x = LEFT;
			blocker.y = TOP;
			blocker.alpha = 0;
			blocker.name = "blocker";
			TweenPlugin.activate([TintPlugin]);
			TweenMax.to(blocker, 0, {tint: 0x000000});
			
			TweenMax.to(blocker, .75, {alpha: .5, onReverseComplete: removeBlocker});
			this.addChild(blocker);
		}
		
		private function removeBlocker():void
		{
			this.removeChild(this.getChildByName("blocker"));
		}
		
		
		private function displayVideoFeedback(e:FeedbackEvent):void 
		{
			trace(e.text);
		}
		private function unblockInterface():void
		{
			blocker.filters = null;
			TweenMax.to(blocker, .5, {alpha: 0});
			this.removeChild(this.getChildByName("blocker"));
		}
		private function displayFeedback(e:FeedbackEvent):void
		{
			//blockInterface();
			//Build Feedback 
			//trace(e.windowType + " : " + e.value + " : " + e.text);
			//trace(stepNumber + " : " + steps[stepNumber].component.name);
			steps[stepNumber].component.stop();
			SoundMixer.stopAll();
			
			if (e.windowType == "SUM")
			{
				if (e.value != "v1")
				{
					for (var i:int = 0; i < steps[stepNumber].component.feedbackList.length; i++)
					{
						if(steps[stepNumber].component.feedbackList[i].value == e.value)
						{	
							steps[stepNumber].component.feedbackList[i].selected = true;
						}
					}
					sceneXML = new VideoXMLLoader(dataPath + e.video);
					sceneXML.addEventListener(Event.COMPLETE, handleFeedbackVideo);
				}
				else
				{
					var audioQueue:Array = new Array();
					
					for (var j:int = 0; j < steps[stepNumber].component.feedbackList.length; j++)
					{
						var correctAudioFeedback:Object = new Object();
						if (!steps[stepNumber].component.feedbackList[j].selected)
						{
							correctAudioFeedback.audio = steps[stepNumber].component.feedbackList[j].audio;
							correctAudioFeedback.value = steps[stepNumber].component.feedbackList[j].value;
							correctAudioFeedback.text = steps[stepNumber].component.feedbackList[j].text;
							audioQueue.push(correctAudioFeedback);
						}
					}
					audioSteps = audioQueue;
					handleCorrectFeedbackAudio(audioQueue);
					ml.addEventListener("SOUND_COMPLETE", incrementAudioCounter);
					this.addEventListener("AUDIO_FEEDBACK_COMPLETE", doAssetComplete);
				}
			}
			
		}
		public function handleCorrectFeedbackAudio(arr:Array):void
		{
			//trace(audioStep + " : " + audioSteps.length);
			//trace(arr[audioStep].audio + " : " + arr[audioStep].value);
			//trace(steps[stepNumber].component.remainingAttempts + " : is teh");
			if (arr[audioStep].value == "v1" && steps[stepNumber].component.remainingAttempts <= 1 )
			{
				var e:Event;
				audioStep = audioSteps.length - 1;
				goNextSlide(e);
			}
			else
			{
				ml.loadMedia(arr[audioStep].audio);
				capTextBox.text = arr[audioStep].text;
				capTextBox.verticalScrollPosition = 0;
				steps[stepNumber].component.handleCustomHighlightState(arr[audioStep].value);
			}
		}
		public function incrementAudioCounter(e:Event):void
		{
			//trace("stepping audio");
			audioStep++;
			if (audioStep < audioSteps.length)
			{
				trace(audioStep + " : " + audioSteps.length);
				handleCorrectFeedbackAudio(audioSteps);
			}
			else
			{
				audioStep = 0;
				ml.removeEventListener("SOUND_COMPLETE", incrementAudioCounter);
				dispatchEvent(new Event("AUDIO_FEEDBACK_COMPLETE"));
			}
		}
		public function handleFeedbackVideo(e:Event):void
		{
			var videoPlayBack:ICEVideoPlayer = new ICEVideoPlayer(sceneXML);
			videoPlayBack.addEventListener("ASSET_COMPLETE", doVideoFeedbackComplete);
			videoPlayBack.addEventListener(ICETimedTextEvent.CAPTION_UPDATED, updateCaptionDisplay2);
			videoPlayBack.name = "feedbackVideo";

			ml.addChild(videoPlayBack);
		    if (videoPlayBack.caption != "")
			{
				capTextBox.text = videoPlayBack.caption;
				capTextBox.verticalScrollPosition = 0;
			
			}
			else if (videoPlayBack.captionURL != "")
			{
				doLoadCaption2(videoPlayBack.captionURL);
			}
		}
		public function doVideoFeedbackComplete(e:Event):void
		{
			ml.getChildByName("feedbackVideo").visible = false;
			ICEVideoPlayer(ml.getChildByName("feedbackVideo")).unload();
			ml.removeChild(ml.getChildByName("feedbackVideo"));
			steps[stepNumber].component.handleCustomFeedbackState();
			if (steps[stepNumber].component.instructionText != "")
			{
				capTextBox.text = steps[stepNumber].component.instructionText;
				capTextBox.verticalScrollPosition = 0;
			}
		}
		public function doAssetComplete(e:Event):void
		{
			goNextSlide(e);
		}
		
		public function doFeedbackNext(e:MouseEvent):void
		{
			updateEvalData(e);
			var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
			for (var i:int = feedback.numChildren - 1; i >= 0; i--)
			{
				var mc:DisplayObject = DisplayObject(feedback.getChildAt(i));
				if (i < 1)
				{
					TweenMax.to(mc, .75, {delay: .6, alpha: 0, onComplete: goNextSlide, onCompleteParams: [e]});
				}
				else
				{
					
					TweenMax.to(mc, .75, {alpha: 0});
				}
			}
		
		}
		
		public function goNextSlide(e:Event):void
		{
			//* if we had a legit transition manager it would call transitions on comp way in and way out
			// steps[stepNumber].component.doTransitionIN/OUT;
			
			playNextScene(e);
			
		}
		
	    public function closeFeedback():void
		{
			var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
			for (var i:int = feedback.numChildren - 1; i >= 0; i--)
			{
				var mc:DisplayObject = DisplayObject(feedback.getChildAt(i));
				if (i < 1)
				{
					TweenMax.to(mc, .25, {delay: .2, alpha: 0, onComplete: feedBackRemoved, onCompleteParams: [feedback]});
				}
				else
				{
					
					TweenMax.to(mc, .25, {delay: .1, alpha: 0});
				}
			}
		}
		
		public function doCloseFeedback(e:MouseEvent):void
		{
			closeFeedback();
		
		}
		
		public function feedBackRemoved(feedback:MovieClip):void
		{
			unblockInterface();
			
			if (this.getChildByName("feedback"))
			{
				var feedback:MovieClip = this.getChildByName("feedback") as MovieClip;
				this.removeChild(feedback);
			}
			
			if (this.getChildByName("evaluation"))
			{
				var evaluation:MovieClip = this.getChildByName("evaluation") as MovieClip;
				evaluation.filters = null;
			}
		}
		
		
		
		public function toggleMenuTree(e:MouseEvent):void
		{
			if (ep.visible)
			{
				ep.visible = false;
			}
			else
			{
				ep.visible = true;
			}
		
		}
		public function handleCaptionClick(e:MouseEvent):void
		{
			/*if (capBox.height == 0)
			{
				TweenMax.to(capBox, 1, { y: capBox.y-80, height:100 } );
				
			}
			else
			{
				TweenMax.to(capBox, 1, { y:capBox.y + 80, height:0 } );
			}*/
			
			if (capBox.visible == false)
			{
				capBox.visible = true;
				//capText.visible = true;
				capTextBox.visible = true;
				//caption.y = caption.y - 75 - caption.height;
			}
			else
			{
				capBox.visible = false;
				//capText.visible = false;
				capTextBox.visible = false;
				//caption.y = caption.y + 75 + caption.height;
			}
		}
		
		public function doExpandMenuTree():void
		{
		
		}
		
		/*public function toggleFullScreen(e:MouseEvent):void
		{
			if (_fullScreen)
			{
				ml.x = LEFT + 2;
				ml.y = TOP + 32;
				ml.Width = 1018;
				ml.Height = 705;
				ml.scaleX -= .0050;
				ml.scaleY -= .09;
				
				backdrop.x = 2;
				backdrop.y = 32;
				backdrop.width = 1020;
				backdrop.height = 705;
				//backdrop.scaleX -= .0050;
				 //backdrop.scaleY -= .09;
				
				_fullScreen = false;
				sB.alpha = 1;
				tB.alpha = 1;
					//ep.x = 1;
			}
			else
			{
				ml.x = 0;
				ml.y = 0;
				ml.Width = stage.stageWidth;
				ml.Height = stage.stageHeight;
				ml.scaleX += .0050;
				ml.scaleY += .09;
				
				backdrop.x = 0;
				backdrop.y = 0;
				backdrop.width = stage.stageWidth;
				backdrop.height = stage.stageHeight;
				//backdrop.scaleX += .0050;
				//backdrop.scaleY += .09;
				
				_fullScreen = true;
				sB.alpha = 0;
				tB.alpha = 0;
				//ep.x -= ep.width - 20;
				
			}
		
		}*/
		
		public function handleToolBarRollOver(e:MouseEvent):void
		{
			if (_fullScreen)
			{
				e.target.alpha = 1;
			}
		}
		
		public function handleToolBarRollOut(e:MouseEvent):void
		{
			if (_fullScreen)
			{
				e.target.alpha = 0;
			}
		}
		
		public function handleClosePlayer(e:MouseEvent):void
		{
			if (ml.getChildByName("video"))
			{
				var ivp:ICEVideoPlayer = ml.getChildByName("video") as ICEVideoPlayer;
				ivp.pause();
			}
			blockInterface();
			var sE:systemExit = new systemExit();
			sE.x = stage.stageWidth / 2 - sE.width / 2;
			sE.y = stage.stageHeight / 2 - sE.height / 2;
			addChild(sE);
			
			sE.ok.buttonMode = true;
			sE.ok.mouseChildren = false;
			sE.ok.addEventListener(MouseEvent.CLICK, closePlayer);
			
			sE.cancel.buttonMode = true;
			sE.cancel.mouseChildren = false;
			sE.cancel.addEventListener(MouseEvent.CLICK, function (e:Event):void 
			{
				removeChild(sE);
				unblockInterface();
				if (ivp)
				{
					ivp.play();
				}
			});
			
		
		}
		public function closePlayer(e:Event):void
		{
			
			//init();
			if (ExternalInterface.available)
			{
				ExternalInterface.call("closeApplication", "close the application");
			}
			else
			{
				var url:URLRequest = new URLRequest("javascript:window.close()"); 
				navigateToURL(url, "_self"); 	
			}
		}
		public function handleContinueClick(e:MouseEvent):void
		{
			trace("get Next Lesson");
			
			clearDisplayList();
			
			stepNumber = 0;
			
			var index:uint = parseInt(currentLesson.id);
			
			if (index < links.length)
			{
			trace("index : " + index);
			currentLesson = links[index];
			//trace(currentLesson.id + " : " + currentLesson.title);
			lessonXml = new com.Amtrak.ICE.utils.LessonXMLLoader("data/" + links[index].src);
			lessonXml.addEventListener(Event.COMPLETE, onXmlLoad);
			}
			else
			{
				trace("return to main menu");
				//init();
				initMainMenu(userDataArray);
			}
		}
		public function handleExitClick(e:MouseEvent):void 
		{
			trace("return to main menu");
			clearDisplayList();
			
			stepNumber = 0;
			
			//init();
			initMainMenu(userDataArray);
		}
		public function handleHelpClick(e:MouseEvent):void
		{
			if (ml.getChildByName("video"))
			{
				var ivp:ICEVideoPlayer = ml.getChildByName("video") as ICEVideoPlayer;
				ivp.pause();
				blockInterface();
			}
			var hs:helpScreen = new helpScreen();
			hs.x = (800 - hs.width) / 2;
			hs.y = (this.height - hs.height) / 2
			hs.name = "helpScreen";
			hs.close.buttonMode = true;
			hs.close.mouseChildren = false;
			hs.close.addEventListener(MouseEvent.CLICK, handleHelpCloseClick);
			hs.helpText.embedFonts = false;
			hs.helpText.htmlText = "ICE Media Player v. 1.0\n";
			hs.helpText.htmlText+=("May 2012<br><br>");
			hs.helpText.htmlText+= 'To report a technical problem, please contact Paul Makarov: <a href="mailto:keith.bridges@windwalker.com?cc=paul.makarov@windwalker.com&subject=Amtrak%20Feedback%20from%20ICE%20Player%20v1.0&body=Your%20comments%20go%20here...">paul.makarov@windwalker.com';
			hs.helpText.appendText("\n\nWe appreciate your feedback!");
			
			addChild(hs);
		}
		public function handleHelpCloseClick(e:MouseEvent):void
		{
			
			var h:helpScreen = this.getChildByName("helpScreen") as helpScreen;
			if (h)
			{
				
				h.close.removeEventListener(MouseEvent.CLICK, handleHelpCloseClick);
				this.removeChild(h);
				if (ml.getChildByName("video"))
				{
					var ivp:ICEVideoPlayer = ml.getChildByName("video") as ICEVideoPlayer;
					unblockInterface();
					ivp.play();
				}
				
				
			}
		}
		
		public function handleEndOfModule(e:Event):void
		{
			stepNumber = steps.length - 1;
				//trace("End of Lesson");
			blockInterface();
			var sM:systemMessage = new systemMessage();
			sM.x = stage.stageWidth / 2 - sM.width / 2;
			sM.y = stage.stageHeight / 2 - sM.height / 2;
			
			
			sM.cont.buttonMode = true;
			sM.cont.mouseChildren = false;
			sM.cont.addEventListener(MouseEvent.CLICK, handleContinueClick);
			
			sM.ex.buttonMode = true;
			sM.ex.mouseChildren = false;
			sM.ex.addEventListener(MouseEvent.CLICK, handleExitClick);
			if (links[0].id == currentLesson.id)
			{
				//Hide the exit; Center the continue button. 
				sM.dialogText.text = "You have reached the end of the current lesson.  Select \"Continue\" to proceed to the next lesson.";
				sM.cont.x = sM.width / 2 - sM.cont.width / 2;
				sM.ex.visible = false;
				sM.cont.visible = true;
				
			}
			else if (links[links.length - 1].id == currentLesson.id)
			{
				sM.dialogText.text = "You have reached the end of the course.  Select \"Exit\" to return to the main menu.";
				sM.ex.x = sM.width / 2 - sM.ex.width / 2;
				sM.cont.visible = false;
				sM.ex.visible = true;
			}
			addChild(sM);
			globalRecordLessonComplete();		
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
			if (ice.scorm != null)
			{
				saveCourseStatus(userDataArray);
			}
			else
			{
				var tmp:Array = new Array();
				tmp.push(index);
				dataManager.call("LOCAL.recordLessonComplete", tmp);
			}
			
			var finalLesson:Boolean = (index == links.length  || allComplete()) ? true : false;
			
			if (finalLesson == true)
			{
				globalRecordEndOfSCO();
				
			}
			
			
		}
		public function globalRecordEndOfSCO():void
		{
			if (ice.scorm != null)
			{
				trace("globalRecordEndOfSco called");
				setCourseToComplete();

			}
			if (ExternalInterface.available)
			{
				ExternalInterface.call("finishSCO", "ohYeahWeDone");
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
				//trace(links[i].id);
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
		
		private function timerHandler(event:TimerEvent):void
		{
			trace("Checking JavaScript status...\n");
			var isReady:Boolean = checkJavaScriptReady();
			if (isReady)
			{
				trace("JavaScript is ready.\n");
				Timer(event.target).stop();
			}
		}
		
		private function keyHandlerfunction(e:KeyboardEvent):void
		{
			//trace("keyHandlerfunction: " + e.keyCode);
			var code:String = e.keyCode.toString();
			
			switch (code)
			{
				case "34": 
				case "39": 
					playNextScene(e);
					break;
				
				case "33": 
				case "37": 
					playPrevScene(e);
					break;
				
				default: 
					break;
			}
		
		}
		/* =================================================================================

			SCORM code below!

		   ============================================================================== */
		/*
			setCourseToComplete

			Accepts: None
			Returns: None

			When the course is completed, we need to perform several tasks:
			  1. Send completion notice to LMS
			  2. Save progress
			  3. Disconnect from LMS (in some courses this may cause the course window to close)
		*/
		public function setCourseToComplete():void 
		{

			//AMTRAK Rule:
			ice.scorm.set("cmi.core.score.raw" , "100");
			
			//Set lesson status to completed
			ice.success = ice.scorm.set("cmi.core.lesson_status", "completed");

			//Ensure the LMS persists (saves) what was just sent
			ice.scorm.save();

			//Disconnect from LMS
			ice.scorm.disconnect();

		}
		
		/*
			saveCourseStatus

			Accepts: None
			Returns: None

			SCORM doesn't provide a clearly-defined place to save progress data. For example, if
			you have a 10-page course, and want to keep track of which pages have been viewed, there's
			no pre-existing SCORM field for pageviews. So we improvise: cmi.suspend_data is a blank
			field we can use to hold whatever data we like. We just have to follow a few rules:

			 1. It has to be a single string (much like a JavaScript browser cookie)
			 2. It can only go up to about 4000 characters in SCORM 1.2 or 64,000 characters in SCORM 2004
			 3. It won't be permanently stored in the LMS until we commit (use ICE' "save" command)

		*/
		public function saveCourseStatus(arr:Array):void 
		{

			//Create a string to store in suspend_data. In this case, we're using a comma-delimited string
			//because it can easily be extracted via string.split() later on. There are a gazillion ways to
			//do this, including JSON, but this is just a simple, somewhat contrived example.
			//var suspend_str:String = visited.Mercury + "," + visited.Venus + "," + visited.Earth + "," + visited.Mars;
			trace("saving this scorm data: " + arr);
			
			
			
			var suspend_str:String = "";

			for (var i:int = 0; i < arr.length; i++)
			{
				suspend_str += arr[i] + ",";
			}
			
			//trace("inside saveCourseStatusSCORM " + suspend_str);
			//Send suspend_data string to LMS
			ice.scorm.set("cmi.suspend_data", suspend_str);

			//Ensure the LMS persists (saves) what was just sent
			ice.scorm.save();
			
		}

		
		/*
			initializeTracking

			Accepts: None
			Returns: None


			This function starts the SCORM session and performs some preliminary checks.

		*/
		public function initializeSCORMTracking():void 
		{


			//Connect to LMS. Can only be done ONCE.
			ice.lmsConnected = ice.scorm.connect();
			
			//Ensure connection was successful before continuing.
			if (ice.lmsConnected)
			{

				//Get course status
				ice.lessonStatus = ice.scorm.get("cmi.core.lesson_status");

				//If course has already been completed, kill connection
				//to LMS because there's nothing to report.
				if (ice.lessonStatus == "completed" || ice.lessonStatus == "passed")
				{

					ice.scorm.disconnect();

				} else 
				{

					//If course has NOT been completed yet, let's
					//ensure the LMS knows the course is incomplete
					//by explicitly setting status to "incomplete"
					ice.success = ice.scorm.set("cmi.core.lesson_status", "incomplete");

					//Perform a save whenever sending vital data to LMS
					//but be careful not to do it too often or risk bogging down the LMS
					ice.scorm.save();

					//Extract our custom course progress data from suspend_data, if available.
					var suspend_data:String = ice.scorm.get("cmi.suspend_data");
					//suspend_data = "1,1,1,1,1,1,1,1,1,1";
					//Is suspend_data empty? Check the length of the returned string.
					//If there's nothing saved, the LMS will return an empty string ""
					if (suspend_data.length > 0)
					{

						//suspend_data is not empty, so we must have
						//saved something in the last course attempt.
						//Remember, we saved a our progress variables in
						//a comma-delimited string; we can convert to an
						//array using string.split(",").
						userDataArray = suspend_data.split(",");

						//Assign the value to each of our planets.
						//Be sure to convert string "1" to integer 1.
						//The order of the array items was specified in
						//saveCourseStatus() when we created the
						//comma-delimited suspend_data string.
						/*visited.Mercury = parseInt(arr[0],10);
						visited.Venus = parseInt(arr[1],10);
						visited.Earth = parseInt(arr[2],10);
						visited.Mars = parseInt(arr[3],10);*/

					}
					else {
						trace("user data does not exist");
						userDataArray = [ "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"];
					}

				}

			} 
			else 
			{

				//Ruh-roh...
				trace("Could not connect to LMS.");
				//userDataArray = [ "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"];
			}

		}
	
	}

}
