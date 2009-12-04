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

package com.ozipi.input
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	/**
	 * Class that handles all the input/output ports 
	 * 
	 */
	public class Input extends Sprite
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		private var BIT0:int = 1;
		private var BIT1:int = 2;
		private var BIT2:int = 4;
		private var BIT3:int = 8;
		private var BIT4:int = 16;
		private var BIT5:int = 32;
		private var BIT6:int = 64;
		private var BIT7:int = 128;
		
		private var OUT_PORT1:int;
		private var OUT_PORT2:int;
		private var OUT_PORT3:int;
		private var OUT_PORT4LO:int;
		private var OUT_PORT4HI:int;
		private var OUT_PORT5:int;
		private var IN_PORT1:int;
		private var IN_PORT2:int;
		
		private var mapper:Dictionary = new Dictionary(true);
		
		public static const PLAYER_1:int = 49; 		//keyboard 1
		public static const PLAYER_2:int = 50; 		//keyboard 2
		public static const COIN_INSERTED:int = 0x43; 	//keyboard c
		public static const TILT:int = 8; 			//keyboard backspace
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function Input()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		//----------------------------------------------------------------------
		//
		//  Handler methods
		//
		//----------------------------------------------------------------------
		/**
		 * onAddedToStage function
		 *  
		 **/
		private function onAddedToStage(event:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		/**
		 * onKeyUp function
		 *  
		 **/
		private function onKeyUp(e:KeyboardEvent):void
		{
			mapper[e.keyCode] = false;
		}
		
		/**
		 * onKeyUp function
		 *  
		 **/
		private function onKeyDown(e:KeyboardEvent):void
		{
			mapper[e.keyCode] = true;
		}
		//----------------------------------------------------------------------
		//
		//  Helper Methods
		//
		//----------------------------------------------------------------------
		/**
		 * Initializes the Port 2 with 6 lives (1&2) and with the coin info off 
		 * 
		 */
		public function init():void
		{
			IN_PORT2 |= (BIT0 | BIT1);
			IN_PORT2 |= (BIT7);
		}
		
		/**
		 * Updates the port information
		 *  
		 **/
		public function update():void
		{
			IN_PORT1 = IN_PORT1 & (~(BIT0 | BIT1 | BIT2 | BIT4 | BIT5 | BIT6 ));
			IN_PORT2 = IN_PORT2 & (~(BIT2 | BIT4 | BIT5 | BIT6 ));
			
			if (mapper[COIN_INSERTED])
			{
				IN_PORT1 |= BIT0;
			}
			
			if (mapper[PLAYER_1])
			{
				IN_PORT1 |= BIT2;
			}
			
			if (mapper[PLAYER_2])
			{
				IN_PORT1 |= BIT1;
			}
			
			if (mapper[TILT])
			{
				IN_PORT2 |= BIT2;
			}
			
			if (mapper[Keyboard.LEFT])
			{
				IN_PORT1 = IN_PORT1 | BIT5;
				IN_PORT2 = IN_PORT2 | BIT5;
			}

			if (mapper[Keyboard.RIGHT])
			{
				IN_PORT1 = IN_PORT1 | BIT6;	
				IN_PORT2 = IN_PORT2 | BIT6;	
			}
			
			if (mapper[Keyboard.SPACE])
			{
				IN_PORT1 = IN_PORT1 | BIT4;	
				IN_PORT2 = IN_PORT2 | BIT4;	
			}
		}
		
		/**
		 * Sets the port information 
		 * @param port
		 * @param value
		 * 
		 */		
		public function OutPutPort(port:int,value:int):void
		{
			switch (port)
			{
				case 2:
					OUT_PORT2 = value;
					break;
				case 3:
					OUT_PORT3 = value;
					break;
				case 4:
					OUT_PORT4LO = OUT_PORT4HI;
					OUT_PORT4HI = value;
					break;
				case 5:
					OUT_PORT5 = value;
					break;
			}
		}
		
		/**
		 * Returns the port information 
		 * @param port
		 * @return 
		 * 
		 */
		public function InputPort(port:int):int
		{
			var result:int;
			switch (port)
			{
				case 1:
					result = IN_PORT1;
					break;
				case 2:
					result = IN_PORT2;
					break;
				case 3:
					result = ((((OUT_PORT4HI << 8) | OUT_PORT4LO) << OUT_PORT2) >> 8);
					break;
			}
			return result;
		}
	}
}