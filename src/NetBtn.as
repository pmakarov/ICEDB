package
{
	import flash.display.SimpleButton;
	//Button for transition triggers
	
	public class NetBtn extends SimpleButton
	{
		public function NetBtn(txt:String)
		{
			upState = new BtnState(0xfab383, 0x9e0039, txt);
			downState = new BtnState(0xffffff, 0x9e0039, txt);
			overState = new BtnState(0x9e0039, 0xfab383, txt);
			hitTestState = upState;
		}
	}
}