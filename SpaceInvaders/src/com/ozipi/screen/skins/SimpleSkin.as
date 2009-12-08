////////////////////////////////////////////////////////////////////////////////
//		
//	The MIT License
//
//	Copyright (c) 2009 
//	Oscar Valdez <ozipi.nomad@gmail.com>
//	Thibault Imbert <thibault@bytearray.org>
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////

package com.ozipi.screen.skins
{
	import flash.display.Sprite;
	
	public class SimpleSkin extends Sprite implements ISkin
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		protected var pixels:Sprite;
		protected var pixelColor:int = 0xff0000;
		protected var pixelMult:int = 2;
		protected var baseWidth:int = 224;
		protected var baseHeight:int = 256;
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function SimpleSkin()
		{
			super();
			setInitialProperties();
		}
		
		//----------------------------------------------------------------------
		//
		//  Helper Methods
		//
		//----------------------------------------------------------------------
		/**
		 * Adds the pixels sprite sets the correct height & width to the screen
		 *  
		 **/
		protected function setInitialProperties():void
		{
			pixels = new Sprite();
			this.addChild(pixels);
		}
		
		/**
		 * Function that set the active pixels on the pixels sprite 
		 * @param x
		 * @param y
		 * @param pixelSet
		 * 
		 */
		public function setPixel(x:int, y:int, pixelSet:Boolean):void
		{
			if (!pixelSet)
				return;

			pixelColor = pixelColor;
			pixels.graphics.beginFill(pixelColor);
			pixels.graphics.drawRect(x*pixelMult,y*pixelMult,pixelMult,pixelMult);
			pixels.graphics.endFill();
			
			//Examples of another draw methods 
			//pixels.graphics.drawCircle(x*2,y*2,.5);
			//pixels.graphics.drawCircle(x*3,y*3,1.5);
			//pixels.graphics.drawRoundRect(x*2,y*2,2,2,1);
		}
		
		/**
		 * Clean the pixels sprite 
		 * 
		 */
		public function cleanPixels():void
		{
			pixels.graphics.clear();
		}
	}
}