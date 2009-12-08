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
	import com.ozipi.custom.PausedImage;
	import com.ozipi.input.Input;
	import com.ozipi.screen.SpaceInvadersVideo;
	import com.ozipi.screen.skins.PaperSkin;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
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
		private var videoClassic:PaperSkin;
		private var pausedState:Boolean;
		private var pausedScreen:PausedImage;
		
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
			
			// Creates the classic skin (using bitmapData)
			//videoClassic = new ClassicSkin();
			// Creates the SimpleSkin (using sprite)
			//videoClassic = new SimpleSkin();
			// Creates the PaperSkin (adds a background)
			videoClassic = new PaperSkin();

			// Creates a new video output
			videoOutput = new SpaceInvadersVideo(cpu, videoClassic);
			addChild (videoClassic);

			// Cpu & video initializers
			cpu.initRegisters();
			cpu.initRom();
			cpu.setInput( input );
			input.init();
			
			// Refresh cpu & screen timer 
			refreshTimer.addEventListener(TimerEvent.TIMER, run);
			refreshTimer.start();
			pausedScreen = new PausedImage(this.width);
			pausedScreen.y = height/2 - pausedScreen.height/2;
			addChild(pausedScreen);
			pauseGame(true);
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
				if (!pausedState)
				{
					pauseGame(true);
				} else 
				{
					pauseGame(false);
				}
			}
			
			if ( e.keyCode == R_KEY )
			{
				cpu.Reset();	
			}
		}
		
		/**
		 * Pauses/Unpauses the game
		 *  
		 **/
		private function pauseGame(pause:Boolean):void
		{
			if (pause)
			{
				refreshTimer.stop();
				videoClassic.alpha = .6;
				pausedScreen.alpha = 1;
				pausedState = true;
			}
			else
			{
				refreshTimer.start();
				videoClassic.alpha = 1;
				pausedScreen.alpha = 0;
				pausedState = false;
			}
		}
	}
}