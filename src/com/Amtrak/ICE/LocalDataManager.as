package com.Amtrak.ICE
{
	import com.Amtrak.ICE.utils.TimeStamp;	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.setTimeout;
	
	import mx.formatters.DateFormatter;
    
    public class LocalDataManager extends EventDispatcher
	{
        
        private var userSo:SharedObject;
		private var menuXmlLoader:URLLoader;
        private static var instance:LocalDataManager;
		private static var allowInstantiation:Boolean;
		private var lessonArray:Array;
		private var componentList:Array;
		private var glossary:Array;
		private var review:Array;
		private var notes:Array;
		private var reflections:Array;
		private var puzzle:Array;
		private var user:amtrakUser;
		private var courseDataLoaded:Boolean;
		private var textLoader:URLLoader;
		private var course:XML;
		private var cOM:Array;

		public function LocalDataManager():void
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use LocalDataManager.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():LocalDataManager 
		{
			if (instance == null) 
			{
				allowInstantiation = true;
				instance = new LocalDataManager();
				allowInstantiation = false;
			}
         return instance;
		}
		
		public function call(service:String, params:Array=null):Object
		{
				
				switch(service)
				{
					
					case "EvalObject.submitData":
						var submitted:Boolean = setComponentDataById(params);
						commitDataToSharedObject();
						return submitted;
					break;
					
					case "EvalObject.getData":
						return getComponentDataById(params[1]);
					break;
					
					case "LOCAL.setContentObjectModel":
						lessonArray = params;
						return lessonArray;
						break;
					
					case "LOCAL.recordLessonComplete":
						trace("RECORD LESSON COMPLETE: " + params[0]);
						return recordLessonComplete(params[0]);
					break;	
					
					case "LOCAL.getProgress":
						var count:uint = 0;
						var progress:Array = new Array();
						for (var c:uint = 0; c < lessonArray.length; c++)
						{
							if (lessonArray[c].complete)
							{
								count++;
								progress.push("1");
							}
							else
							{
								progress.push("0");
							}
						}
						return progress;
					break;
						
					case "ePRIME.init":
					var outer:Array = new Array();
					outer[0] = new Array();
					outer[0]["uid"] = getUserId();
					outer[0]["currentinstructor"] = "49";
					if (params.length == 1)
					{
						outer[0]["scenexmlurl"] = lessonArray[user.lesson].xml;
						outer[0]["lastsavepoint"] = user.currentLocation;
						outer[0]["complete"] = lessonArray[user.lesson].complete;
					}
					else 
					{
						outer[0]["scenexmlurl"] = getLessonXmlBySceneId(params[1]);
						outer[0]["lastsavepoint"] = getSavePointBySceneId(params[1]);
						outer[0]["complete"] = getLessonStatusBySceneId(params[1]);
						user.lesson = getLessonIndexBySceneId(params[1]);
						user.currentLocation = "";
					}
					commitDataToSharedObject();
					return outer;
					break;
					
					case "ePRIME.setLastSavePoint":			
					trace("Set Last Save Point " + params[2]);
					user.currentLocation = params[2];
					commitDataToSharedObject();
					return true;
					break;
					
					case "ePRIME.recordCompletedScene":
					trace("RECORD SCENE COMPLETE: " + params[1]);
					return recordSceneComplete(params[1]);
					break;
					
					case "ePRIME.recordCompletedLesson":
					trace("RECORD LESSON COMPLETE: " + params[1]);
					//var index:uint = getLessonIndexBySceneId(params[1]);
					//trace(index);
					return recordLessonComplete(params[1]);
					/*lessonArray[index].complete = true;
					trace("FOO FOO " + lessonArray[index].lessonId);
					return lessonArray[index].complete;*/
					break;
					
					case "ePRIME.recordCompletedUnit":
					case "ePRIME.recordCompletedVideo":					
					//trace("i can't believe you would need to use " + service + "... -_- f(';..;')f ");
					return true;
					break;
					
				
					
					case "ePRIME.getProgress":
					var retOb:Object = new Object(); 
					var la:Array = new Array();
					var sa:Array = new Array();
					for (var a:uint = 0; a < lessonArray.length; a++)
					{
						if (lessonArray[a].complete)
						{
							la[a] = { "nid":lessonArray[a].lessonId };
							sa[a] = { "nid":lessonArray[a].sceneId };
						}
					}
					retOb["field_myprime_completed_lessons"] = la;
					retOb["field_myprime_completed_scenes"] = sa;
					retOb["Unit 1: Exploring"] = 26;
					retOb["Unit 2: Reflecting"] = 9;
					retOb["Unit 3: Protecting"] = 8;
					retOb["total_lessons"] = 43;
					return retOb;
					break;
					
					case "ePRIME.getNextScene":		
					var tmp:Object = getNextLessonBySceneId(params[1]);
					var result:Array = new Array();
					result[0] = new Array();
					result[0]["uid"] = getUserId();
					result[0]["currentinstructor"] = "49";
					result[0]["scenexmlurl"] = tmp.xml;
					result[0]["lastsavepoint"] = tmp.savePoint;
					result[0]["complete"] = tmp.complete;
					user.lesson = tmp.count;
					user.currentLocation = "";
					var pCount:uint = 0;
					for (var b:uint = 0; b < lessonArray.length; b++)
					{
						if (lessonArray[b].complete)
						{
							pCount++;
						}
					}
					user.totalProgress = pCount;
					
					//trace(tmp.xml + "\n" + tmp.savePoint + "\n" + tmp.complete + "\n" + tmp.count);
					commitDataToSharedObject();
					return result;
					break;
					
					case "ePRIME.getGlossary":
					handleGetGlossary();
					return true;
					break;
					
					case "ePRIME.getMyReview":
					handleGetReview();
					return true;
					break;
					
					case "ePRIME.getMyStuff":
					handleGetMyStuff();
					return true;
					break;
					
					
					case "ePRIME.getMyTimeline":
					var obj:Object = getTimeLine(params[1]);
					commitDataToSharedObject();
					return obj;
					break;
					
					case "ePRIME.setMyTimeline":
					var bool:Boolean =  setTimeLine(params);
					commitDataToSharedObject();
					return bool;
					break;
					
					case "ePRIME.sendContact":
					var sc:Boolean = saveContact(params);
					commitDataToSharedObject();
					return sc;
					break;
					
					
					case "ePRIME.retrieveMapData":
					var mapdData:Object = getMapData(params[1]);
					return false;
					break;
					
					
					
					default:
					trace("service not found:", service);
					return null;
					break;
				}
			
		}
		
		/****************** Lesson Functions ************************/
		private function getLessonXmlBySceneId(sceneId:String):String
		{
			var found:Boolean = false;
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (sceneId == lessonArray[i].sceneId)
				{
					found = true;
					return lessonArray[i].xml;
				}
			}
			if (!found)
			{
				return lessonArray[0].xml;
			}
			
			return "";
		}
		
		private function getLessonStatusBySceneId(sceneId:String):Boolean
		{
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (sceneId == lessonArray[i].sceneId)
				{
					return lessonArray[i].complete;
				}
			}
			
			return false;
		}
		
		private function getSavePointBySceneId(sceneId:String):String 
		{
			if (sceneId == "")
			{
				return "";
			}
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (sceneId == lessonArray[i].sceneId)
				{
					return lessonArray[i].savePoint;
				}
			}
			
			return "";
		}
		
		private function getNextLessonBySceneId(sceneId:String):Object
		{
			
			var found:Boolean = false;
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				//trace(lessonArray[i].sceneId);
				if (sceneId == lessonArray[i].sceneId)
				{
					if (sceneId == "3763")
					{
						return lessonArray[48];
					}
					else if (sceneId == "3650")
					{
						return lessonArray[lessonArray.length - 1];
					}
					else if (lessonArray[i + 1])
					{
						//trace(lessonArray[i + 1].xml);
						found = true;
						return lessonArray[i + 1];
					}
				}
			}
			if (!found)
			{
				return null;
			}
			
			return null;
		}
		
		private function getLessonIndexBySceneId(sceneId:String):uint
		{
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (sceneId == lessonArray[i].sceneId)
				{
					return i;
				}
			}
			
			return 0;
		}
		
		private function recordSceneComplete(sceneId:String):Boolean
		{
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (sceneId == lessonArray[i].sceneId)
				{
					lessonArray[i].complete = true;
					return true;
				}
			}
			return false;
		}
		private function recordLessonComplete(lessonId:String):Boolean
		{
			for (var i:uint = 0; i < lessonArray.length; i++)
			{
				if (lessonId == lessonArray[i].id)
				{
					
					lessonArray[i].complete = true;
					return true;
				}
			}
			return false;
		}
		
		/********************* User functions **************************/
		public function handleNewUser(userObject:Object):void
		{
			var file:String = userObject.name + userObject.pass;
			trace("kachow : "  +file);
			userSo = SharedObject.getLocal(file, "/");
			if (userSo.data.courseData)
			{
				//userSo.clear();
			}
			else
			{
				user = new amtrakUser();
				user.uid = userObject.uid;
				user.name = userObject.name;
				user.pass = userObject.pass;
				user.location = userObject.location;
				user.currentLocation = "";
				user.totalProgress = 0;
				userSo.data.user = user;
				
				componentList = new Array();
				this.addEventListener("LESSON_DATA_LOADED", handleLoadComponents);
				this.addEventListener("COMPONENT_DATA_LOADED", handleLoadComplete);
				loadCourseData();
				
			}
			
		}
		public function handleDemoUser(userObject:Object):void
		{
			var file:String = userObject.name + userObject.pass;
			trace(file.toString());
			file = file.toString();
			userSo = SharedObject.getLocal(file, "/");
			if (userSo.data.user)
			{
				user = new amtrakUser();
				user.uid = userSo.data.user.uid;
				user.name = userSo.data.user.name;
				user.pass = userSo.data.user.pass;
				user.location = userSo.data.user.location;
				user.currentLocation = userSo.data.user.currentLocation;
				
				user.totalProgress = userSo.data.user.totalProgress;
				user.lesson = userSo.data.user.lesson;
				
				
				this.addEventListener("LESSON_DATA_LOADED", handleLoadComponents);
				this.addEventListener("COMPONENT_DATA_LOADED", handleLoadComplete);
				//loadCourseData();
				handleLoadLesson();
			}
			else
			{
				trace("totally new test user");
				user = new amtrakUser();
				user.uid = "xxx";
				user.name = "amtrak";
				user.pass = "password";
				user.location = 0;
				user.currentLocation = "";
				user.totalProgress = 0;
				userSo.data.user = user;
				
				componentList = new Array();
				this.addEventListener("LESSON_DATA_LOADED", handleLoadDemoComponents);
				this.addEventListener("COMPONENT_DATA_LOADED", handleLoadComplete);
				
				loadDemoCourseData();
				
			}
			
		}
		private function handleLoadComplete(e:Event):void
		{
			commitDataToSharedObject();
			dispatchEvent(new Event("LOAD_COMPLETE"));
		}
		public function handleUserLogin(file:String):Boolean
		{
			userSo = SharedObject.getLocal(file, "/");
			if (userSo.data.user)
			{
				user = new amtrakUser();
				user.uid = userSo.data.user.uid;
				user.name = userSo.data.user.name;
				user.pass = userSo.data.user.pass;
				user.location = userSo.data.user.location;
				user.currentLocation = userSo.data.user.currentLocation;
				
				user.totalProgress = userSo.data.user.totalProgress;
				user.lesson = userSo.data.user.lesson;
				
				
				this.addEventListener("LESSON_DATA_LOADED", handleLoadComponents);
				this.addEventListener("COMPONENT_DATA_LOADED", handleLoadComplete);
				//loadCourseData();
				handleLoadLesson();
				return true;
				
			}
			else
			{
				trace("didn't find local shared object for : " + file);
				return false;
			}
		}
		private function getUserId():String
		{
			return user.uid;
		}
		private function getUserById(userID:String):amtrakUser
		{
			if (user.uid == userID)
			{
				return user;
			}
			else return null;
		}
		public function getUser () : amtrakUser 
		{
			return user;
		}
		
		public function setUserLocation(sceneId:String, savePoint:String):void
		{
			user.lesson = getLessonIndexBySceneId(sceneId);
			user.currentLocation = savePoint;
			commitDataToSharedObject();
		}
		
		/******************* Course Functions *********************/
		private function loadDemoCourseData():void 
		{
			lessonArray = new Array();
			menuXmlLoader = new URLLoader();
			menuXmlLoader.dataFormat = "e4x";
			menuXmlLoader.addEventListener( Event.COMPLETE, handleDemoCourseXML);
			menuXmlLoader.load( new URLRequest("data/myPRIME_taxonomy.xml") );	
		}
		
		private function handleDemoCourseXML(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var menu:XML = new XML(loader.data);
			
			var units:XMLList = menu["link-collection"].children();
			
			//var pathArray:Array = user.TotalProgress.split(/U{1,2}/)[1].split(/L{1,2}/);
			var unitCount:uint = 0;
			var count:uint = 0;
			for each (var unit:XML in units)
			{
					unitCount++;
					var lessons:XMLList = unit["link-collection"].link;
					for each(var lesson:XML in lessons)
					{
						var lessonObject:Object = new Object();
						lessonObject.title = lesson.title.toString();
						lessonObject.sceneId = lesson.sceneId.toString();
						lessonObject.lessonId = lesson.@id.toString();
						lessonObject.xml = lesson.url.toString();
						lessonObject.unit = unitCount;
						lessonObject.count = count;
						lessonObject.complete = true;
						lessonObject.savePoint = "";
						//trace("save Point in lesson " + count +"  is... " +lessonObject.savePoint + " Lesson : " + user.lesson + " count: " + count );
						lessonArray.push(lessonObject);
						count++;
					}
				
			}
			userSo.data.lessonList = lessonArray;
			trace("lesson data loaded...");
			dispatchEvent(new Event("LESSON_DATA_LOADED"));
		}
		private function loadCourseData():void 
		{
			
			trace("Write initial course data to LSO");
			/*for (var i:int = 0; i < lessonArray.length; i ++)
			{
				var lessonObject:Object = new Object();
				lessonObject.count = i;
				lessonObject.savePont = "";
			}
			userSo.data.lessonList = lessonArray;
			trace("lesson data loaded...");
			dispatchEvent(new Event("LESSON_DATA_LOADED"));*/
			
			lessonArray = new Array();
			menuXmlLoader = new URLLoader();
			menuXmlLoader.dataFormat = "e4x";
			menuXmlLoader.addEventListener( Event.COMPLETE, handleCourseXML);
			menuXmlLoader.load( new URLRequest("data/myPRIME_taxonomy.xml") );	
		}
		
		private function handleCourseXML(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var menu:XML = new XML(loader.data);
			
			var units:XMLList = menu["node-collection"].children();
			
			//var pathArray:Array = user.TotalProgress.split(/U{1,2}/)[1].split(/L{1,2}/);
			var unitCount:uint = 0;
			var count:uint = 0;
			for each (var unit:XML in units)
			{
				
					unitCount++;
					var lessons:XMLList = unit["node-collection"].node;
					for each(var lesson:XML in lessons)
					{
						
						var lessonObject:Object = new Object();
						lessonObject.title = lesson.title.toString();
						lessonObject.xml = lesson.url.toString();
						lessonObject.unit = unitCount;
						lessonObject.count = count;
						lessonObject.complete = false;
						lessonObject.savePoint = "";
						//trace("save Point in lesson " + count +"  is... " +lessonObject.savePoint + " Lesson : " + user.lesson + " count: " + count );
						lessonArray.push(lessonObject);
						count++;
					}
				
			}
			userSo.data.lessonList = lessonArray;
			trace("lesson data loaded...");
			dispatchEvent(new Event("LESSON_DATA_LOADED"));
		}
		
		private function handleDemoCompXML(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var menu:XML = new XML(loader.data);
			//trace(menu);
			
			var compList:XMLList = menu.component;
			//trace(compList);
			for each(var comp:XML in compList)
			{
				var params:Array = new Array();
				params[0] = "XXXXXXXXXXXX";
				comp.evalInfo
				var uv:URLVariables = new URLVariables();
				uv.type = comp.evalInfo.@type.toString();
				uv.componentID = comp.evalInfo.@componentID.toString();
				uv.date = comp.evalInfo.@date.toString();
				uv.evalType = comp.evalInfo.@evalType.toString();
				if (comp.evalInfo.questionText.toString() != "")
				{
					uv.questionText = comp.evalInfo.questionText.toString();
				}
				
				if (comp.evalInfo.@templateType.toString() != "")
				{
					uv.templateType = comp.evalInfo.@templateType.toString();
				}
				params[1] = uv;
				
				var evalData:Array = new Array();
				if (uv.type == "evaluation")
				{
					var evalList:XMLList = comp.evalData.choice;
					for each (var evals:XML in evalList)
					{
						evalData.push( { "answerID":evals.@id.toString(), "answerData":evals.toString() } );
					}
					
				}
				else
				{
					
					
					var goalList:XMLList = comp.evalData.goal;
					for each (var goal:XML in goalList)
					{
						var obj:Object = new Object();
						var nodeList:XMLList = comp.evalData.goal.*;
						for each (var node:XML in nodeList)
						{
							obj[node.name()] = node.toString();
							
						}
						evalData.push(obj);
					}
				}
				params[2] = evalData;
				setComponentDataById(params);
			}
			
			
			trace("component data loaded...");
			dispatchEvent(new Event("COMPONENT_DATA_LOADED"));
		}
		
		private function handleLoadLesson():void 
		{
			lessonArray = new Array();
			if (userSo.data.lessonList)
			{
				lessonArray = userSo.data.lessonList;
			}
			trace("lesson data loaded...");
			dispatchEvent(new Event("LESSON_DATA_LOADED"));
		}
		private function handleLoadComponents(e:Event):void
		{
			componentList = new Array();
			if (userSo.data.componentList)
			{
				componentList = userSo.data.componentList;
			}
			trace("component data loaded...");
			dispatchEvent(new Event("COMPONENT_DATA_LOADED"));
			
		}
		
		private function handleLoadDemoComponents(e:Event):void 
		{
			componentList = new Array();
			menuXmlLoader = new URLLoader();
			menuXmlLoader.dataFormat = "e4x";
			menuXmlLoader.addEventListener( Event.COMPLETE, handleDemoCompXML);
			menuXmlLoader.load( new URLRequest("data/demo.xml") );	
			
		}
		/****************** EvalObject ***********************/
		
		private function getComponentDataById(compId:String):Array
		{
			
			for (var i:uint = 0; i < componentList.length; i++)
			{
				if (compId == componentList[i].id)
				{
					return(componentList[i].evalData);
				}
			}
			
			return null;
		}
		
		private function setComponentDataById(params:Array):Boolean
		{
			var found:Boolean = false;
			for (var i:uint = 0; i < componentList.length; i++)
			{
				if (params[1].componentID == componentList[i].id)
				{
					componentList[i].evalInfo = params[1];
					componentList[i].evalData = params[2];
					found = true;
					return true;
				}
			}
			
			if (!found)
			{
				//trace("i didn't find: " + params[1].componentID + " so i will add it to the list");
				var comp:Object = new Object();
				comp.id = params[1].componentID;
				comp.evalInfo = params[1];
				comp.evalData = params[2];
				componentList.push(comp);
				return true;
			}
			else
			{
				return false;
			}
			
		}
		
		/********************* system level functions ***********************************/
		
		
		private function generateFileKey(userName:String, password:String):String
		{
			var fileName:String = userName + password;
			return fileName;
		}
		
		private function commitDataToSharedObject():void
		{
			trace("commiting data to local shared object...");
			userSo.data.user = user;
			userSo.data.componentList = componentList;
			var flushStatus:String = null;
            try 
			{
                flushStatus = userSo.flush(10000);
            } 
			catch (error:Error) 
			{
                trace("Error...Could not write SharedObject to disk\n");
            }
            if (flushStatus != null) 
			{
                switch (flushStatus) 
				{
                    case SharedObjectFlushStatus.PENDING:
                        trace("Requesting permission to save object...\n");
                        userSo.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                        break;
                    case SharedObjectFlushStatus.FLUSHED:
					trace("************ D A T A ********************.\n ************* S A V E D *************************");
                        break;
                }
            }        
		}
		 private function onFlushStatus(event:NetStatusEvent):void 
		 {
            trace("User closed permission dialog...\n");
            switch (event.info.code) 
			{
                case "SharedObject.Flush.Success":
                    trace("User granted permission -- value saved.\n");
                    break;
                case "SharedObject.Flush.Failed":
                    trace("User denied permission -- value not saved.\n");
                    break;
            }
            userSo.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		 }
		private function getTimeLine(type:String):Object
		{
			switch(type)
			{
				case "past":
				return getComponentDataById("u2l7c10");
				break;
				
				case "future":
				return getComponentDataById("u3l2c3");
				break;
				
				default:
				break;
			}
			return null;
		}
		
		private function setTimeLine(params:Array):Boolean
		{
			var uv:URLVariables = new URLVariables();
			uv.date = TimeStamp.NewTimeStamp.time.toString();
			uv.type = "Timeline";
			switch(params[1])
			{
				case "past":
				uv.evalType = "past";
				uv.componentID = "u2l7c10";
				break;
				
				case "future":
				uv.evalType = "future";
				uv.componentID = "u3l2c3";
				break;
				
				default:
				break;
			}
			params[1] = uv;
			
			var goalsArray:Array = new Array();
			var oldArray:Array = params[2];
			for (var b:uint = 0; b <oldArray.length; b++)
			{
				var tmp:Object = new Object();
				tmp["node_title"] = "Timeline Item - " + user.name;
				tmp["node_data_field_timeline_type_field_timeline_type_value"] = oldArray[b].timeline_type;
				tmp["node_revisions_body"] = oldArray[b].body;
				tmp["node_data_field_timeline_type_field_timeline_startdate_value"] = oldArray[b].startdate;
				tmp["node_data_field_timeline_type_field_timeline_enddate_value"] = oldArray[b].enddate;
				tmp["node_data_field_timeline_type_field_timeline_orientation_value"] = oldArray[b].orientation;
				tmp["node_data_field_timeline_type_field_timeline_x_value"] = oldArray[b].x;
				tmp["node_data_field_timeline_type_field_timeline_y_value"] = oldArray[b].y;
				
				goalsArray.push(tmp);
			}
			params[2] = goalsArray;

			return (setComponentDataById(params));
		}
		private function saveContact(params:Array):Boolean
		{
			var newParams:Array = new Array();
			var uv:URLVariables = new URLVariables();
			uv.componentID = TimeStamp.NewTimeStamp.time.toString();
			uv.date = TimeStamp.NewTimeStamp.time.toString();
			uv.type = "contact";
			uv.evalType = "contact";
			newParams[0] = "XXXXXXXXX";
			newParams[1] = uv;
			newParams[2] = params.slice(1);
			return (setComponentDataById(newParams));
		}
		
		public function getSynchUpData():String
		{
			return course;
		}
		public function handleSynchUp():void
		{
			course = <course/>;
			
			for (var i:uint = 0; i < componentList.length; i++)
			{
				var comp:XML = <component/>;
				if (componentList[i]["evalInfo"])
				{
					//trace("evalInfo: ");
					var evalInfo:XML = <evalInfo/>
					for (var o:* in componentList[i]["evalInfo"])
					{
						switch(o)
						{
							case "type":
							evalInfo.@type = componentList[i]["evalInfo"][o];
							break;
							
							case "componentID":
							evalInfo.@componentID = componentList[i]["evalInfo"][o];
							break;
							
							case "date":
							evalInfo.@date = componentList[i]["evalInfo"][o];
							break;
							
							case "evalType":
							evalInfo.@evalType = componentList[i]["evalInfo"][o];
							break;
							
							case "questionText":
							var questionText:XML = new XML("<questionText><![CDATA[" + componentList[i]["evalInfo"][o]+ "]]></questionText>");
							evalInfo.appendChild(questionText);
							break;
							
							case "templateType":
							evalInfo.@templateType = componentList[i]["evalInfo"][o];
							break;
							
							default:
							break;
						}
						//evalInfo@[o] = componentList[i]["evalInfo"][o];
						//trace(o + " : " +componentList[i]["evalInfo"][o]);
					}
					comp.appendChild(evalInfo);
				}
				if (componentList[i]["evalData"])
				{
					//trace("evalData: ");
					var evalD:XML = <evalData/>;
					var evalData:Array = componentList[i]["evalData"];
					for (var k:uint = 0; k < evalData.length; k++)
					{
						if (componentList[i]["evalInfo"]["type"] == "Timeline")
						{
							//trace("goal:");
							var goal:XML = <goal/>;
							for (var s:* in componentList[i]["evalData"][k])
							{
								//trace(s + " : " +componentList[i]["evalData"][k][s]);
								var openTag:String = "<" + s + "/>";
								//trace(openTag);
								var opn:XML = new XML(openTag);
								//trace(opn);
								opn.appendChild(componentList[i]["evalData"][k][s]);
								goal.appendChild(opn);
							}
							evalD.appendChild(goal);
							//trace(evalData[k].x+ "\n" + evalData[k].y+ "\n" + evalData[k].body + "\n" + evalData[k].orientation + "\n" + evalData[k].timeline_type + "\n" + evalData[k].startDate);
						}
						else if (componentList[i]["evalInfo"]["type"] == "evaluation")
						{
							//trace("answerID: " + evalData[k].answerID + " - - - \nanswerData: " + evalData[k].answerData);
							var choice:XML = <choice/>;
							choice.@id = evalData[k].answerID;
							choice.appendChild(evalData[k].answerData);
							evalD.appendChild(choice);
						}
						else if (componentList[i]["evalInfo"]["type"] == "contact")
						{
							//trace("answerID: " + evalData[k].answerID + " - - - \nanswerData: " + evalData[k].answerData);
							var contact:XML = <contact/>;
							for (var c:* in componentList[i]["evalData"][k])
							{
								//trace(s + " : " +componentList[i]["evalData"][k][s]);
								var conTag:String = "<" + s + "/>";
								//trace(openTag);
								var con:XML = new XML(conTag);
								//trace(opn);
								con.appendChild(componentList[i]["evalData"][k][s]);
								contact.appendChild(opn);
							}
							evalD.appendChild(contact);
						}
					}
					comp.appendChild(evalD);
				}
				//trace(i);
				course.appendChild(comp);
			}
			
			//trace(course);
			dispatchEvent(new Event("DATA_READY"));
		}
		private function getMapData(compId:String):Object
		{
			var evalData:Array;
			var evalData2:Array;
			var tmp:Object;
			var tmp2:Array;
			switch(compId) 
			{
				case "u1l1c14":
				evalData= getComponentDataById("u1l1c14b");
				if (evalData[0].answerData == "1")
				{
					evalData2 = getComponentDataById("u1l1c13");
					if (evalData2[0].answerData)
					{
						tmp = new Object();
						tmp["title"] = evalData2[0].answerData;
						tmp["desc"] = evalData2[0].answerData;
						tmp["lat"] = user.location["latitude"];
						tmp["lon"] = user.location["longitude"];
						tmp["name"] = user.location["name"];
						
						tmp2 = new Array(tmp);
						
					}
				}
				return tmp2;
				break;
			}
			return null;
		}
		
		private function handleGetGlossary():void
		{
			var glossaryXmlLoader:URLLoader = new URLLoader();
			glossaryXmlLoader.dataFormat = "e4x";
			glossaryXmlLoader.addEventListener( Event.COMPLETE, parseGlossary);
			glossaryXmlLoader.load( new URLRequest("flash/glossary.xml") );	
		}
		private function parseGlossary(e:Event):void
		{
			glossary = new Array();
			var loader:URLLoader = e.target as URLLoader;
			var menu:XML = new XML(loader.data);
			
			var words:XMLList = menu.channel.item;
			for each (var item:XML in words)
			{
				var tmp:Object = new Object();
				tmp["node_title"] = item.title.toString();
				tmp["node_revisions_body"] = item.description.toString();
				glossary.push(tmp);
			}
			
			dispatchEvent(new Event("GLOSSARY_LOADED"));
		}
		
		public function getGlossary():Array
		{
			if (glossary)
			{
				return glossary;
			}
			return null;
		}
		
		private function handleGetReview():void
		{
			var reviewXmlLoader:URLLoader = new URLLoader();
			reviewXmlLoader.dataFormat = "e4x";
			reviewXmlLoader.addEventListener( Event.COMPLETE, parseReview);
			reviewXmlLoader.load( new URLRequest("flash/myreviewstructure.xml") );	
		}
		private function parseReview(e:Event):void
		{
			review = new Array();
			var lessArray:Array = lessonArray.slice(0);
			for (var a:uint = 0; a < lessArray.length; a++)
			{
				if (lessArray[a].count == 29 || lessArray[a].count == 31 || lessArray[a].count == 33)
				{
					lessArray.splice(a, 1);
				}
			}
			
			var loader:URLLoader = e.target as URLLoader;
			var menu:XML = new XML(loader.data);
			var reviewXML:XML = new XML(menu.children());
			
			var units:XMLList = reviewXML.children();
			var unitCount:uint = 0;
			var count:uint = 0;
			for each (var unit:XML in units)
			{
					//trace(unit);
					unitCount++;
					var tmp:Array = new Array();
					tmp["Unit"] = unit.@title.toString();
					tmp["Lessons"] = [];
					review.push(tmp);
					var lessons:XMLList = unit.children();
					for each(var lesson:XML in lessons)
					{
						
							var tmp2:Array = new Array();
							//trace(lesson.@title.toString() );
							var lessonObject:Object = new Object();
							lessonObject["Lesson"] = lesson.@title.toString();
							lessonObject["imgurl"] = "assets/media/images/" + lesson.@img.toString();
							lessonObject["Description"] = String(lesson.text());
							
							var lessonInfo : Object;
							
							if (count < 39)
							{
								lessonInfo = lessArray[count];
								//trace(count + " ** " + lessonInfo.title);
							}
							else if (count == 39)
							{
								lessonInfo = lessArray[lessArray.length - 1];
								//trace(count + " !! " + lessonInfo.title);
							}
							else if(count>39)
							{
								lessonInfo = lessArray[count+5];
								//trace(count + " $$ " + lessonInfo.title);
							}
							
							
							lessonObject["Enabled"] = lessonInfo.complete ? "enabled" : "disabled";
							lessonObject["LessonID"] = lessonInfo.lessonId;
							lessonObject["SceneID"] = lessonInfo.sceneId;
							
							var practiceList:XMLList = lesson["Practice"];
							lessonObject["Practices"] = new Array();
							for each(var pItem:XML in practiceList)
							{
								//trace(pItem.toXMLString());
								var pObject:Object = new Object();
								pObject["practice_nid"] = pItem.@practice_nid.toString();
								pObject["practice_name"] = pItem.@practice_name.toString();
								pObject["practice_url"] = pItem.@practice_url.toString();
								pObject["practice_image"] = "assets/media/images/" +pItem.@practice_image.toString();
								lessonObject["Practices"].push(pObject);
							}
							
							//trace(practiceList);
							var tmp3:Array = new Array();
							tmp3[0] = lessonObject;
							tmp2["Lessons"] = tmp3;
							review.push(tmp2);
						
						
						count++;
					}
				
			}
			
			dispatchEvent(new Event("REVIEW_LOADED"));
		}
		
		public function getReview():Array
		{
			if (review)
			{
				return review;
			}
			return null;
		}
		
		private function handleGetMyStuff():void
		{
			notes = new Array();
			reflections = new Array();
			puzzle = new Array();
			
			
			var values:Array = new Array();
			var choices:Array = new Array();
			var formula:Array = new Array();
			var experiences:Array = new Array();
			var past:Array = new Array();
			var future:Array = new Array();
			var success:Array = new Array();
			var support:Array = new Array();
			var internalR:Array = new Array();
			var fun:Array = new Array();
			var state:Array = new Array();
			var rewards:Array = new Array();
			var quick:Array = new Array();
			var letter:Array = new Array();
			
			var rQString:String = "u1l1c9,u1l5c5,u1l6t1ac11a,u1l6t4c9,u1l8t1c5,u1l9c10,u1l9c22,u1l11t3c7,u1l14c11_1,u1l14c11_2,u1l14c11_3,";
			rQString += "u2l4c34_1,u2l4c34_2,u2l4c37_1,u2l4c37_2,u2l5c6_1,u2l5c6_2,u2l5c6_3,u2l5c6_4,u2l5c10,u2l7c4,u2l7c12_1,";
			rQString += "u2l7c12_2,u3l2c4_1,u3l2c4_2,u3l2c4_3,u3l4c7_1,u3l4c7_2,u3l4c7_3,u3l4c7_4,u3l4c7_5,u3l5c5_1,u3l5c5_2,";
			rQString += "u3l5c5_3,u3l6c5_1,u3l6c5_2,u3l6c5_3,u3l10c3b_1,u3l10c3b_2,u3l10c3b_2b,u3l10c3b_3,u3l10c3b_4,u3l10c3b_5,";
			rQString += "u3l10c3b_6,u3l10c3b_7,u3l10c3d_1,u3l10c3d_2,u3l10c3d_2b,u3l10c3d_3,u3l10c3d_4,u3l10c3d_5,u3l10c3d_6,";
			rQString += "u3l10c3d_7,u3l10c3d_8";

			var pzString:String = "u1l1c11,u1l9c21,u1l9c22b,u1l9c22c,u1l14c8,u1l14c9,u2l0c3_1,u2l0c3_2,u2l0c3_3,u2l7c10,";
			pzString += "u2l7c7,u3l2c3,u3l2c4_1,u3l2c4_2,u3l2c4_3,u3l3c5_1,u3l3c5_2,u3l3c5_3,u3l3c6_7,u3l4c7_1,u3l4c7_2,";
			pzString += "u3l4c7_3,u3l4c7_4,u3l4c7_5,u3l5c5_1,u3l5c5_2,u3l5c5_3,u3l5c6_1,u3l5c6_2,u3l5c6_3,u3l6c5_1,u3l6c5_2,";
			pzString += "u3l6c5_3,u3l6c7_3,u3l7c5_1,u3l7c5_2,u3l7c5_3,u3l7c5_4,u3l7c5_5,u3l8c4,u3l8c7_1,u3l8c7_2,u3l9c6_1,";
			pzString += "u3l9c6_2,u3l9c6_3,u3l9c6_4,u3l9c8_1,u3l9c8_2,u3l9c8_3,u3l9c8_4,u3l11c3";
			
			var pzCheck:Array = pzString.split(",");
			
			var rQCheck:Array = rQString.split(",");
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "YYYYMMDD";
			for (var i:uint = 0; i < componentList.length; i++)
			{
				if (componentList[i].evalInfo.templateType == "notes")
				{
					trace(componentList[i].id + "\n" + componentList[i].evalData[0].answerData);
					var noteObject:Object = new Object();
					//passing "nid" for compID for editNoteReflection
					noteObject["nid"] = componentList[i].id;
					noteObject["bodytext"] = componentList[i].evalData[0].answerData;
					noteObject["title"] = componentList[i].evalInfo.questionText;
					noteObject["imgurl"] = "assets/media/images/practice_area_img.png";
					var nd:Date = new Date();
					nd.time = componentList[i].evalInfo.date;
					noteObject["datetime"] = formatter.format(new Date(nd));
					notes.push(noteObject);
				}
				
				var pathArray:Array = componentList[i].id.split("c");
				var imagePath:String = "TG_" + pathArray[0].toUpperCase() + "C1.png";
				//trace(imagePath);
				componentList[i].img = imagePath;
				for (var j:uint = 0; j < rQCheck.length; j++)
				{
					if (componentList[i].id == rQCheck[j])
					{
						//trace(componentList[i].evalInfo.questionText);
						switch(componentList[i].evalInfo.evalType)
						{
							case "ReflectionQuestion":
							var rqObject:Object = new Object();
							rqObject["nid"] = componentList[i].id;
							rqObject["bodytext"] = componentList[i].evalData[0].answerData;
							rqObject["title"] = componentList[i].evalInfo.questionText;
							rqObject["imgurl"] = "assets/media/images/" + componentList[i].img;
							reflections.push(rqObject);
							break;
							
							case "Assessment":
							break;
							
							default:
							break;
						}
						
					}	
				}
				for (var k:uint = 0; k < pzCheck.length; k++)
				{
					if (componentList[i].id == pzCheck[k])
					{
						
						switch(componentList[i].id)
						{
							//My Values
							case "u1l1c11":
								values.push(buildValues(componentList[i]));
								puzzle = puzzle.concat(values);
							break;
							
							// My Choices
							case "u1l9c21":							
							case "u1l9c22b":
							case "u1l9c22c":
								buildChoices(componentList[i], choices);
							break;
							
							//My Formula
							case "u1l14c8":
							case "u1l14c9":
								buildFormula(componentList[i], formula);
							break;
							
							//My Experiences 
							case "u2l0c3_1":
							case "u2l0c3_2":
							case "u2l0c3_3":
								buildExperiences(componentList[i], experiences);
							break;
							
							//A Timeline of My Experiences 
							case "u2l7c10":
								past.push(buildPastTimeline(componentList[i]));
							break;
							
							//My Future Timeline 
							case "u3l2c3":
							case "u3l2c4_1":
							case "u3l2c4_2":
							case "u3l2c4_3":
								buildFutureTimeline(componentList[i], future);
							break;
							
							//My Plan for Success 
							case "u3l3c5_1":
							case "u3l3c5_2":
							case "u3l3c5_3":
							case "u3l3c6_7":
								buildPlan(componentList[i], success);
							break;
							
							
							//My Sources of Support  (U3L4C7)
							case "u3l4c7_1":
							case "u3l4c7_2":
							case "u3l4c7_3":
							case "u3l4c7_4":
							case "u3l4c7_5":
								buildSupport(componentList[i], support);
							break;
							
							//My Internal Resources (U3L5C5)
							case "u3l5c5_1":
							case "u3l5c5_2":
							case "u3l5c5_3":
								buildInternal(componentList[i], internalR);
							break;
							
							//My Fun 
							case "u3l6c5_1":
							case "u3l6c5_2":
							case "u3l6c5_3":
							case "u3l6c7_3":
								buildMyFun(componentList[i], fun);
							break;
							
							//Overcoming State Dependent Learning 
							case "u3l7c5_1":
							case "u3l7c5_2":
							case "u3l7c5_3":
							case "u3l7c5_4":
							case "u3l7c5_5":
								buildOSDL(componentList[i], state);
							break;
							
							//My Rewards 
							case "u3l8c4":
							case "u3l8c7_1":
							case "u3l8c7_2":
								buildRewards(componentList[i], rewards);
							break;
							
							//Be Ready, Be Quick Strategies 
							case "u3l9c6_1":
							case "u3l9c6_2":
							case "u3l9c6_3":
							case "u3l9c6_4":
							case "u3l9c8_1":
							case "u3l9c8_2":
							case "u3l9c8_3":
							case "u3l9c8_4":
								buildBRBQ(componentList[i], quick);
							break;
							
							//My Letter 
							case "u3l11c3":
								buildLetter(componentList[i],letter);
							break;
							
							default:
							break;
							
						}
					}
				
				}
				
			}
			
			// push it all Choices together:
			if (choices.length > 0)
			{
				var cObject:Object = new Object();	
				cObject["nid"] = "u1l9c21";
				cObject["title"] = "My Choices";
				cObject["imgurl"] = "TG_U1L9C1.png";
				cObject["bodytext"] = "";
				//trace(choices.length);
				for (var a:uint = 0; a < choices.length; a++)
				{
					cObject["bodytext"] += choices[a]["bodytext"];
				}
				puzzle.push(cObject);
			}
			
		    if (formula.length > 0)
			{
				var fObject:Object = new Object();	
				fObject["nid"] = "u1l14c8";
				fObject["title"] = "My Formula";
				fObject["imgurl"] = "TG_U1L14C1.png";
				fObject["bodytext"] = "";
				//trace(formula.length);
				for (var f:uint = 0; f < formula.length; f++)
				{
					//trace(formula[f]["bodytext"]);
					fObject["bodytext"] += formula[f]["bodytext"];
				}
				puzzle.push(fObject);
			}
			
			 if (experiences.length > 0)
			{
				var eObject:Object = new Object();	
				eObject["nid"] = "u2l0c3";
				eObject["title"] = "My Experiences";
				eObject["imgurl"] = "TG_U2L0C1.png";
				eObject["bodytext"] = "";
				//trace(experiences.length);
				for (var e:uint = 0; e < experiences.length; e++)
				{
					//trace(experiences[e]["bodytext"]);
					eObject["bodytext"] += experiences[e]["bodytext"];
				}
				puzzle.push(eObject);
			}
			
			if (past.length > 0)
			{
				puzzle = puzzle.concat(past);
			}
			
			 if (future.length > 0)
			{
				var fuObject:Object = new Object();	
				fuObject["nid"] = "u3l2c3";
				fuObject["title"] = "My Future Timeline";
				fuObject["imgurl"] = "TG_U3L2C1.png";
				fuObject["bodytext"] = "";
				for (var q:uint = 0; q < future.length; q++)
				{
					//trace(future[q]["bodytext"]);
					fuObject["bodytext"] += future[q]["bodytext"];
				}
				puzzle.push(fuObject);
			}
			
			if (success.length > 0)
			{
				var sObject:Object = new Object();	
				sObject["nid"] = "u3l3c5_1";
				sObject["title"] = "My Plan for Success";
				sObject["imgurl"] = "TG_U3L3C1.png";
				sObject["bodytext"] = "";
				for (var s:uint = 0; s < success.length; s++)
				{
					//trace(success[s]["bodytext"]);
					sObject["bodytext"] += success[s]["bodytext"];
				}
				puzzle.push(sObject);
			}
			
			if (support.length > 0)
			{
				var suObject:Object = new Object();	
				suObject["nid"] = "u3l4c7_1";
				suObject["title"] = "My Sources of Support";
				suObject["imgurl"] = "TG_U3L4C1.png";
				suObject["bodytext"] = "";
				for (var su:uint = 0; su < support.length; su++)
				{
					//trace(support[su]["bodytext"]);
					suObject["bodytext"] += support[su]["bodytext"];
				}
				puzzle.push(suObject);
			}
			
			if (internalR.length > 0)
			{
				var iObject:Object = new Object();	
				iObject["nid"] = "u3l5c5_1";
				iObject["title"] = "My Internal Resources";
				iObject["imgurl"] = "TG_U3L5C1.png";
				iObject["bodytext"] = "";
				for (var r:uint = 0; r < internalR.length; r++)
				{
					//trace(internalR[r]["bodytext"]);
					iObject["bodytext"] += internalR[r]["bodytext"];
				}
				puzzle.push(iObject);
			}
			if (fun.length > 0)
			{
				var funObject:Object = new Object();	
				funObject["nid"] = "u3l6c5_1";
				funObject["title"] = "My Fun";
				funObject["imgurl"] = "TG_U3L6C1.png";
				funObject["bodytext"] = "";
				for (var ff:uint = 0; ff < fun.length; ff++)
				{
					//trace(fun[ff]["bodytext"]);
					funObject["bodytext"] += fun[ff]["bodytext"];
				}
				puzzle.push(funObject);
			}
			
			if (state.length > 0)
			{
				var stObject:Object = new Object();	
				stObject["nid"] = "u3l7c5_1";
				stObject["title"] = "Overcoming State Dependent Learning";
				stObject["imgurl"] = "TG_U3L7C1.png";
				stObject["bodytext"] = "";
				for (var st:uint = 0; st < state.length; st++)
				{
					//trace(state[st]["bodytext"]);
					stObject["bodytext"] += state[st]["bodytext"];
				}
				puzzle.push(stObject);
			}
			
			if (rewards.length > 0)
			{
				var rewObject:Object = new Object();	
				rewObject["nid"] = "u3l8c4";
				rewObject["title"] = "My Rewards ";
				rewObject["imgurl"] = "TG_U3L8C1.png";
				rewObject["bodytext"] = "";
				for (var rw:uint = 0; rw < rewards.length; rw++)
				{
					//trace(rewards[rw]["bodytext"]);
					rewObject["bodytext"] += rewards[rw]["bodytext"];
				}
				puzzle.push(rewObject);
			}
			
			if (quick.length > 0)
			{
				var qObject:Object = new Object();	
				qObject["nid"] = "u3l9c6_1";
				qObject["title"] = "Be Ready, Be Quick Strategies";
				qObject["imgurl"] = "TG_U3L9C1.png";
				qObject["bodytext"] = "";
				for (var qu:uint = 0; qu < quick.length; qu++)
				{
					//trace(quick[qu]["bodytext"]);
					qObject["bodytext"] += quick[qu]["bodytext"];
				}
				puzzle.push(qObject);
			}
			
			if (letter.length > 0)
			{
				var lObject:Object = new Object();	
				lObject["nid"] = "u3l11c3";
				lObject["title"] = "My Letter ";
				lObject["imgurl"] = "TG_U3L11C1.png";
				lObject["bodytext"] = "";
				for (var l:uint = 0; l < letter.length; l++)
				{
					//trace(letter[l]["bodytext"]);
					lObject["bodytext"] += letter[l]["bodytext"];
				}
				puzzle.push(lObject);
			}
			//trace(puzzle.length);
			//trace(notes.length);
			
			dispatchEvent(new Event("MYSTUFF_LOADED"));
		}
		
		public function getMyStuff():Array
		{
			var myStuffArray:Array = new Array();
			myStuffArray["notes"] = notes;
			myStuffArray["reflect"] = reflections;
			myStuffArray["puzzle"] = puzzle;
			return myStuffArray;
		}
		
		private function buildValues(comp:Object):Object 
		{
			//trace("building Values");
			var rObject:Object = new Object();
			rObject["nid"] = comp.id;
			rObject["bodytext"] = "<p>";
			rObject["bodytext"] += "1. <b>"+comp.evalData[0].answerData + "</b>";
			rObject["bodytext"] += "</p>";
			rObject["bodytext"] += "<p>";
			var four:Array = getComponentDataById("u1l1c8");
			var count:uint = 1;
			
			for (var i:uint = 0; i < four.length; i++)
			{
				if (comp.evalData[0].answerData != four[i].answerData)
				{
					count++;
					rObject["bodytext"] += count.toString() + ". " +four[i].answerData + "<br/>";
				}
			}
			
			rObject["bodytext"] += "</p>";
			rObject["bodytext"] += "<p>";
			var ten:Array = getComponentDataById("u1l1c5");
			for ( var j:uint = 0; j < ten.length; j++)
			{
				switch(ten[j].answerData)
				{
					case four[0].answerData:
					case four[1].answerData:
					case four[2].answerData:
					case four[3].answerData:
					break;
					
					default:
					count++;
					rObject["bodytext"] += count.toString() + ". " +ten[j].answerData + "<br/>";
					break;
					
				}
			}
			rObject["bodytext"] += "</p>";
			rObject["title"] = "My Values";
			rObject["imgurl"] = comp.img;
			return rObject;
		}
		
		private function buildChoices(comp:Object, container:Array):void
		{
			var rObject:Object = new Object();		

			switch(comp.id)
			{
				case "u1l9c21":		
				rObject["bodytext"] = "<p>Total drinks per week: "+comp.evalData[0].answerData.charAt(comp.evalData[0].answerData.length-1)+"</p><br/>";
				container.push(rObject);
				break;
				
				case "u1l9c22b":
				case "u1l9c22c":
				rObject["bodytext"] = "<p>" + comp.evalInfo.questionText + "<br/>" + comp.evalData[0].answerData + "</p><br/>";
				container.push(rObject);
				break;
				
				default:
				break;
			}
		
		}
		
		private function buildFormula(comp:Object, container:Array):void
		{
				var rObject:Object = new Object();	
				rObject["bodytext"] = "";
				var key:String = "Yes";
				var c8:Array = new Array();
				c8[0] = "<p>Do I have a family history of alcoholism? <br/>";
				c8[1] = "<p>Do I have high tolerance? <br/>";
				
				var c9:Array = new Array();
				c9[0] = "<p>Do I have any health problems that could be affected by alcohol? <br/>";
				c9[1] = "<p>Am I taking any medications that could increase my risk?<br/>";
				c9[2] = "<p>Do I have a small body size?<br/>";
				c9[3] = "<p>Do I need to plan for other changes in my life that might affect my metabolism?<br/>";
				switch(comp.id)
				{
					case "u1l14c8":		
					for (var i:uint = 0; i < comp.evalData.length; i++)
					{
						if (comp.evalData[i].answerData.charAt(comp.evalData[i].answerData.length - 1) == "1")
						{
							key = "No";
						}
						else if (comp.evalData[i].answerData.charAt(comp.evalData[i].answerData.length - 1) == "2")
						{
							key = "I don't know";
						}
						rObject["bodytext"] += c8[i]+key+"</p><br/>";
					}
					
		
					//trace(rObject["bodytext"]);
					container.push(rObject);
					break;
					
					case "u1l14c9":
					for (var j:uint = 0; j < comp.evalData.length; j++)
					{
						if (comp.evalData[j].answerData.charAt(comp.evalData[j].answerData.length - 1) == "1")
						{
							key = "No";
						}
						else if (comp.evalData[j].answerData.charAt(comp.evalData[j].answerData.length - 1) == "2")
						{
							key = "I don't know";
						}
						rObject["bodytext"] += c9[j] + key + "</p><br/>";
					}
					//trace(rObject["bodytext"]);
					container.push(rObject);
					break;
					
					default:
					break;
				}
			
		}
		private function buildExperiences(comp:Object, container:Array):void
		{
			var rObject:Object = new Object();	
				rObject["bodytext"] = "";
				var key:String = "Yes";
				var c1:Array = new Array();
				c1[0] = "<p>When I drink, I often drink more than the 0-1-2-3 Guidelines.<br/>";
				c1[1] = "<p>Occasionally, I use illegal drugs or use a prescription drug to get high.<br/>";
				c1[2] = "<p>It now takes more drugs or alcohol for me to get high or intoxicated than when I first started.<br/>";
				c1[3] = "<p>I function best in groups when I am making high-risk drinking or drug choices.<br/>";
				
				var c2:Array = new Array();
				c2[0] = "<p>Have you wanted or needed to cut down on your drinking or drug use in the last year? <br/>";
				c2[1] = "<p>In the last year, have you ever drunk or used drugs more than you meant to?<br/>";
				c2[2] = "<p>Have you had a feeling of guilt or remorse after drinking or drug use?<br/>";
				c2[3] = "<p>Have you failed to do what was normally expected from you because of drinking or drug use?<br/>";
	
			    var c3:Array = new Array();
				c3[0] = "<p>Have you been unable to remember what happened the night before because you had been drinking or using?<br/>";
				c3[1] = "<p>Have you needed a drink (or drug) in the morning to get yourself going after a heavy drinking or drug using episode?<br/>";
				c3[2] = "<p>Have you tried to cut back on your drinking or drug use but could not?<br/>";
				c3[3] = "<p>Sometimes when I start drinking or using drugs, it is like something takes over and I get drunk or high without meaning to.<br/>";
				
				
					
				switch(comp.id)
				{
					case "u2l0c3_1":		
					for (var i:uint = 0; i < comp.evalData.length; i++)
					{
						if (comp.evalData[i].answerData.charAt(comp.evalData[i].answerData.length - 1) == "1")
						{
							key = "No";
						}
						rObject["bodytext"] += c1[i]+key+"</p><br/>";
					}
					//trace(rObject["bodytext"]);
					container.push(rObject);
					break;
					
					case "u2l0c3_2":
					for (var j:uint = 0; j < comp.evalData.length; j++)
					{
						if (comp.evalData[j].answerData.charAt(comp.evalData[j].answerData.length - 1) == "1")
						{
							key = "No";
						}
						rObject["bodytext"] += c2[j] + key + "</p><br/>";
					}
					//trace(rObject["bodytext"]);
					container.push(rObject);
					break;
					
					case "u2l0c3_3":
					for (var k:uint = 0; k < comp.evalData.length; k++)
					{
						if (comp.evalData[k].answerData.charAt(comp.evalData[k].answerData.length - 1) == "1")
						{
							key = "No";
						}
						rObject["bodytext"] += c3[k] + key + "</p><br/>";
					}
					//trace(rObject["bodytext"]);
					container.push(rObject);
					break;
					
					
					default:
					break;
				}
			
			
		}
		private function buildPastTimeline(comp:Object):Object
		{
			var rObject:Object = new Object();
			rObject["nid"] = comp.id;
			rObject["title"] = "A Timeline of My Experiences";
			rObject["imgurl"] = comp.img;
			rObject["bodytext"] = "";
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "MM,DD,YYYY";
			for (var i:uint = 0; i < comp.evalData.length; i++)
			{
				rObject["bodytext"] += "<p><b>Date: </b>" + formatter.format(new  Date(comp.evalData[i]["node_data_field_timeline_type_field_timeline_startdate_value"])) + "<br/>";
				rObject["bodytext"] += comp.evalData[i]["node_revisions_body"] + "</p>";
			}
			//trace(rObject["bodytext"]);
			return rObject;
		}
		
		private function buildFutureTimeline(comp:Object, container:Array):void
		{
			var rObject:Object = new Object();
			
			rObject["bodytext"] = "";
			
			switch(comp.id)
			{
				case "u3l2c3":
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = "MM,DD,YYYY";
				for (var i:uint = 0; i < comp.evalData.length; i++)
				{
					rObject["bodytext"] += "<p><b>Date: </b>" + formatter.format(new  Date(comp.evalData[i]["node_data_field_timeline_type_field_timeline_startdate_value"])) + "<br/>";
					rObject["bodytext"] += comp.evalData[i]["node_revisions_body"] + "</p>";
				}
				container.push(rObject);
				break;
				
				case "u3l2c4_1":
				case "u3l2c4_2":
				case "u3l2c4_3":
				rObject["bodytext"] = "<br/><p>" + comp.evalInfo.questionText + "<br/>" + comp.evalData[0].answerData + "</p>";
				container.push(rObject);
				break;
				
				default:
				break;
			
			}
			
		}
		
		private function buildPlan(comp:Object, container:Array):void 
		{
			var rObject:Object = new Object();			
			rObject["bodytext"] = "";

			switch(comp.id)
			{
				case "u3l3c6_7":
				rObject["bodytext"] = "<b>My Plan:</b><br/>";
				for (var i:uint = 0; i < comp.evalData.length; i++)
				{
					if (i == 0)
					{
						comp.evalData[i].answerData = comp.evalData[i].answerData.replace(/\n/g, '');
					}
					rObject["bodytext"] += "<p>"+comp.evalData[i].answerData + "</p><br/>";
				}
				container.push(rObject);
				break;
				
				case "u3l3c5_1":
				case "u3l3c5_2":
				case "u3l3c5_3":
				var tmp:String = comp.evalInfo.questionText.replace(/<.*?>/g, "~~~");
				var questions:Array = tmp.split("~~~");
				for (var j:uint = 0; j < comp.evalData.length; j++)
				{
					rObject["bodytext"] += "<p>" + questions[j] + "<br/>" + comp.evalData[j].answerData + "</p><br/>";
				}
				container.push(rObject);
				break;
				
				default:
				break;
			
			}
		}
		private function buildSupport(comp:Object , container:Array):void
		{
			var rObject:Object = new Object();
			rObject["bodytext"] = "";
			rObject["bodytext"] = "<p>" + comp.evalInfo.questionText + "<br/>" + comp.evalData[0].answerData + "</p><br/>";
			container.push(rObject);
		}
		
		private function buildInternal(comp:Object, container:Array):void 
		{
			var rObject:Object = new Object();
			rObject["bodytext"] = "";
			rObject["bodytext"] = "<p>" + comp.evalInfo.questionText + "<br/>" + comp.evalData[0].answerData + "</p><br/>";
			container.push(rObject);
		}
		
		private function buildMyFun(comp:Object, container:Array):void 
		{
			var rObject:Object = new Object();
			rObject["bodytext"] = "";

			var c1:Array = new Array();
			c1[0] = "<p>I like to explore strange places.<br/>";
			c1[1] = "<p>I get restless when I spend too much time alone.<br/>";
			c1[2] = "<p>I like to do frightening things.<br/>";
			c1[3] = "<p>I like wild parties.<br/>";
			c1[4] = "<p>I would like to take off on a trip with no pre-planned routes or timetables.<br/>";
			c1[5] = "<p>I prefer friends who are excitingly unpredictable.<br/>";
			c1[6] = "<p>I would like to try bungee jumping.<br/>";
			c1[7] = "<p>I would love to have new and exciting experiences, even if they are illegal.<br/>";
	
			var scale:Array = new Array();
			scale[0] = "Strongly Disagree";
			scale[1] = "Disagree";
			scale[2] = "Neither Agree nor Disagree";
			scale[3] = "Agree";
			scale[4] = "Strongly Agree";
			
			switch(comp.id)
			{
				case "u3l6c5_1":
				case "u3l6c5_2":
				case "u3l6c5_3":
				rObject["bodytext"] = "<p>" + comp.evalInfo.questionText + "<br/>" + comp.evalData[0].answerData + "</p><br/>";
				container.push(rObject);
				break;
				
				case "u3l6c7_3":
				for (var i:uint = 0; i < comp.evalData.length; i++)
				{
					var num:uint = int(comp.evalData[i].answerData.charAt(comp.evalData[i].answerData.length - 1));
					rObject["bodytext"] += c1[i] + scale[num] + "</p><br/>";
				}
				container.push(rObject);
				break;
				
				default:
				break;
			}
			
		}
		
		private function buildOSDL(comp:Object, container:Array):void
		{
			var rObject:Object = new Object();			
			rObject["bodytext"] = "";

			switch(comp.id)
			{
				
				case "u3l7c5_1":
				case "u3l7c5_2":
				var tmp:String = comp.evalInfo.questionText.replace(/<.*?>/g, "~~~");
				var questions:Array = tmp.split("~~~");
				for (var j:uint = 0; j < comp.evalData.length; j++)
				{
					rObject["bodytext"] += "<p>" + questions[j] + "<br/>" + comp.evalData[j].answerData + "</p><br/>";
				}
				container.push(rObject);
				break;
				
				case "u3l7c5_3":
				case "u3l7c5_4":
				case "u3l7c5_5":
				rObject["bodytext"] = "<p>" + comp.evalInfo.questionText + "<br/>On a scale from 0-10: " + comp.evalData[0].answerData + "</p><br/>";
				container.push(rObject);
				break;
				
				default:
				break;
			
			}
		}
		
		private function buildRewards(comp:Object, container:Array):void 
		{
			var rObject:Object = new Object();			
			rObject["bodytext"] = "";
			var tmp:String = comp.evalInfo.questionText.replace(/<.*?>/g, "~~~");
			var questions:Array = tmp.split("~~~");
			
			for (var j:uint = 0; j < comp.evalData.length; j++)
			{
				rObject["bodytext"] += "<p>" + questions[j] + "<br/>" + comp.evalData[j].answerData + "</p><br/>";
			}
			container.push(rObject);
			
		}
		private function buildBRBQ(comp:Object, container:Array):void 
		{
			var rObject:Object = new Object();			
			rObject["bodytext"] = "";
			var tmp:String = comp.evalInfo.questionText.replace(/<.*?>/g, "~~~");
			var questions:Array = tmp.split("~~~");
			
			for (var j:uint = 0; j < comp.evalData.length; j++)
			{
				rObject["bodytext"] += "<p>" + questions[j] + "<br/>" + comp.evalData[j].answerData + "</p><br/>";
			}
			container.push(rObject);
		}
		private function buildLetter(comp:Object, container:Array):void
		{
			var rObject:Object = new Object();		
			rObject["bodytext"] = "<p>" +comp.evalData[0].answerData + "</p><br/>";
			container.push(rObject);
		}
    }
}