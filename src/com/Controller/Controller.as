package com.Controller
{
	import com.Model.IModel;
	
	public class Controller implements ICompInputHandler
	{
		private var model:Object;
		
		public function Controller(aModel:IModel)
		{
			this.model = aModel;
		}
		
		public function compChangeHandler(index:uint):void 
		{
			(model as IModel).setRegion(index); //update model
		}
	}
}