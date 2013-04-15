package com.Amtrak.ICE.components
{
	import com.Amtrak.ICE.utils.loadSwf;
	import flash.geom.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.ui.Mouse;
	import fl.containers.ScrollPane;
	import fl.containers.BaseScrollPane;
	

	
	/**
	 * ...
	 * @author Paul Makarov
	 */
	
	
	public class PopupWindow extends MovieClip
	{
		public var window:MovieClip;
		private var winParams:Object;
		public var titleBar:MovieClip;
		
		public function PopupWindow(message:String, url:String, params:Object = null) 
		{	
			if (params == null)
			{
				params = new Object();
				params.x = 0;
				params.y = 0;
				params.width = 300;
				params.height = 200;
			}
			winParams = params;
			winParams.message = message;
			winParams.url = url;
			createWindow();
			

			
			
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x222222, 0x000000];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 127];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(20, 100, 0, 0, 0);
			matr.rotate(Math.PI/2);
			matr.translate(5, 5);
			var spreadMethod:String = SpreadMethod.PAD;
			
			titleBar = new MovieClip();
			titleBar.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
			titleBar.graphics.drawRect(0, 0, window.width, 20);
			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, dragWindow);
			titleBar.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			//window.addChild(titleBar);
			
			trace(titleBar.height);
			titleBar.width = window.width;
			titleBar.height = 20;
			window.x = params.x;
			window.y = params.y;
			window.width = params.width;
			window.height = params.height;
			
			
		}
		public function createWindow():void
		{
			window = new MovieClip();			
			var bgColor:uint = 0xC0C0C0;

			var previewWindow:Sprite = new Sprite();
            previewWindow.x = 0;
            previewWindow.y = 0;
			previewWindow.graphics.beginFill(bgColor);
            previewWindow.graphics.lineStyle(1, 0, 1);
			previewWindow.graphics.drawRect(0,0,winParams.width,winParams.height);
            previewWindow.graphics.endFill();
			window.addChild(previewWindow);
			
			
			var fillType:String = GradientType.LINEAR;

			var colors:Array = [0x222222, 0x000000];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 127];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(20, 100, 0, 0, 0);
			matr.rotate(Math.PI/2);
			matr.translate(5, 5);
			var spreadMethod:String = SpreadMethod.PAD;
			
			titleBar = new MovieClip();
			titleBar.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
			titleBar.graphics.drawRect(0, 0, winParams.width, 20);
			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, dragWindow);
			titleBar.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			window.addChild(titleBar);
			
			var label:TextField = new TextField();
            label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
            //label.background = true;
            //label.border = true;
			label.selectable = false;
			label.x = 5;
			label.y = 0;
			label.wordWrap = false;
			label.multiline = false;
            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xAAAAAA;
            format.size = 14;
			format.bold = true;
            format.underline = false;

            label.defaultTextFormat = format;
			//label.embedFonts = true;
			label.text = winParams.message;
			
			trace(label.height + " is teh height");
			label.width = winParams.width - 40;
           window.addChild(label);
		   
			addChild(window);
		}
		public function drawLabel(str:String):void 
		{
			var label:TextField = new TextField();
			
            label.autoSize = TextFieldAutoSize.LEFT;
           // label.background = true;
            //label.border = true;
			//label.selectable = false;
			label.x = 5;
			label.y = 50;
            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFF0000;
            format.size = 14;
            format.underline = false;

            label.defaultTextFormat = format;
			label.embedFonts = true;
			label.text = "Who's that girl?";
			//this.name = str;
			//label.width = 200;
			//label.height = 20;
			trace(label.height + " is teh height");
           titleBar.addChild(label);
		}
		
		protected function buttonMouseOver(e:MouseEvent):void 
		{
			e.target.gotoAndStop(2);
		}
		
		protected function buttonMouseOut(e:MouseEvent):void 
		{
			e.target.gotoAndStop(1);
		}
		
		public function dragWindow(e:MouseEvent):void
		{
			this.window.startDrag(false);
		}
		public function focusWindow(e:MouseEvent):void
		{
			dispatchEvent(new Event("onCompWindowFocus"));
		}
		
		private function mouseMoveHandler(e:MouseEvent):void
		{
			e.updateAfterEvent();
        }
		
		public function stopDragWindow(e:MouseEvent):void
		{
			this.window.stopDrag();

		}

		public function closeComponent(e:MouseEvent):void 
		{
			dispatchEvent(new Event("onPopupWindowClose"));
		}
		
		public function doComponentMin(e:MouseEvent):void
		{
			
		}
		
		public function doComponentMax(e:MouseEvent):void
		{
		}
	
		public function doChangeView():void
		{
		}
		
		
		public function changeBarColor(color1:String, color2:String):void
		{
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [color1, color2];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 127];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(20, 100, 0, 0, 0);
			matr.rotate(Math.PI/2);
			matr.translate(5, 5);
			var spreadMethod:String = SpreadMethod.PAD;
			titleBar.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			titleBar.graphics.drawRect(0,0,window.width,20);

		}
	}	
}
