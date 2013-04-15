package com.Amtrak.ICE
{
	import com.Amtrak.ICE.components.multipleChoiceSingleSelect;
	/*import com.Amtrak.ICE.components.multipleChoiceMultipleSelect;
	import com.Amtrak.ICE.components.Assessment;
	import com.Amtrak.ICE.components.FillInTheBlank;
	import com.Amtrak.ICE.components.Matching;
	import com.Amtrak.ICE.components.ReflectionQuestion;*/
	
	public class EvaluationGenerator
	{
		private static var instance:EvaluationGenerator;
		private static var allowInstantiation:Boolean;
		internal var eval:Evaluation;
		
		public static function getInstance():EvaluationGenerator 
		{
			if (instance == null) 
			{
				allowInstantiation = true;
				instance = new EvaluationGenerator();
				allowInstantiation = false;
			}
         return instance;
		}

		public function EvaluationGenerator():void
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use EvaluationGenerator.getInstance() instead of new.");
			}

		}
		
		public function makeEvalFromXML(xml:XML):Evaluation
		{
			eval = this.createEvalComponent(xml);
			return eval;
		}
		
		private function createEvalComponent(xml:XML):Evaluation
		{
			var type:String = xml.@evalType.toString();
			//trace("Type: " + type);
				switch(type)
				{
					case "multipleChoiceSingleSelect":
					return new multipleChoiceSingleSelect(xml);
					break;
					
					/*case "multipleChoiceMultipleSelect":
					return new multipleChoiceMultipleSelect(xml);
					break;
					
					case "ReflectionQuestion":
					return new ReflectionQuestion(xml);
					break;
					
					case "FIB":
					return new FillInTheBlank(xml);
					break;
					
					case "matching":
					return new Matching(xml);
					break;
					
					case "assessment":
					return new Assessment(xml);
					break;*/
					
					default:
					trace(" I hit default!!");
					//throw new Error("Invalid kind of eval");
					return null;
					break;
				}
			
		}
	}
}
