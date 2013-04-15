package com.Controller
{
	import com.Model.INewModel;
	public class MapTypeController implements ICompInputHandler
	{
		private var model:Object;
		
		public function MapTypeController(oModel:INewModel)
		{
			this.model = oModel;
		}
		
		public function compChangeHandler(index:uint):void 
		{
			(model as INewModel).setMapType(index); //update model
		}
	}
}