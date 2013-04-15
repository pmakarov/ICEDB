package com.View
{
	import com.Controller.ICompInputHandler;
	import com.Model.IModel;
	import flash.events.Event;
	import fl.controls.ComboBox;
	
	public class CBView extends CompositeView
	{
		private var cb:ComboBox;
		
		public function CBView(aModel:IModel, aController:ICompInputHandler = null)
		{
			super(aModel, aController);
			
			//get region names from model
			var aRegions:Array = (model as IModel).getRegionList();
			
			//draw combo box using region names
			cb = new ComboBox();
			for (var i:uint = 0; i < aRegions.length; i++)
			{
				cb.addItem( { label:aRegions[i], data:i});
			}
			
			update();
			addChild(cb);
				
			//register to receive changes to combo box
			cb.addEventListener(Event.CHANGE, this.changeHandler);
		}
		
		override public function update(event:Event = null):void
		{
			//get data from model and update view
			cb.selectedIndex = (model as IModel).getRegion();
			super.update(event);
		}
		
		private function changeHandler(event:Event):void
		{
			//delegate to the controller (strategy) to handle
			(controller as ICompInputHandler).compChangeHandler(ComboBox(event.target).selectedItem.data);
		}
	}
}