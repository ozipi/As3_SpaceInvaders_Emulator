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

package com.ozipi.cpu
{
	import com.ozipi.input.Input;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * Extends the intel8080 to create the instructions for the space invaders 
	 * execution   
	 * 
	 */
	public class SpaceInvadersCpu extends Intel8080 
	{
		//----------------------------------------------------------------------
		//
		//  Attributes
		//
		//----------------------------------------------------------------------
		//Embeds the invaders rom file
		[Embed( source="/invaders.rom", mimeType="application/octet-stream" )]
		protected var ROM:Class;

		//interrupt handling 
		protected var instruction_per_frame:int = 4000;
		protected var half_instruction_per_frame:int = instruction_per_frame >> 1;
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		public function setInput(input:Input):void
		{
			io = input;
		}
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		public function SpaceInvadersCpu()
		{
			super();
		}
		
		//----------------------------------------------------------------------
		//
		//  Control Methods
		//
		//----------------------------------------------------------------------
		/**
		 * Initializes the space invaders rom and sets the new memory space 
		 * 
		 */
		public function initRom():void
		{
			_memory = new ROM() as ByteArray;
			_memory.endian = Endian.LITTLE_ENDIAN;
			
			// Verifying the rom size and resizing the memory to 16Kb
			// Address         Size Section
			// 0000h - 1FFFh	8K	ROM
			// 2000h - 23FFh	1K	RAM
			// 2400h - 3FFFh	7K	Video RAM
			if ( _memory.length > 8192 ) throw new Error("Bad rom size!");
			_memory.length = 16384;
		}
		
		/**
		 * Runs instructions to the limit per frame 
		 * 
		 */
		public function Run():void
		{
			for (var i:int = 0; i<instruction_per_frame; ++i)
				ExecuteInstruction();
		}
		
		/**
		 * Executes the instructions from the cpu
		 * 
		 */
		private function ExecuteInstruction():void
		{
			
			disassembly_pc = PC;
			current_inst = FetchRomByte();
			
			if (opcodeTable[current_inst] != null ) opcodeTable[current_inst]();
			else throw new Error ("OPCODE unhandled");
			
			count_instructions += 1;
			
			if ( count_instructions >= half_instruction_per_frame )
			{
				if ( INTERRUPT )
				{
					if ( interrupt_alternate == 0 )
					{
						CallInterrupt(0x08);
					} else CallInterrupt(0x10);
				}
				interrupt_alternate = 1 - interrupt_alternate;
				count_instructions = 0;
			}
		}
	}
}