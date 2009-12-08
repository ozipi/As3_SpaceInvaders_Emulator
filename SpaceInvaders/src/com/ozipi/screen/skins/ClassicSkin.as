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
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * A classic space invaders skin (black background and one color pixels) 
	 * 
	 */
	public class ClassicSkin extends Bitmap implements ISkin
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		private var btData:BitmapData;
		private var _bitmapHeight:int = 256;
		private var _bitmapWidth:int = 224;
		private var fillColor:int = 0;
		private var pixelActiveColor:int = 0x93DCFF;
		private var pixelInactiveColor:int = 0x00;
		private var transparentBitmap:Boolean = false;
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		/**
		 * Receives the color for the screen and adds the bitmapData to a new bitmap 
		 * @param mainColor
		 * 
		 */
		public function ClassicSkin(mainColor:int=0xFFFFFF)
		{
			btData = new BitmapData(_bitmapWidth,_bitmapHeight,transparentBitmap,fillColor);
			super(btData);
			pixelActiveColor = mainColor;
		}

		//----------------------------------------------------------------------
		//
		//  Pixel Methods
		//
		//----------------------------------------------------------------------
		/**
		 * Will set the corresponding pixels inside the bitmapData 
		 * @param x
		 * @param y
		 * @param pixelSet
		 * 
		 */
		public function setPixel(x:int, y:int, pixelSet:Boolean):void
		{
			if (pixelSet)
			{
				btData.setPixel(x,y,pixelActiveColor);
			}
			else
			{
				btData.setPixel(x,y,pixelInactiveColor);
			}
		}
		
		/**
		 * Clean the pixels from the bitmapData 
		 * 
		 */
		public function cleanPixels():void
		{
			btData.fillRect(btData.rect, 0);
		}
	}
}