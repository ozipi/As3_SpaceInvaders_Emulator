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
	import flash.display.Sprite;

	public class PaperSkin extends SimpleSkin implements ISkin
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		[Embed(source='library/linepaper.jpg')]
		private var paperClass:Class;
		private var paperBitmap:Bitmap = new paperClass();
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function PaperSkin()
		{
			super();
		}
				
		//----------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//----------------------------------------------------------------------
		override protected function setInitialProperties():void
		{
			pixels = new Sprite();
			pixelColor = 0x000000;
			paperBitmap.height = baseHeight * pixelMult; 
			paperBitmap.width = baseWidth * pixelMult;
			this.addChild(paperBitmap);
			this.addChild(pixels);
		}
	}
}