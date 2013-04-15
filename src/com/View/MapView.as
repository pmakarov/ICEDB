package com.View
{
	import com.Model.IModel;
	import flash.events.Event;
	import fl.containers.UILoader;
	
	public class MapView extends ComponentView
	{
		private var uiLoader:UILoader;
		
		public function MapView(aModel:IModel, aController:Object = null)
		{
			super(aModel, aController);
			
			uiLoader = new UILoader();
			uiLoader.scaleContent = false;
			update();
			addChild(uiLoader);
		}
		
		override public function update(event:Event = null):void
		{
			//get data from model and update view
			uiLoader.source = (model as IModel).getMapURL();
		}
	}
}