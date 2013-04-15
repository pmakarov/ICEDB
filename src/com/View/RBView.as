package com.View
{
	import com.Controller.ICompInputHandler;
	import com.Model.INewModel;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	
	public class RBView extends ComponentView
	{
		private var rbList:Array = new Array();
		private var rbGrp:RadioButtonGroup;
		
		public function RBView(aModel:INewModel, aController:ICompInputHandler = null)
		{
			super(aModel, aController);
			var aMapTypes:Array = aModel.getMapTypeList();
			
			rbGrp = new RadioButtonGroup("Map Type");
			for (var i:uint = 0; i < aMapTypes.length; i++)
			{
				var rb:RadioButton = new RadioButton();
				rb.label = aMapTypes[i];
				rb.value = i;
				rb.group = rbGrp;
				rb.x = i * 75;
				addChild(rb);
				rbList.push(rb);
			}
			update();
			rbGrp.addEventListener(MouseEvent.CLICK, this.changeHandler);
		}
		
		override public function update(event:Event = null):void
		{
			var index:uint = (model as INewModel).getMapType();
			rbList[index].selected = true;
			super.update(event);
		}
		private function changeHandler(event:Event):void
		{
			controller.compChangeHandler(event.target.selection.value);
		}
	}
}