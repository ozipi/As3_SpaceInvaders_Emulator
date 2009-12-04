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

package
{
	import com.ozipi.cpu.SpaceInvadersCpu;
	import com.ozipi.input.Input;
	import com.ozipi.screen.SpaceInvadersVideo;
	import com.ozipi.screen.skins.Classic;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	/**
	 *	As3 space invaders emulator  
	 * 
	 */
	public class SpaceInvaders extends Sprite 
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		private static const R_KEY:int = 82;
		
		private var cpu:SpaceInvadersCpu;
		private var input:Input;
		private var videoOutput:SpaceInvadersVideo;
		private var videoClassic:Classic;
		private var paused:Boolean;
		
		private var refreshTimer:Timer = new Timer(16,0);
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		/**
		 * Sets all config for the cpu,video and input handlers 
		 * 
		 */
		public function SpaceInvaders()
		{
			// Adds a key listener to check the escape,pause and the reset key
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Creates a new spaceinvaders cpu
			cpu = new SpaceInvadersCpu();
			
			// Defines a new input handler
			addChild ( input = new Input() );
			
			// Creates a skin with a specific color
			videoClassic = new Classic(0xF6EC50);

			// Createsa new video output
			videoOutput = new SpaceInvadersVideo(cpu, videoClassic);
			addChild (videoClassic);

			// Takes the current position and adds the height beause of the negative orientation
			videoClassic.y += videoClassic.height;
			
			// Cpu & video initializers
			cpu.initRegisters();
			cpu.initRom();
			cpu.setInput( input );
			input.init();
			
			//e
			this.width = 224;
			this.height = 256;
			
			// Refresh cpu & screen timer 
			refreshTimer.addEventListener(TimerEvent.TIMER, run);
			refreshTimer.start();
			
		}		
		
		//----------------------------------------------------------------------
		//
		//  Handler methods
		//
		//----------------------------------------------------------------------
		/**
		 * Executes the cpu refresh
		 * note: i leave the same sweetspot that tibo coded on its code (3x cpu.Run())  
		 *  
		 **/
		private function run(event:TimerEvent):void
		{
			input.update();
			cpu.Run();
			cpu.Run();
			cpu.Run();
			videoOutput.render(); 
			trace("wh:" + width + ":" + height);
		}
		
		/**
		 * Handles keyboard strokes
		 * @param e
		 * 
		 */
		private function onKeyDown(e:KeyboardEvent):void
		{	
			if ( e.keyCode == Keyboard.ESCAPE) 
			{
				if ( !paused )
				{
					refreshTimer.stop();
					videoClassic.alpha = .8;
				} else 
				{
					refreshTimer.start();
					videoClassic.alpha = 1;
				}
				paused = !paused;
			}
			
			if ( e.keyCode == R_KEY )
			{
				cpu.Reset();	
			}
		}		
	}
}