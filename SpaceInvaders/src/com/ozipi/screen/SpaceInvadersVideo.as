////////////////////////////////////////////////////////////////////////////////
//		
//	The MIT License
//
//	Copyright (c) 2009 Oscar Valdez
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

package com.ozipi.screen
{
	import com.ozipi.cpu.IVram;
	import com.ozipi.screen.skins.ISkin;

	/**
	 * Handles all video operations  
	 * 
	 */
	public class SpaceInvadersVideo
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		private static const VIDEO_RAM_BASE:int = 0x2400;
		private var spaceInvadersCpu:IVram;
		private var spaceSkin:ISkin; 
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		/**
		 * Receives the cpu reference and a skin to send the pixels 
		 * @param cpu
		 * @param Skin
		 * 
		 */
		public function SpaceInvadersVideo(cpuReference:IVram, Skin:ISkin)
		{
			super();
			spaceSkin = Skin;
			spaceInvadersCpu = cpuReference;
		}

		//----------------------------------------------------------------------
		//
		//  Helper Methods
		//
		//----------------------------------------------------------------------
		/**
		 * Cleans the screen and get the new video memory state 
		 * 
		 */
		public function render():void
		{
			spaceSkin.cleanPixels();
			getVideoBytes();
		}
		
		/**
		 * Gets the video ram memory bytes and send them to the corresponding skin 
		 * 
		 */
		private function getVideoBytes():void
		{
			var px:int = 0;
			var videoBytePosition:int = 0;
			var videoBytevalue:int = 0;
			var pxBytesPerRow:int = 256/8;
			var pixelActive:Boolean = false;
			var rectHeight:int = 224;
			
			videoBytePosition = VIDEO_RAM_BASE;
			for (var py:int=0;py<rectHeight;py++)
			{
				px = 0;
				for (var i:int=0;i<pxBytesPerRow;i++)
				{
					videoBytevalue = spaceInvadersCpu.memory[videoBytePosition];
					videoBytePosition += 1;
					for (var bitCompare:int=0;bitCompare<8;bitCompare++)
					{
						pixelActive = false;
						if (videoBytevalue&1) pixelActive = true;
						spaceSkin.setPixel(px,py,pixelActive);
						px++;
						videoBytevalue = videoBytevalue >> 1;
					}
				}
			}
		}
	}
}