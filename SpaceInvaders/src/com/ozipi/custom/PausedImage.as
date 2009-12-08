package com.ozipi.custom
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.utils.StringUtil;
	
	public class PausedImage extends Sprite
	{
		
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		[Embed(source='library/ozipi.png')]
		private var logoClass:Class;
		private var logoBitmap:Bitmap = new logoClass();
		
		private var txtLogo:TextField;
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function PausedImage(pWidth:Number=224,pHeight:Number=65)
		{
			super();
			setInitialProperties(pWidth,pHeight);
		}
		
		//----------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//----------------------------------------------------------------------
		/**
		 * setInitialProperties function
		 *  
		 **/
		private function setInitialProperties(pWidth:Number,pHeight:Number):void
		{
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRoundRect(0,0,pWidth,pHeight,50);
			this.graphics.endFill()
			
			var titleFormat:TextFormat = new TextFormat("Arial",18);
			txtLogo = new TextField();
			txtLogo.selectable = false;
			txtLogo.width = 250;
			txtLogo.x = (width/2) - (txtLogo.width/2);
			txtLogo.y = (height/2) - 10;
			txtLogo.text = "Press Escape to Play... :)";
			
			txtLogo.setTextFormat(titleFormat);
			txtLogo.textColor = 0x0000dd;
			
			logoBitmap.x = width - logoBitmap.width - 10;
			
			addChild(txtLogo);
			addChild(logoBitmap);
		}
	}
}